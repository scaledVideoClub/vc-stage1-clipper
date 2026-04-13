# Domain Model — Stage 1: Clipper 5.2

> Defines the concepts, relationships, and rules of the system.
> Independent of technology and UI. The tech spec implements this; it does not redefine it.

---

## 1. Entities

### Movie

| Attribute | Type | Notes |
|---|---|---|
| `id` | Integer | System-assigned. Unique. Printed on the cassette label. |
| `title` | String | Display name. Not required to be unique. |
| `rented_to` | Integer | Customer ID currently holding this movie. Null if on the shelf. |
| `rented_on` | Date | Date the current rental started. Null if on the shelf. |

A movie is **available** when `rented_on IS NULL`.
A movie is **rented** when `rented_on IS NOT NULL`.
No separate availability field is stored.

### Customer

| Attribute | Type | Notes |
|---|---|---|
| `id` | Integer | System-assigned. Unique. |
| `name` | String | Full name. Used for display only. |

---

## 2. Relationships

- A **Customer** may currently hold zero or more **Movies**.
- A **Movie** is currently held by at most one **Customer**.
- There is no Rental entity. The rental relationship is state carried directly on the Movie.

---

## 3. State Transitions

### Movie

```
AVAILABLE ──[ operator rents ]──► RENTED
RENTED    ──[ operator returns ]──► AVAILABLE
```

**AVAILABLE → RENTED:** `rented_to` and `rented_on` are set. Customer active count increases by 1.

**RENTED → AVAILABLE:** `rented_to` and `rented_on` are cleared (set to null). Customer active count decreases by 1. Fee is calculated and displayed before clearing.

No other transitions exist. Movies are never deleted or suspended in Stage 1.

---

## 4. Invariants

1. A movie where `rented_on IS NOT NULL` must have a non-null `rented_to`, and vice versa.
2. A customer cannot hold more than `MAX_RENTALS` movies simultaneously.
3. No two movies can have the same `rented_to` + `rented_on` combination referencing the same customer at the same moment — each movie is an independent rental.

---

## 5. Derived Values

Calculated at runtime. Never stored.

| Value | Formula | Notes |
|---|---|---|
| `due_on` | `rented_on + RENTAL_DAYS` | Standard return deadline. |
| `days_rented` | `MAX(1, returned_on − rented_on)` | Minimum 1 day. |
| `days_overdue` | `MAX(0, returned_on − (rented_on + RENTAL_DAYS))` | Zero if returned on time or early. |
| `rental_fee` | `days_rented × DAILY_RATE` | Displayed at return. Not recorded. |
| `late_fee` | `days_overdue × LATE_FEE_DAILY` | Zero if not overdue. |
| `active_rental_count` | Count of movies where `rented_to = customer_id` | Used to enforce invariant 2. |

---

## 6. Out of Scope (Stage 1)

- Rental history — past rentals are not stored. Once a movie is returned, the rental data is gone.
- Genre, category, or any movie classification.
- Customer balance or payment records.
