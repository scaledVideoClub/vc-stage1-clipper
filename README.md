# vc-stage1-clipper

**Stage 1 of 7 — Scaled Video Club**

A video rental management system for a physical store, built in Clipper 5.2 and running under DOS (DOSBox). Keyboard only. No mouse, no network, no objects.

Part of the [Scaled Video Club](https://github.com/scaledVideoClub/vc-project) learning project — a 7-stage journey across stacks, paradigms, and eras of computing.

---

## What this is

A single-operator terminal application. The store employee registers customers, records rentals, processes returns, and checks available stock. State lives in `.dbf` files. The UI is pure Clipper text-mode.

**Paradigm:** Procedural structured  
**Constraint:** Stock (1 physical copy per movie)  
**Environment:** DOSBox (WSL or native Windows)

---

## Specs

All stage specifications live in `/specs/`:

| File | Contents |
|---|---|
| [`specs/prd.md`](specs/prd.md) | Product requirements — what the system does |
| [`specs/domain.md`](specs/domain.md) | Entities, relationships, state machine, invariants |
| [`specs/tech.md`](specs/tech.md) | Architecture, data storage, key flows |
| [`specs/test_cases.md`](specs/test_cases.md) | Validation scenarios |

---

## Docs

| File | Contents |
|---|---|
| [`docs/setup.md`](docs/setup.md) | How to set up DOSBox and compile the project |
| [`docs/run.md`](docs/run.md) | How to run through all core flows |
| [`docs/decisions.md`](docs/decisions.md) | Key architectural decisions and their rationale |
| [`docs/retrospective.md`](docs/retrospective.md) | Stage retrospective (filled after completion) |

---

## Configuration

Business parameters are set in `VIDEOCLUB.CFG` in the application directory:

```
RENTAL_DAYS=3
DAILY_RATE=2.00
LATE_FEE_DAILY=1.00
```

See [`specs/prd.md` Section 7](specs/prd.md#7-configuration) for details.

---

## Stage context

This is Stage 1 of 7. Concepts introduced here (and here only):

- Movie with stock constraint (1 copy)
- Customer (name + ID)
- Rental lifecycle (open → closed)
- Late fee calculation (display only)
- System configuration via `.CFG` file

Nothing from Stage 2 or later appears in this codebase. Stage boundaries are enforced strictly.
