# Retrospective — Stage 1: Clipper 5.2

> Complete this after the stage is declared Done.
> Be honest. This is for your own learning, not for an audience.

---

## 1. What the Stage Was About

Stage 1 was about a procedural paradigm approach, starting again with a clear mind. Working within the constraints of DOS and Clipper 5.2, with a stock-based rental constraint, forced the experience of simplicity and linear flow — a stark contrast to modern development where multiple layers, frameworks, and asynchronous patterns dominate.

---

## 2. What Went Well

- **Claude assistance across the full spectrum**: Getting back into Clipper syntax, writing specs, and structuring the project were all accelerated by AI guidance without replacing understanding.
- **Getting back to basics**: Old-school procedural programming brought back memories and proved sufficient for this scope. The simplicity of linear flow was striking.
- **Environment setup**: DOSBox workflow was reliable and straightforward once configured.

---

## 3. What Was Harder Than Expected

- **Fewer tools, more constraints**: Not just the DOS environment itself, but DOSBox is not a complete DOS machine. Working within its limitations required adaptation.
- **Clipper quirks**: The language is intuitive, but issues like century ambiguity in date handling caught me off guard and required side tools (BACKDATE.EXE) to work around.
- **Pagination and menu management**: Articulating flow beyond basic linear sequences felt limiting. Menus and listings without event-driven patterns were awkward to implement, even for simple interactions.

---

## 4. Spec vs Reality

| Spec Decision | What Actually Happened | Justified? |
|---------------|----------------------|------------|
| Simplified late fees model | Removed explicit delay fee calculation, worked with days only | Yes — sufficient for the exercise scope |
| Rental selection by catalog ID | Worked exactly as planned | Yes |
| Single .PRG file structure | Held up throughout without refactoring | Yes |
| Stock constraint model | Accurate; no redefinition needed | Yes |

---

## 5. Paradigm Reflection

**What did working procedurally teach you that reading about it wouldn't?**

Procedural programming is simple and straightforward. The linearity of the flow forces you to think sequentially, and the lack of OOP or frameworks means everything is explicit. This brings clarity but also reveals limitations: pagination, menu management, and basic interactivity become awkward without a way to decouple logic from presentation. You feel the weight of managing state manually through PUBLIC variables and careful ordering of operations.

**What limitations did you feel that the next paradigm would solve?**

Events. Managing menus, pagination, and user interactions without event-driven architecture is limiting. VB6's event model will let us attach behavior to user actions naturally rather than forcing everything into a sequential menu loop. However, I anticipate this gain in interactivity will come at the cost of simplicity.

**What did this paradigm do well that later stages might lose?**

**Simplicity was the most iconic easiness of that era — everything was simpler.** One file, linear flow, no abstraction layers, no framework opinions. The constraints of DOS and Clipper 5.2 forced clarity. Modern stacks, even when they solve real problems (events, concurrency, distributed state), introduce complexity that cannot be avoided. Whether we use VB6, Rails, or Python, we will lose the brutal directness of procedural code. That loss is a trade-off, not always a win.

---

## 6. AI Usage Reflection

**What worked well in the AI-assisted workflow?**

Claude helped across everything: syntax recovery, spec writing, project structure, and debugging. The spec-first workflow was effective and probably would have been advantageous even in the 1980s, before AI — the discipline of defining before coding, rather than rushing to implement and improving on the road, produces clearer thinking. AI accelerated this without replacing it.

**What didn't work? Where did AI help less?**

Nothing stands out. AI didn't miss anything in this stage. Debugging was straightforward when combined with written test cases and manual verification.

**What would you do differently with Claude in the next stage?**

Same approach: AI as a tool, but I want to code. We will lose hands-on work as we advance, and I want to preserve that while I can. The workflow of spec-first review, targeted stubs, and deliberate implementation has proven valuable.

---

## 7. Domain Notes

**Did any entity need to be redefined?**

For Stage 2, we will redefine all entities from scratch. We can start from the same conceptual model (Movie, Customer, Rental), but it should grow. The specs were correct; we can extend and improve them. The domain model should evolve, not copy.

**Did any business rule turn out to be more complex than expected?**

No. The stock constraint, late fees model, and rental lifecycle were modeled accurately in the spec and held up throughout implementation.

**What should the next stage inherit vs. rebuild?**

Stage 2 is **rebuild, not inherit** — but we rebuild from the same foundation while improving. The product spec can be shared and enhanced, but the tech spec must be rewritten entirely (domain model and architecture change). Although in theory we inherit, in practice we are rebuilding: each stage is independent, so even when concepts are carried forward, they are redefined without reference to the previous stage.

---

## 8. One Thing to Carry Forward

**Simplicity forces clarity.** In Stage 2 and beyond, when adding events, layers, and new abstractions, remember that the value came from constraints, not tools. Don't add complexity for its own sake. VB6 will give us more power, but the lesson from Clipper is: linear, explicit, and simple beats layered and implicit.

---

*Completed on: 2026-05-01*
*Next stage: Stage 2 — Visual Basic 6*
