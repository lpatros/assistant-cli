---
name: resume
description: Generate project summaries from local project context.
---

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

## Context

Use the project evidence supplied by the caller or user. If required evidence is missing and workspace tools are available, verify each project directory and inspect its structure, README, manifests, configuration and relevant source files yourself. Collect only missing context. Explain inaccessible projects or unavailable tools and request missing evidence instead of inventing details. Do not invoke Assistant CLI or source shell handlers.

## Output

- If the caller explicitly captures the response for one project, return only that project's raw Markdown. The caller owns the output path; do not create another file or include conversational text, confirmations or outer code fences.
- Otherwise, when file tools are available, create **`projects-resumes/`** inside the current working directory and write one `.md` file per project, named after the project folder.
- Detect identical project folder names before writing; ask for distinct output names so one result cannot silently replace another.
- Existing summaries for the same selected project may be regenerated as requested; preserve unrelated files.
- Without file tools, return clearly separated Markdown documents that the user can save.
- Report project failures, incomplete evidence and files actually produced. In captured-response mode, use the caller's error mechanism or request missing evidence before producing a document; do not present an error message as a successful summary.

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

- **ALWAYS** ground the analysis in supplied project evidence or read missing files first — package.json, README, main entry points and config files
- **NEVER** guess the tech stack — verify by reading actual config/code files
- **ALWAYS** identify the real problem the project solves, not just what it does
- **NEVER** use generic descriptions — be specific about features, architecture patterns, and technologies
- **ALWAYS** use strong action verbs (developed, implemented, built, modeled, structured, created, designed, led, optimized)
- Write descriptions as if they are professional experience, even for study projects
- Highlight real-world impact when applicable
- Mention architecture, design patterns, and best practices when applicable
- Note the project type: Scientific Initiation, Mentored Project, Study Project, Technical Assessment, Creative Project
- When analyzing multiple projects, use parallel analysis only when the environment supports it and it is permitted; otherwise process projects sequentially. A caller may already schedule projects independently.

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

- **Use supplied project evidence or inspect missing source files** — never guess
- **Identify the real problem**, not just features
- **Use strong action verbs**
- **Be specific** about architecture, patterns, and technologies
- **Output**: raw Markdown when the caller captures it; otherwise one `.md` file per project inside **`projects-resumes/`** in the CWD when file tools are available
- **Multiple projects**: pass multiple paths — one per project
- **Format sections**: Role → Problem → Technologies → Achievements → Skills
- **Classify the project type** (Scientific Initiation, Study, etc.)
