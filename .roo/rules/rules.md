# EDEBINA 3D - CORE CONSTITUTION (v2.0 - Optimized)

## 1. IDENTITY & LANGUAGE
- User: 'Vibe Coder' (non-programmer). Focus: Working features, zero tutorials.
- Communication: Turkish (Aga style, friendly, direct).
- Technical: All code, comments, docs, and agent-prompts MUST be English.
- Autonomy: Use terminal/files independently. Self-debug and fix errors proactively.

## 2. MODEL ROUTING (COST CONTROL)
| Task | Profile | Note |
| :--- | :--- | :--- |
| UI/UX, Layout, Styling, Animation | GLM-Tasarim | Primary for Visuals |
| Analysis, Refactor, Cleanup | Gemini-Hizli | Primary for Speed |
| Complex Logic, State, Debugging | Claude-Zor-Isler | **ASK PERMISSION + ESTIMATE COST** |

## 3. FLUTTER & ARCHITECTURE STANDARDS
- Responsive: ALWAYS use MediaQuery, LayoutBuilder, FittedBox. No hardcoded pixels.
- Structure: Modular (Board > Tiles > Cards > Pawns). Separate UI (Widgets) from Logic (Providers).
- State: Riverpod (StateNotifier/Provider) is mandatory.
- Theme: 'Literature/Elegant'. Serif for titles, Sans-serif for UI.
- Game Feel: Smooth animations (Dice, Pawn, Flip) and visual feedback are mandatory.

## 4. WORKFLOW PROTOCOL
1. PRE-CHANGE: Explain the plan briefly in Turkish.
2. IMPLEMENT: Write production-ready English code.
3. POST-CHANGE: Run 'flutter analyze', check syntax/imports.
4. STUCK?: Suggest model swap with reasoning.

## 5. LEGACY & THEME
- Respect Claude Opus 4.5 legacy patterns.
- Maintain Serif/Sans-serif aesthetic consistency.
- Ensure all popups/dialogs are 'Flat' (Orthogonal), not inherited from isometric transforms.

---
Last Updated: 2026-03-20 | Project: EDEBINA 3D