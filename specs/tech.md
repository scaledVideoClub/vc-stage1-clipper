# Tech Spec — Stage 1: Clipper 5.2

> Defines how the system is built. Implements the domain model.
> Read domain.md and prd.md before this file.

---

## 1. Architecture

Single-file procedural application. All code lives in `VIDEOCLUB.PRG` and compiles to a single `VIDEOCLUB.EXE` via the Clipper 5.2 compiler and Blinker/RTLink linker. No overlays, no external modules.

**Paradigm:** Strictly procedural. Procedures call procedures. No objects, no events, no callbacks. Execution flows top to bottom within each procedure.

**Entry point:** The `MAIN` procedure initializes the system (config, DBFs, indexes) and enters the menu loop. All other procedures are called from the menu dispatcher and return to it on completion.

---

## 2. File Structure

```
VIDEOCLUB.PRG       — All application source code
VIDEOCLUB.EXE       — Compiled executable
VIDEOCLUB.CFG       — Configuration file (key=value)
DATA\
  MOVIES.DBF        — Movie records
  MOVIES.NTX        — Index on MOVIE_ID
  CUSTOMERS.DBF     — Customer records
  CUSTOMERS.NTX     — Index on CUSTOMER_ID
```

All data files live in the `DATA\` subdirectory relative to the executable.

---

## 3. Data Storage

### MOVIES.DBF

| Field | Type | Width | Notes |
|---|---|---|---|
| `MOVIE_ID` | Numeric | 6 | Primary key. Auto-incremented. |
| `TITLE` | Character | 60 | Movie title. |
| `RENTED_TO` | Numeric | 6 | Customer ID. 0 = available. |
| `RENTED_ON` | Date | 8 | Empty (8 spaces) = available. |

**Available:** `RENTED_TO = 0` and `EMPTY(RENTED_ON)`
**Rented:** `RENTED_TO > 0` and `.NOT. EMPTY(RENTED_ON)`

Index `MOVIES.NTX` on field `MOVIE_ID`. Used for all movie lookups by catalog ID.

### CUSTOMERS.DBF

| Field | Type | Width | Notes |
|---|---|---|---|
| `CUST_ID` | Numeric | 6 | Primary key. Auto-incremented. |
| `NAME` | Character | 40 | Full name. Display only. |

Index `CUSTOMERS.NTX` on field `CUST_ID`. Used for all customer lookups by ID.

### VIDEOCLUB.CFG

Plain text, one `KEY=VALUE` per line. Read once at startup. Unknown keys are ignored.

```
RENTAL_DAYS=3
DAILY_RATE=2.00
LATE_FEE_DAILY=1.00
MAX_RENTALS=3
```

If the file is missing or a key is absent, the system uses the defaults above and displays a warning on startup before entering the menu.

---

## 4. Global Variables

Loaded from `VIDEOCLUB.CFG` at startup and used throughout the session. Never written back to disk.

```
nRentalDays     — integer, standard rental period
nDailyRate      — decimal, rental fee per day
nLateFeeDaily   — decimal, late fee per day overdue
nMaxRentals     — integer, maximum active rentals per customer
```

---

## 5. UI Model

All screens are full-screen DOS forms built with Clipper's `@ROW,COL` drawing commands. No single-line prompts. Every interaction is a form with:

- A drawn border (double-line `╔═╗║╚═╝` characters)
- Labeled fields with `@ROW,COL SAY "Label:" GET variable`
- An explicit confirmation line: `OK [Enter] / Cancel [Esc]`

Screen layout (80×25 DOS standard):
- **Row 0:** Application title bar
- **Rows 1–3:** ASCII logo area (main menu only)
- **Rows 4–20:** Form content / list content
- **Rows 22–23:** Status / error messages
- **Row 24:** Key legend (`[Enter] Confirm  [Esc] Cancel`)

Error messages appear on row 22 in reverse video and wait for a keypress before clearing.

### Main menu layout

Displayed after the ASCII logo. Options are single-keypress — no need to press Enter.

```
  ╔══════════════════════════╗
  ║  R. Rent a movie         ║
  ║  D. Return a movie       ║
  ║  ────────────────────    ║
  ║  C. New customer         ║
  ║  L. Customer list        ║
  ║  ────────────────────    ║
  ║  M. Available movies     ║
  ║  N. New movie            ║
  ║  ────────────────────    ║
  ║  X. Exit                 ║
  ╚══════════════════════════╝
```

---

## 6. Procedure Map

```
MAIN
├── LoadConfig()          — reads VIDEOCLUB.CFG into globals
├── OpenFiles()           — opens DBFs and NTX indexes
├── ShowLogo()            — draws ASCII art header
└── MenuLoop()            — main dispatch loop
    ├── RentMovie()       — Flow 2
    ├── ReturnMovie()     — Flow 3
    ├── NewCustomer()     — Flow 1
    ├── CustomerList()    — Flow 5
    ├── AvailableMovies() — Flow 4
    └── NewMovie()        — add movie to catalog
```

Each procedure is responsible for its own form drawing, input, validation, and error display. Procedures do not return values — they act directly on the open DBFs and display results on screen.

---

## 7. Key Flows (step by step)

### Startup

1. `LoadConfig()` — open `VIDEOCLUB.CFG`, parse key=value pairs into globals. If file missing, use defaults, print warning on row 22.
2. `OpenFiles()` — open `MOVIES.DBF` with `MOVIES.NTX`, open `CUSTOMERS.DBF` with `CUSTOMERS.NTX`. If any file is missing, display fatal error and exit.
3. `ShowLogo()` — draw ASCII art.
4. Enter `MenuLoop()`.

### RentMovie()

1. Draw form. Prompt for Movie ID (`MOVIE_ID`) and Customer ID (`CUST_ID`).
2. Seek `MOVIE_ID` in `MOVIES.NTX`. If not found: show "Movie not found", return.
3. Check `RENTED_TO = 0`. If rented: show "Movie not available", return.
4. Seek `CUST_ID` in `CUSTOMERS.NTX`. If not found: show "Customer not found", return.
5. Count movies where `RENTED_TO = nCustId`. If count `>= nMaxRentals`: show "Rental limit reached", return.
6. Confirm form: show movie title, customer name, due date (`DATE() + nRentalDays`). Wait for Enter/Esc.
7. On confirm: `REPLACE RENTED_TO WITH nMovieId, RENTED_ON WITH DATE()`.
8. Show "Rental recorded. Due: [date]." Return to menu.

### ReturnMovie()

1. Draw form. Prompt for Movie ID.
2. Seek `MOVIE_ID` in `MOVIES.NTX`. If not found: show "Movie not found", return.
3. Check `RENTED_TO > 0`. If not rented: show "No active rental for this movie", return.
4. Calculate:
   - `dDueOn = RENTED_ON + nRentalDays`
   - `nDaysRented = MAX(1, DATE() - RENTED_ON)`
   - `nDaysOverdue = MAX(0, DATE() - dDueOn)`
   - `nRentalFee = nDaysRented * nDailyRate`
   - `nLateFee = nDaysOverdue * nLateFeeDaily`
5. Display summary form: customer name, days rented, rental fee, overdue days (if any), late fee (if any).
6. Wait for Enter to confirm.
7. On confirm: `REPLACE RENTED_TO WITH 0, RENTED_ON WITH CTOD("  /  /  ")`.
8. Show "Movie returned." Return to menu.

### NewCustomer()

1. Draw form. Prompt for customer name.
2. Validate: name must not be empty.
3. Auto-increment: find max `CUST_ID` in `CUSTOMERS.DBF`, add 1.
4. Append new record with new ID and name.
5. Show "Customer registered. ID: [id]." Return to menu.

### NewMovie()

1. Draw form. Prompt for movie title.
2. Validate: title must not be empty.
3. Auto-increment: find max `MOVIE_ID` in `MOVIES.DBF`, add 1.
4. Append new record: `MOVIE_ID`, `TITLE`, `RENTED_TO = 0`, `RENTED_ON = empty`.
5. Show "Movie added. Catalog ID: [id]." Return to menu.

### AvailableMovies()

1. Scan `MOVIES.DBF` from top. Display records where `EMPTY(RENTED_ON)`.
2. Show paginated list: `MOVIE_ID` and `TITLE`, 15 rows per page.
3. `[N]ext / [P]rev / [Esc] back to menu`.
4. If no records match: show "No movies available."

### CustomerList()

1. Scan `MOVIES.DBF`, count `RENTED_TO` occurrences per customer into a memory array.
2. Scan `CUSTOMERS.DBF` from top. For each customer, display `CUST_ID`, `NAME`, and active rental count from array.
3. Paginated, 15 rows per page.
4. `[N]ext / [P]rev / [Esc] back to menu`.

---

## 8. Validation Rules

| Context | Rule |
|---|---|
| Movie ID input | Must be numeric and > 0 |
| Customer ID input | Must be numeric and > 0 |
| Movie title | Must not be empty or blank |
| Customer name | Must not be empty or blank |
| Rent — movie | Must exist and be available |
| Rent — customer | Must exist and be under `MAX_RENTALS` |
| Return — movie | Must exist and be currently rented |

---

## 9. Error Handling

All errors are non-fatal and display on row 22 in reverse video. The operator presses any key to clear the message and return to the current form or menu.

| Error | Message |
|---|---|
| Movie not found | `Movie not found.` |
| Movie not available | `Movie is currently rented out.` |
| Customer not found | `Customer not found.` |
| Rental limit reached | `Customer has reached the rental limit.` |
| No active rental | `No active rental for this movie.` |
| Empty input | `This field cannot be empty.` |
| DBF file missing | `[FATAL] Data file not found: [filename]. Exiting.` |
| CFG file missing | `Config file not found. Using defaults.` |

Fatal errors (missing DBF) display and exit immediately. All other errors are recoverable.
