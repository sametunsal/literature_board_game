# Project Context

This is a Flutter (Dart) mobile board game project.

- Game type: Board game
- Platform: Mobile (Flutter)
- Codebase style: Clean, readable, feature-first
- Development style: Iterative, agent-assisted

---

## Design & Theme

- Visual theme: Warm Library Light + Dark Academia
- UI should feel cozy, elegant, and readable
- Avoid overly bright or playful colors unless explicitly requested
- Maintain strong contrast for accessibility

---

## UI & Layout Rules (Very Important)

- Prevent overflow issues at all costs
- Always consider small screens
- Prefer:
  - LayoutBuilder
  - Expanded / Flexible
  - SingleChildScrollView where appropriate
- Avoid fixed heights unless strictly necessary
- Respect SafeArea

---

## Animation Rules

- All animations MUST use the project's animation system:
  - MotionDurations
  - MotionCurves
- Do not introduce hardcoded durations or curves
- Animations should feel soft, physical, and non-distracting

---

## Coding Rules

- Use Dart & Flutter best practices
- Keep widgets small and composable
- Prefer stateless widgets when possible
- Avoid unnecessary rebuilds
- Do not introduce new dependencies without asking

---

## Workflow Rules

Before writing code:
1. Briefly explain the plan
2. List files that will be changed

After writing code:
1. Explain what changed and why
2. Mention any potential side effects or follow-up tasks

---

## Safety & Discipline

- Never delete files unless explicitly instructed
- Never modify configuration or environment files unless asked
- Never store secrets or API keys in the repository

---

## Communication

- Be concise and technical
- Do not over-explain unless asked
- Ask for clarification if a requirement is ambiguous
