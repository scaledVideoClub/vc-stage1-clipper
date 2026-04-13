# PRD — Stage 1: Videoclub Clipper

> Stage 1 of 7 — Clipper 5.2 | Paradigm: Procedural structured | Constraint: Stock
> Part of the Scaled Video Club learning project. See [master context](https://github.com/scaledVideoClub/vc-project) for global rules.

---

## 1. Overview

A single-operator DOS application for a physical video rental store. The store employee manages customers and movie rentals from a keyboard-driven text interface. No mouse, no graphics, no network. All state lives in `.dbf` files on disk.

The system tracks which movies are currently rented and which are on the shelf. When a customer returns a movie late, a fee is calculated and displayed. That is the entire business.

---

## 2. Actors

**One actor: the store employee (operator).** They sit at the terminal and do everything. Customers are not users of the system — they are data records to which rentals are linked.

---

## 3. Core Flows

### Flow 0 — Main menu

On startup, the system displays the "VIDEO CLUB" ASCII logo and the main menu. The operator navigates by pressing the corresponding letter. All other flows are invoked from here and return to the menu on completion.

    R. Rent a movie
    D. Return a movie
    ─────────────────────
    C. New customer
    L. Customer list
    ─────────────────────
    M. Available movies
    N. New movie
    ─────────────────────
    X. Exit

### Flow 1 — Register a customer

The operator creates a new customer record: name and a system-assigned ID. No history, no contact info, no balance. The customer is now a record the system can link rentals to.

### Flow 2 — Rent a movie

The operator:
1. Enters the catalog ID of the movie (read from the physical cassette's label)
2. Enters the customer ID
3. The system verifies the movie is available (stock = 1 unit, currently in)
4. The system records the rental: movie, customer, start date, due date
5. The movie is marked as rented (unavailable)

### Flow 3 — Return a movie

The operator:
1. Enters the catalog ID of the movie being returned
2. The system finds the active rental for that movie
3. The system calculates whether the return is late
4. If late: displays the fee owed (`days_overdue × daily_late_fee`). The operator reads this aloud — **the system does not record payment**
5. The movie is marked as available again. The rental is marked as closed.

### Flow 4 — View available movies (informational)

The operator displays a paginated list of all movies currently on the shelf (not rented out). Used to recommend titles to customers and to look up catalog IDs. No filters, no sort controls.

### Flow 5 — Customer list

The operator views a paginated list of all customers with their current number of active rentals. No history, no detail of which movies they hold.

    ID   NAME                ACTIVE
    001  García, Juan        2
    002  Martínez, Ana       0

### Flow 6 — Add a movie to the catalog

The operator adds a new movie to the system:

1. Enters the movie title
2. The system assigns the next available catalog ID
3. The movie is saved as available (no active rental)
4. The system displays the assigned catalog ID so the operator can label the physical cassette

---

## 4. Business Rules

| Rule | Definition |
|---|---|
| Stock | Every movie entry is exactly 1 physical copy. A movie is either available or rented. |
| Catalog ID | Each movie has a unique, system-assigned numeric ID. Printed on the cassette label. |
| Rental period | Configurable (see Section 7). Default: 3 days. |
| Daily rental rate | Configurable (see Section 7). Same for all movies. |
| Daily late fee | Configurable (see Section 7). Applied per day overdue. |
| Late fee calculation | `(return_date − due_date) × daily_late_fee`. Zero if returned on time or early. |
| Fee display | The system shows the fee. No payment recording in Stage 1. |
| Customer ID | System-assigned numeric ID. Operator reads it from a printed or noted customer card. |
| Duplicate rentals | A movie that is currently rented cannot be rented again until returned. |
| Customer rentals | A customer cannot hold more than `MAX_RENTALS` active rentals simultaneously. |

---

## 5. Edge Cases

- **Movie not found:** Operator enters an invalid catalog ID → system shows "movie not found" and returns to menu.
- **Movie already rented:** Operator tries to rent a movie that is out → system shows "not available" and returns to menu.
- **Customer not found:** Operator enters an invalid customer ID → system shows "customer not found" and returns to menu.
- **Movie not currently rented:** Operator tries to return a movie not marked as rented → system shows "no active rental for this movie."
- **Same-day return:** Return on the due date is not late. Fee = 0.
- **No movies available:** The availability list is empty → system shows an appropriate message instead of an empty list.
- **Config file missing:** System falls back to hardcoded defaults and warns the operator on startup.
- **Customer at limit:** Operator attempts to rent to a customer who already holds `MAX_RENTALS` active rentals → system shows "rental limit reached" and returns to menu.
---

## 6. Constraints (Stage 1 specific)

- **Stock constraint:** 1 unit per movie entry. Enforced in memory and on disk at all times.
- **No payment recording:** The system calculates and displays fees only.
- **No future-stage concepts:** No genres, no search, no customer history, no copy management, no roles, no auth, no notifications, no images, no trailers.
- **Technology:** Clipper 5.2. `.dbf` files for all persistent storage. Text UI (`@ROW,COL SAY/GET`). DOSBox environment.
- **Paradigm:** Strictly procedural. No objects, no events, no separation of concerns beyond what Clipper's procedural structure naturally provides.
- **DOS forms** All operator interactions happen through full-screen DOS forms with drawn borders, labeled fields, and OK/Cancel confirmation where appropriate. No single-line prompt inputs.

---

## 7. Configuration

Business parameters are defined in `VIDEOCLUB.CFG`, a plain-text key-value file in the application directory. The system reads it at startup and loads values into global variables. If the file is missing or a key is absent, the system uses the defaults below and prints a warning.

```
RENTAL_DAYS=3
DAILY_RATE=2.00
LATE_FEE_DAILY=1.00
MAX_RENTALS=3
```

| Key | Type | Default | Meaning |
|---|---|---|---|
| `RENTAL_DAYS` | Integer | 3 | Standard rental period in days |
| `DAILY_RATE` | Decimal | 2.00 | Price per rental (displayed only, not recorded) |
| `LATE_FEE_DAILY` | Decimal | 1.00 | Fee per day overdue |

The config file is not editable from within the application. It is a store-setup concern, not an operator-facing feature.

---

## 8. Out of Scope (Stage 1)

The following are explicitly deferred to later stages:

| Feature | Stage |
|---|---|
| Genre / category | 2 |
| Customer rental history | 2 |
| Search by title or customer | 2 |
| Multiple copies per movie | 2 |
| Movie listings with filters | 3 |
| Payment recording | 6 |
| User roles / auth | 6 |
| Edit or delete a movie | — |
---

*Stage 1 PRD v1.0 — initial*
