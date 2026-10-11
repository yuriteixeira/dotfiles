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
- **Explicit recency filters** -- append the current year (e.g. 2026) or recent months (e.g. Oct 2026, Q3 2026, recent, latest, new release, 2026 update) to every query
- YouTube-specific queries for tutorials, benchmarks, and hands-on reviews (add `site:youtube.com` or use YouTube-focused keywords like "tutorial", "review", "benchmark", "how to")

### 3. Verify
Cross-reference findings across at least two independent sources before stating a fact as established. Flag any claim that lacks supporting evidence.

### 4. Resolve
Read linked pages when summaries are insufficient. Use `web_access` with `op: fetch` to load full content from promising URLs.

For YouTube videos that need deeper analysis, use the `youtube-transcript` skill to fetch and parse the transcript. This is useful when a video contains specific benchmark numbers, setup commands, or comparisons that cannot be confirmed from search snippets alone.

### 5. Synthesize
Produce a structured summary with:
- Direct answer to the original question
- Key supporting facts, each with a direct source link (so findings are auditable)
- Confidence level (high / medium / low) based on source agreement
- Gaps or open questions that could not be resolved
- Recent trends and new releases (separate section, see Output Format)

## Best Practices

### Prioritize Recency

- The field moves extremely fast. A model or technique released three months ago may already be superseded.
- Always include the date of every source. When no date is visible, note "date not available" rather than assuming.
- Prefer sources from the last 90 days. If only older sources exist, explicitly flag that information may be outdated.
- When searching for models, tools, or frameworks, search with explicit date qualifiers: "Q3 2026", "Oct 2026", "recent", "new", "latest release", "just released".
- Check HuggingFace model cards, release changelogs, and official blogs directly -- these update faster than summary articles.
- If a widely-cited model has been superseded, mention the older version only as context and lead with the current recommendation.

- Lead with authoritative sources (official docs, reputable publishers, primary sources)
- Distinguish between factual claims and opinions or speculation
- If sources conflict, present each view with its source and note the disagreement
- Include YouTube when hands-on testing or community sentiment is relevant
- Summarize findings clearly; do not dump raw search results

### YouTube Source Weighting
- Treat YouTube as a complementary source, not a primary authority
- Use it to surface real-world testing, hardware compatibility claims, and community trends
- Cross-reference YouTube claims with blog posts, Reddit, or official docs before treating them as established fact
- Note when a claim appears only on YouTube vs. when it is corroborated elsewhere

## Output Format

```markdown
**Answer**: <direct answer to the question>

**Supporting Facts**:
- <fact> — [[source title]](<URL>)[, <date if available>]
- <fact> — [[source title]](<URL>)[, <date if available>]

**Confidence**: <high | medium | low>

**Recent Trends & Releases** (last 90 days):
- <trending topic, new release, or community shift from the most recent sources>

**YouTube Notes** (if applicable):
- <community trend, real-world test result, or setup insight from YouTube>

**Unresolved**: <open questions or gaps, if any>
```

Each fact must cite at least one clickable source link inline. When a fact draws from multiple sources, list them separated by commas.

**Confidence guidelines**:
- **high** — multiple independent sources agree, from authoritative outlets
- **medium** — supported but by one or two sources, or sources are less authoritative
- **low** — limited evidence, unverified, or conflicting sources with no clear resolution
