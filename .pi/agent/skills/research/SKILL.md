---
name: research
description: Search the web, verify facts across multiple sources, and produce well-sourced summaries. Use when gathering information, answering questions, or validating claims.
---

# Research

Systematically search, verify, and synthesize information from the web.

## Workflow

### 1. Plan
Before searching, identify the core question and what sub-questions must be answered.

### 2. Search
Use `web_access` with `op: search` and diverse queries. Try multiple search strategies:
- Broad keyword searches for general overviews
- Specific queries with key terms and context
- Alternative spellings or related terminology

### 3. Verify
Cross-reference findings across at least two independent sources before stating a fact as established. Flag any claim that lacks supporting evidence.

### 4. Resolve
Read linked pages when summaries are insufficient. Use `web_access` with `op: fetch` to load full content from promising URLs.

### 5. Synthesize
Produce a structured summary with:
- Direct answer to the original question
- Key supporting facts, each with a direct source link (so findings are auditable)
- Confidence level (high / medium / low) based on source agreement
- Gaps or open questions that could not be resolved

## Best Practices

- Lead with authoritative sources (official docs, reputable publishers, primary sources)
- Prefer recent sources; note the date of information
- Distinguish between factual claims and opinions or speculation
- If sources conflict, present each view with its source and note the disagreement
- Summarize findings clearly; do not dump raw search results

## Output Format

```markdown
**Answer**: <direct answer to the question>

**Supporting Facts**:
- <fact> — [[source title]](<URL>)[, <date if available>]
- <fact> — [[source title]](<URL>)[, <date if available>]

**Confidence**: <high | medium | low>

**Unresolved**: <open questions or gaps, if any>
```

Each fact must cite at least one clickable source link inline. When a fact draws from multiple sources, list them separated by commas.

**Confidence guidelines**:
- **high** — multiple independent sources agree, from authoritative outlets
- **medium** — supported but by one or two sources, or sources are less authoritative
- **low** — limited evidence, unverified, or conflicting sources with no clear resolution
