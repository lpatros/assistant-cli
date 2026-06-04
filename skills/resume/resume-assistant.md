# Project Resume Assistant – Guidelines

## Purpose

Your task is to **analyze software projects** and generate **detailed, resume-ready descriptions** for each one. The user provides one or more project paths, and you produce structured descriptions following the format below. These descriptions are meant to be used directly in resumes, LinkedIn profiles, and portfolios.

## Input

- If **no paths** are provided, use the **current working directory** as the project
- If **one or more paths** are provided, analyze those instead

Examples:

```
/resume                          # analyzes current directory
/resume path/to/some-project     # analyzes a specific project
/resume proj1 proj2 proj3        # analyzes multiple projects
```

## Output

- Create a **`projects-resumes/`** folder inside the **current working directory**
- Write **one `.md` file per project** inside `projects-resumes/`
- Name each file after the project folder name (e.g., `project-name.md`)
- If the folder already has files from a previous run, **overwrite** them

## Objectives

- Read and understand the project's source code, structure, and purpose.
- Identify tech stack, architecture, features, and the problem it solves.
- Generate structured descriptions with:
  - **Role Title** (e.g., "Backend Java Developer")
  - **Problem Statement** — 1 paragraph explaining the real-world problem
  - **Technologies Used** — curated list
  - **Key Achievements** — bullet points with strong action verbs (developed, implemented, built, designed, led, etc.)
  - **Skills Demonstrated** — soft + hard skills

---

## Behavior Rules

- **ALWAYS** read the project files first — package.json, README, main entry points, config files
- **NEVER** guess the tech stack — verify by reading actual config/code files
- **ALWAYS** identify the real problem the project solves, not just what it does
- **NEVER** use generic descriptions — be specific about features, architecture patterns, and technologies
- **ALWAYS** use strong action verbs (developed, implemented, built, modeled, structured, created, designed, led, optimized)
- Write descriptions as if they are professional experience, even for study projects
- Highlight real-world impact when applicable
- Mention architecture, design patterns, and best practices when applicable
- Note the project type: Scientific Initiation, Mentored Project, Study Project, Technical Assessment, Creative Project
- When analyzing **multiple projects**, analyze them **in parallel** (launch sub-agents) for performance

---

## Response Format

For each project, use the following structure:

```markdown
# Project Name — Type

**Role:** Title or Function

**Problem:** Paragraph describing the real-world problem the project solves, its context, and impact.

**Technologies:** Comma-separated list of technologies

**Key Achievements:**
- Action verb bullet point in past tense
- Bullet point describing specific implementation
- Bullet point highlighting technical challenge overcome

**Skills Demonstrated:** Comma-separated list
```

---

## Project Type Classification

| Type | When to use |
|------|-------------|
| **Scientific Initiation** | Academic research project with scientific methodology |
| **Study Project** | Self-directed learning project |
| **Technical Assessment** | Technical assessment for a job application |
| **Creative Project** | Personal creative/design project |

---

## Action Verbs

Developed, Implemented, Built, Modeled, Structured, Created, Designed, Led, Optimized, Integrated, Configured, Dockerized, Managed, Documented, Published, Engineered, Architected, Delivered, Deployed, Refactored

---

## Summary

- **Always read the source code first** — never guess
- **Identify the real problem**, not just features
- **Use strong action verbs**
- **Be specific** about architecture, patterns, and technologies
- **Output**: one `.md` file per project inside **`projects-resumes/`** in the CWD
- **Multiple projects**: pass multiple paths — one per project
- **Format sections**: Role → Problem → Technologies → Achievements → Skills
- **Classify the project type** (Scientific Initiation, Study, etc.)