# Test Cases — Stage 1: Clipper 5.2

> Manual test scripts. Execute step by step from inside DOSBox.
> Each test case is independent unless marked as requiring prior state.
> Reset DATA\ directory between test groups if needed.

---

## Conventions

- **Input:** what the operator types
- **Expected:** what the system must display or do
- **PASS / FAIL:** record result manually

---

## Group 1 — Startup

### TC-001 — Normal startup with valid config

**Preconditions:** `VIDEOCLUB.CFG` present with valid values. `DATA\` directory exists.

| Step | Action | Expected |
|---|---|---|
| 1 | Run `VIDEOCLUB` | ASCII logo displays |
| 2 | Observe | Main menu displays with all options |
| 3 | Observe | No warning messages on screen |

---

### TC-002 — Startup with missing config file

**Preconditions:** `VIDEOCLUB.CFG` deleted or renamed.

| Step | Action | Expected |
|---|---|---|
| 1 | Run `VIDEOCLUB` | Warning message: "Config file not found. Using defaults." |
| 2 | Observe | System continues to main menu normally |
| 3 | Observe | System operates with default values (RENTAL_DAYS=3, DAILY_RATE=2.00, LATE_FEE_DAILY=1.00, MAX_RENTALS=3) |

---

### TC-003 — Startup with missing DATA directory or DBF files

**Preconditions:** `DATA\` directory deleted or `MOVIES.DBF` removed.

| Step | Action | Expected |
|---|---|---|
| 1 | Run `VIDEOCLUB` | Fatal error message displayed |
| 2 | Observe | System exits — does not reach main menu |

---

## Group 2 — New Movie (Flow 6)

### TC-010 — Add a movie successfully

| Step | Action | Expected |
|---|---|---|
| 1 | From main menu press `N` | New movie form displays with border and labeled field |
| 2 | Enter title: `Terminator 2` | Field accepts input |
| 3 | Press Enter to confirm | System displays: "Movie added. Catalog ID: 1" |
| 4 | Return to main menu | Menu redisplays cleanly |

---

### TC-011 — Add multiple movies, IDs auto-increment

**Preconditions:** TC-010 completed (one movie exists with ID 1).

| Step | Action | Expected |
|---|---|---|
| 1 | Press `N`, enter title `Jurassic Park`, confirm | "Movie added. Catalog ID: 2" |
| 2 | Press `N`, enter title `The Fugitive`, confirm | "Movie added. Catalog ID: 3" |

---

### TC-012 — Add movie with empty title

| Step | Action | Expected |
|---|---|---|
| 1 | Press `N` | New movie form displays |
| 2 | Leave title blank, press Enter | Error message: "This field cannot be empty." |
| 3 | Observe | Form remains open, operator can re-enter |

---

### TC-013 — Cancel new movie

| Step | Action | Expected |
|---|---|---|
| 1 | Press `N` | New movie form displays |
| 2 | Enter a title, press Esc | No movie added, return to menu |

---

## Group 3 — New Customer (Flow 1)

### TC-020 — Register a customer successfully

| Step | Action | Expected |
|---|---|---|
| 1 | Press `C` | New customer form displays |
| 2 | Enter name: `Juan Garcia` | Field accepts input |
| 3 | Press Enter to confirm | "Customer registered. ID: 1" |
| 4 | Return to menu | Menu redisplays cleanly |

---

### TC-021 — Multiple customers, IDs auto-increment

**Preconditions:** TC-020 completed.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `C`, enter `Ana Martinez`, confirm | "Customer registered. ID: 2" |
| 2 | Press `C`, enter `Pedro Lopez`, confirm | "Customer registered. ID: 3" |

---

### TC-022 — Register customer with empty name

| Step | Action | Expected |
|---|---|---|
| 1 | Press `C` | New customer form displays |
| 2 | Leave name blank, press Enter | Error: "This field cannot be empty." |
| 3 | Observe | Form remains open |

---

## Group 4 — Rent a Movie (Flow 2)

**Preconditions for this group:** At least 3 movies (IDs 1, 2, 3) and 2 customers (IDs 1, 2) exist. All movies available.

### TC-030 — Rent a movie successfully

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays with Movie ID and Customer ID fields |
| 2 | Enter Movie ID: `1`, Customer ID: `1` | Confirmation form shows movie title, customer name, due date |
| 3 | Press Enter to confirm | "Rental recorded. Due: [today + RENTAL_DAYS]" |
| 4 | Return to menu | Menu redisplays |

---

### TC-031 — Rented movie no longer appears as available

**Preconditions:** Run TC-010, TC-011, TC-020, TC-030 in order.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `M` (available movies) | List displays |
| 2 | Observe | Movie ID 1 (`Terminator 2`) does NOT appear in list |
| 3 | Observe | Movies 2 and 3 appear normally |

---

### TC-032 — Rent movie with invalid Movie ID

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays |
| 2 | Enter Movie ID: `999`, Customer ID: `1` | Error: "Movie not found." |
| 3 | Observe | Return to menu |

---

### TC-033 — Rent movie that is already rented

**Preconditions:** Run TC-010, TC-020, TC-030 in order. Movie 1 is currently rented to Customer 1.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays |
| 2 | Enter Movie ID: `1`, Customer ID: `2` | Error: "Movie is currently rented out." |
| 3 | Observe | Return to menu |

---

### TC-034 — Rent with invalid Customer ID

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays |
| 2 | Enter Movie ID: `2`, Customer ID: `999` | Error: "Customer not found." |
| 3 | Observe | Return to menu |

---

### TC-035 — Rent cancelled with Esc

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays |
| 2 | Enter Movie ID: `2`, Customer ID: `1`, press Esc on confirmation | No rental recorded |
| 3 | Press `M` | Movie 2 still appears as available |

---

### TC-036 — Customer reaches rental limit (MAX_RENTALS=3)

**Preconditions:** Set `MAX_RENTALS=3` in `VIDEOCLUB.CFG`. Then:
1. Press `N`, add movies: `Terminator 2` (ID 1), `Jurassic Park` (ID 2), `The Fugitive` (ID 3), `Schindler's List` (ID 4)
2. Press `C`, add customer: `Juan Garcia` (ID 1)
3. Press `R`, rent movie 1 to customer 1
4. Press `R`, rent movie 2 to customer 1
5. Press `R`, rent movie 3 to customer 1 — customer now holds 3 active rentals

| Step | Action | Expected |
|---|---|---|
| 1 | Press `R` | Rent form displays |
| 2 | Enter Movie ID: `4`, Customer ID: `1` | Error: "Customer has reached the rental limit." |
| 3 | Observe | Return to menu, movie 4 still available |

---

### TC-037 — Customer at limit can rent after returning one

**Preconditions:** TC-036 completed. Customer 1 holds movies 1, 2, 3.

| Step | Action | Expected |
|---|---|---|
| 1 | Return movie 1 (see TC-040) | Return succeeds |
| 2 | Press `R`, enter Movie ID: `4`, Customer ID: `1` | Confirmation form shows — rental allowed |
| 3 | Confirm | Rental recorded successfully |

---

## Group 5 — Return a Movie (Flow 3)

**Preconditions for this group:**
1. Press `N`, add movie: `Terminator 2` (ID 1)
2. Press `N`, add movie: `Jurassic Park` (ID 2)
3. Press `C`, add customer: `Juan Garcia` (ID 1)
4. Press `R`, rent movie 1 to customer 1 — rental starts today

### TC-040 — Return on time (same day, minimum fee)

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D` | Return form displays |
| 2 | Enter Movie ID: `1` | Summary form: customer name, days rented = 1 (minimum), rental fee = 1 × DAILY_RATE, late fee = 0 |
| 3 | Press Enter to confirm | "Movie returned." |
| 4 | Press `M` | Movie 1 appears again in available list |

---

### TC-041 — Return with late fee

**Preconditions:** This test requires a rental with a past date that cannot be set from the UI.
1. Press `N`, add movie: `Jurassic Park` (ID 2)
2. Press `C`, add customer: `Juan Garcia` (ID 1)
3. Run `TOOLS\TESTDATA` from DOSBox — this sets movie 2 as rented to customer 1 with `RENTED_ON` = today minus 5 days (RENTAL_DAYS=3, so 2 days overdue)

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D`, enter Movie ID: `2` | Summary shows: days rented = 5, rental fee = 5 × DAILY_RATE, days overdue = 2, late fee = 2 × LATE_FEE_DAILY |
| 2 | Confirm | "Movie returned." Movie 2 available again |

---

### TC-042 — Return on exact due date (no late fee)

**Preconditions:** This test requires a rental with a past date that cannot be set from the UI.
1. Press `N`, add movie: `The Fugitive` (ID 3)
2. Press `C`, add customer: `Juan Garcia` (ID 1)
3. Run `TOOLS\TESTDATA` from DOSBox — this sets movie 3 as rented to customer 1 with `RENTED_ON` = today minus RENTAL_DAYS (exactly on due date)

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D`, enter Movie ID | Summary shows: days overdue = 0, late fee = 0 |
| 2 | Confirm | "Movie returned." |

---

### TC-043 — Return movie not found

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D` | Return form displays |
| 2 | Enter Movie ID: `999` | Error: "Movie not found." |
| 3 | Observe | Return to menu |

---

### TC-044 — Return movie that is not currently rented

**Preconditions:**
1. Press `N`, add movie: `The Fugitive` (ID 3)
2. Do NOT rent movie 3 — it must remain available

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D`, enter Movie ID: `3` | Error: "No active rental for this movie." |
| 2 | Observe | Return to menu |

---

### TC-045 — Return cancelled with Esc

**Preconditions:** Run TC-010, TC-020, TC-030 in order. Movie 1 is currently rented to Customer 1.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `D`, enter Movie ID: `1` | Summary form displays |
| 2 | Press Esc | No changes made. Movie remains rented |
| 3 | Press `M` | Movie 1 does NOT appear as available |

---

## Group 6 — Available Movies (Flow 4)

### TC-050 — List with available movies

**Preconditions:**
1. Press `N`, add movies: `Terminator 2` (ID 1), `Jurassic Park` (ID 2), `The Fugitive` (ID 3)
2. Press `C`, add customer: `Juan Garcia` (ID 1)
3. Press `R`, rent movie 1 to customer 1 — movies 2 and 3 remain available

| Step | Action | Expected |
|---|---|---|
| 1 | Press `M` | List displays with border |
| 2 | Observe | Movie 1 NOT listed |
| 3 | Observe | Movies 2 and 3 listed with their IDs and titles |

---

### TC-051 — List with no available movies

**Preconditions:**
1. Press `N`, add movies: `Terminator 2` (ID 1), `Jurassic Park` (ID 2)
2. Press `C`, add customers: `Juan Garcia` (ID 1), `Ana Martinez` (ID 2)
3. Press `R`, rent movie 1 to customer 1
4. Press `R`, rent movie 2 to customer 2 — all movies now rented

| Step | Action | Expected |
|---|---|---|
| 1 | Press `M` | Message: "No movies available." |
| 2 | Observe | No list renders, no crash |

---

### TC-052 — Pagination (more than 15 available movies)

**Preconditions:** 20 available movies exist.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `M` | First 15 movies listed |
| 2 | Press `N` (next) | Next 5 movies listed |
| 3 | Press `P` (prev) | Returns to first 15 |
| 4 | Press Esc | Returns to main menu |

---

## Group 7 — Customer List (Flow 5)

### TC-060 — List with active rentals

**Preconditions:**
1. Press `N`, add movies: IDs 1, 2, 3 (any titles)
2. Press `C`, add customers: `Juan Garcia` (ID 1), `Ana Martinez` (ID 2), `Pedro Lopez` (ID 3)
3. Press `R`, rent movie 1 to customer 1
4. Press `R`, rent movie 2 to customer 1 — customer 1 now holds 2
5. Press `R`, rent movie 3 to customer 2 — customer 2 holds 1
6. Customer 3 has no rentals

| Step | Action | Expected |
|---|---|---|
| 1 | Press `L` | List displays with border |
| 2 | Observe Customer 1 | Shows ACTIVE = 2 |
| 3 | Observe Customer 2 | Shows ACTIVE = 1 |
| 4 | Observe Customer 3 | Shows ACTIVE = 0 |

---

### TC-061 — Active count updates after return

**Preconditions:** TC-060 completed. Customer 1 holds movies 1 and 2.

| Step | Action | Expected |
|---|---|---|
| 1 | Return one of Customer 1's movies | Return succeeds |
| 2 | Press `L` | Customer 1 now shows ACTIVE = 1 |

---

### TC-062 — Pagination (more than 15 customers)

**Preconditions:** 20 customers exist.

| Step | Action | Expected |
|---|---|---|
| 1 | Press `L` | First 15 customers listed |
| 2 | Press `N` | Next 5 customers listed |
| 3 | Press Esc | Returns to main menu |

---

## Group 8 — Invariant Verification

### TC-070 — Movie state consistency after rent

**Preconditions:**
1. Press `N`, add movie: `Terminator 2` (ID 1)
2. Press `C`, add customer: `Juan Garcia` (ID 1)
3. Movie 1 is available

| Step | Action | Expected |
|---|---|---|
| 1 | Rent movie 1 to customer 1 | Rental recorded |
| 2 | Press `M` | Movie 1 absent from available list |
| 3 | Press `L` | Customer 1 shows ACTIVE = 1 |
| 4 | Attempt to rent movie 1 again | Error: "Movie is currently rented out." |

---

### TC-071 — Movie state consistency after return

**Preconditions:** TC-070 completed. Movie 1 is currently rented to Customer 1.

| Step | Action | Expected |
|---|---|---|
| 1 | Return movie 1 | Return succeeds |
| 2 | Press `M` | Movie 1 appears in available list |
| 3 | Press `L` | Customer 1 shows ACTIVE = 0 |
| 4 | Attempt to rent movie 1 again | Confirmation form shows — rent allowed |

---

### TC-072 — MAX_RENTALS enforced across sessions

**Preconditions:**
1. Edit `VIDEOCLUB.CFG`, set `MAX_RENTALS=2`
2. Press `N`, add movies: `Terminator 2` (ID 1), `Jurassic Park` (ID 2), `The Fugitive` (ID 3)
3. Press `C`, add customer: `Juan Garcia` (ID 1)
4. Press `R`, rent movie 1 to customer 1
5. Press `R`, rent movie 2 to customer 1 — customer now holds 2 (at limit)
6. Press `X` to exit the application

| Step | Action | Expected |
|---|---|---|
| 1 | Exit and restart application | System starts normally |
| 2 | Attempt to rent a third movie to Customer 1 | Error: "Customer has reached the rental limit." |

---

## Group 9 — Configuration

### TC-080 — Custom config values applied

**Preconditions:**
1. Edit `VIDEOCLUB.CFG` to contain:
   ```
   RENTAL_DAYS=5
   DAILY_RATE=3.00
   LATE_FEE_DAILY=2.00
   MAX_RENTALS=2
   ```
2. Press `N`, add movies: `Terminator 2` (ID 1), `Jurassic Park` (ID 2), `The Fugitive` (ID 3)
3. Press `C`, add customer: `Juan Garcia` (ID 1)
4. Restart application so new config values are loaded

| Step | Action | Expected |
|---|---|---|
| 1 | Rent movie 1 to customer 1 | Confirmation form shows due date = today + 5 days |
| 2 | Return movie 1 same day | Rental fee = 1 × 3.00 = 3.00, late fee = 0 |
| 3 | Rent movies 1 and 2 to customer 1 | Both succeed |
| 4 | Attempt to rent movie 3 to customer 1 | Error: "Customer has reached the rental limit." |
