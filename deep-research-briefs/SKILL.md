---
name: deep-research-briefs
description: Mohamed's standing conventions for deep-research briefs. Use WITH deep-research-prompt whenever authoring a research contract for him — brief-only deliverable handed to Gemini Deep Research, required niche/practitioner-source branch, cache/documents file convention, banked-intake reconciliation.
tags: [research, deep-research, workflow]
related_skills: [deep-research-prompt]
---

# Deep Research Briefs — Mohamed's conventions

Companion to `deep-research-prompt`. That skill is manually authored and rejects agent patches (confirmed July 2026), so his standing requirements live here. Load BOTH when he asks for deep research; this file wins where they conflict.

## Search tool routing (MUST route through exa/agent-reach, not raw web_search)

Before searching, run `agent-reach doctor --json` and select a route whose `active_backend` is available. If Exa is unavailable, use agent-reach's Jina Reader fallback over a search-results page, then open the selected direct URLs through Jina:

```bash
python3 - <<'PY'
from urllib.parse import quote
from urllib.request import Request, urlopen
q = "your search query"
u = "https://r.jina.ai/https://html.duckduckgo.com/html/?q=" + quote(q)
print(urlopen(Request(u, headers={"User-Agent": "agent-reach/1.0"}), timeout=30).read().decode("utf-8", "replace"))
PY
curl -s "https://r.jina.ai/https://example.com/article"
```

Treat snippets as discovery only; fetch the source page before using a claim as evidence, and preserve the direct source URL. This fallback keeps the retrieval inside agent-reach rather than silently switching to an untracked generic search loop.

For any research that uses the web (inline execution OR author-legwork during brief authoring): the profile has the `exa` MCP (`mcp__exa__web_search_exa` with `query` + `objective`) and `agent-reach` (`mcporter call 'exa.web_search_exa(...)'`, Reddit/YouTube via backends, `r.jina.ai` for page reading). Route ALL web gathering through these — the user called out hand-grinding hermes `web_search` loops as the wrong approach mid-run and made the point explicitly ("you have agent reach and exa mcp ... why are you doing this manually"). Rule: pick the *platform-appropriate* reach tool before any generic search call — Reddits via agent-reach/opencli or exa if opencli is absent; specific hadith/books via Exa or sunnah-style corpora; practitioner threads via Exa highlight extraction, which returns graded quotes with URLs in one call and fits the evidence-registry entry shape directly. Each claim lands as one Exa call + one append; no scrape-then-plaintext-for-the-sake-of-it detours.

## Deliverable default: brief file only, external execution

- "Run the deep research prompt on X" means: AUTHOR the contract, save it, STOP. He executes externally — currently **Gemini Deep Research** (stated July 28, 2026: "Do not provide the full report only the prompt i will handoff to gemini deep research").
- Do NOT execute the research inline unless he explicitly picks "execute" or "both" on the routing clarify — OR overrides after brief delivery ("you run it", "deploy as much subagents as you want"). On override: execute the contract via subagent fan-out per the pitfall section below; the saved brief file becomes the binding spec.
- If a routing clarify times out (~10 min), default to **brief-only** — confirmed correct twice.
- Save briefs to `~/.hermes/cache/documents/<topic>_deep_research_prompt.md`. (The deep-research-prompt skill text may reference stale paths; `cache/documents/` is the live convention.)

## Required: niche/practitioner-source branch

His review reflex on any brief is "did you include Reddit etc.?" — pre-empt it. Every brief MUST contain a dedicated, **required (not optional)** practitioner/niche-source branch. Pattern that satisfied him (used in two briefs, July 28, 2026):

1. **Named source categories**, topic-appropriate. Career/interview example: Reddit (specific subs), Blind megathreads, personal writeups, LeetCode Discuss, YouTube debriefs, non-English communities (一亩三分地), question/method folklore. Training example: r/naturalbodybuilding + related subs, credentialed-coach YouTube/podcasts, current evidence debates (e.g., lengthened partials), natural-bb coaching practice, technique-variant folklore.
2. **Hard rules:** dates + source IDs on every niche claim; load-bearing claims need an independent root (repost chains count as ONE root); inaccessible categories reported as explicit gaps in Limitations, never silently omitted; practitioner-vs-official conflicts go to the contradiction table.
3. **A failure-condition line:** "A report built only on <academic/official sources> FAILS this contract."
4. **Wire it into the parallel-branch plan** as its own branch (e.g., B4a), not just a bullet under evidence protocol.

## Decision-strategy briefs (pick-a-winner questions)

When the deliverable is a ranked strategy/build choice against a known audience or competition (hackathon, RFP, pitch, application), do this author-legwork before writing the contract:

1. **Extract the live primary artifact first (event page, RFP, job posting) with web_extract and hard-code its facts as binding context.** Name the evaluators, hosts, sponsors, constraints, and deadline verbatim in the brief's mission/scope. Aggregator copies of the same artifact carry stale or conflicting facts (dates, venues, rosters) — the canonical host page wins; record the discrepancy in the brief rather than averaging.
2. **Enumerate the full option space yourself, with stable IDs (A1/A2…/B1…), and require the report to score THAT fixed set.** A strategy report left free to invent options produces an unfalsifiable menu; a fixed set lets the acceptance tests force exactly-one-winner and per-option scoring columns.
3. **Require a per-evaluator scoring dimension when evaluators are named individuals** — one column per judge/decision-maker, weights derived from their public backgrounds and labeled inference (not evidence), plus a sensitivity note showing the ranking survives re-weighting.
4. **Add a required saturation question:** given current press coverage and the topic's virality, which options will most competitors choose, and which slice is under-served? Winning strategy depends on the crowd's likely choice as much as on intrinsic merit.
5. **Require the per-option prior-work check against named existing products** (closest deployed tool per candidate option, stated difference). Closeness to an existing product is not disqualifying — the stated difference plus feasibility-in-the-actual-timebox is what the matrix must score.
6. **Require one live adversarial demo component built from a real cited published payload** (not an invented example) whenever the strategy is demonstrable — a demo against a documented attack/works-example is the strongest credibility artifact and the acceptance tests should demand it.

## Skill/plugin blueprint branch

When the downstream research will be used to create an agent skill or plugin, add a dedicated implementation branch rather than ending at descriptive synthesis. See [`references/anti-slop-skill-blueprint-notes.md`](references/anti-slop-skill-blueprint-notes.md) for the compact evidence-backed baseline. Require the report to translate evidence into:

- a class-level operating model, not a narrow one-off checklist;
- explicit modes when applicable: `diagnose` (read-only ranked findings), `refactor` (bounded behavior-preserving change), and `repair-slop` (staged remediation that may stop when safety evidence is insufficient);
- a machine-readable run manifest containing baseline status, scope, commands, changed files, verification results, rollback/checkpoint data, unresolved risks, and explicit `no edit` outcomes;
- separate treatment for style preference, maintainability risk, and behavior/security risk;
- both new-work prevention and existing-code remediation;
- acceptance tests for behavior preservation, false positives, review burden, metric gaming, and cases where the correct result is no change.

For software-quality or "slop" topics, operationalize the subject as a multi-dimensional risk profile. Do not define quality by AI provenance. Require the research to test the practitioner synthesis that harmful slop is context-free, unverified, and unaccountable output that shifts comprehension and maintenance cost to reviewers, while preserving counterexamples where duplication, complexity, abstraction, or comments are justified by domain needs.

The practitioner branch should report recurring signals such as oversized diffs, architecture/context mismatch, invented dependencies or APIs, weakened/tautological tests, swallowed errors, and inability to explain changes. Treat these as practitioner observations requiring independent corroboration, not prevalence or causal proof.

## Synthesis mandate (mirrored from deep-research-prompt §3b — mode-selective)

Every brief must require the report to contain at least ONE original analytical product derived from the evidence. Restating what the literature says is NOT a complete report, and the requirement must not be satisfied by an appended "Original Insights" section — the mode is encoded in the brief's objective, workflow, required outputs, and acceptance checks. Select a mode per brief:

- **S1 contradiction-driven (default):** organize by claims/conditions/assumptions, check comparability before calling findings contradictory, generate competing explanations with distinguishing predictions, pick the strongest survivor, and state what decision it changes. Output: a testable hypothesis or conditional rule.
- **S2 cross-domain invention:** for design/invention questions — abstract the bottleneck, transfer a mechanism from another field with the mapping and its limits specified, and run a MANDATORY prior-work check (existing method under other terminology = established practice, not invention). Separate generation from an adversarial review pass.
- **S3 experiment-driven:** ONLY for inline-executed runs (subagents with real tools) — never in a brief-only handoff to Gemini Deep Research, which cannot execute code. Without executable tools the honest deliverable is an executable protocol.

Wire this as a named deliverable in the brief (e.g., "Synthesis Artifact" section) with an explicit FAIL condition: a report that only summarizes findings fails the contract. Every derived claim carries the contribution record (Contribution / Prior work / Basis / Consequence / Test / Status), the prior-work check names the closest existing idea WITH a verifiable source (URL/DOI/evidence ID — an asserted "no comparable work exists" requires a stated search and is labeled an inference), and each derived claim includes a falsifying observation. Novelty and usefulness are reader-grading definitions, not agent self-scores: novelty = stated distance from the named closest prior work; usefulness = the concrete decision the report changes. For banked-intake work, preferred synthesis forms: consolidate the practitioner-vs-literature conflict table into a verdict/recommendation, or build the cross-branch comparison the branches individually cannot produce.

## Banked-intake pattern

When prior research artifacts exist for the domain (e.g., `training-program-design`'s references/training-research-bank.md), the brief must name them as **binding intake**: read and reconcile, don't re-derive settled conclusions (e.g., clavicle-fusion verdict), record conflicts in the contradiction table rather than silently overwriting. For standalone efforts that supersede banked work, say so explicitly in the brief.

## Inline-executed research reports: scope + example conventions

When Mohamed asks for a report to be executed inline (not handed to Gemini), two conventions from the 2026-07-29 covert-manipulation report session:

1. **Scope corrections are surgical — rewrite the file, don't append.** He asked for a report covering "micro dosing and shit" plus psychological techniques; the first draft included a full chemical-control/drugging section. His correction: "do not add the drugging to the knowledge base" (keep it out of the standing deliverable). The fix was a full rewrite of the .md with that section removed — not a note appended. When he narrows scope, regenerate the artifact cleanly.
2. **"Add fake examples" means fictional scenarios for EVERY item, one per entry.** He asked for fake examples to compare against his life. The pattern that satisfied: one blockquoted invented scenario per technique, written to be *deniable from the inside* (each piece has an innocent explanation — that deniability is what makes the comparison useful), varying genders and relationship types across examples, with an explicit "all examples are fictional composites" caveat in Limitations. For self-diagnosis-flavored requests, pair examples with a pointer to the pattern-level tests (drift over time, response to boundaries) rather than incident-matching.

## Subagent fan-out pitfalls (2026-08-06, human meta-learning run — 9 branches, 3 waves)

- **Nesting check BEFORE dispatching orchestrators.** This profile runs `max_spawn_depth=1`: `role='orchestrator'` children are SILENTLY forced to leaf and cannot call delegate_task. Prompts written as "delegate to leaf subagents" then fail per-worker: two of three burned time discovering the tool was missing and executed all research solo; the third stalled into a 600s timeout with zero output. Do NOT dispatch orchestrator-prompted workers under this config — dispatch self-contained direct-research workers in batches of 3 (`max_concurrent_children`). Note: the earlier B7 orchestration note below ("delegate_task was NOT available in the toolset") is the same forcing in a different guise, not a separate toolset absence.
- **Size tasks for a solo 600s budget:** one technique/cluster/question set per worker, cap ~5 tool calls, require a fast structured return. A prompt sized for orchestrator+3 leaves will not fit a forced-leaf budget.
- **Timeout recovery:** check the worker's evidence file for partial writes first, then redispatch immediately with narrower scope (recovered the stalled branch this way). Expect partial waves — 2/3 completing per wave is normal; retry stragglers in parallel with later waves rather than blocking.
- **Worker prompt contract that produced high-quality output:** stable IDs (A#-E#), effect sizes VERBATIM or 'not extracted' (never invented), supports/partially_supports/contradicts per claim, URL/DOI required, replication failures flagged, unresolved contradictions returned as a list (not averaged).
- **Evidence registry pattern:** one append-only file per branch at `~/.hermes/evidence/A<n>_<topic>.md`, YAML header (research_id, branch, cutoff, status) written by the parent before dispatch; branch owner appends only. Final report goes to `~/.hermes/cache/documents/<topic>_deep_research_report.md`.

## Executing a practitioner-source branch: evidence-registry shape

For lightweight user-requested research that is not a full deep-research brief, still use the same core discipline in miniature: search at least two differently worded queries, inspect high-signal threads and top comments, record subreddit/post IDs, scores, comment counts, and URLs, and distinguish community consensus from verified evidence. If the user rejected a generic answer, do not answer from memory first; gather the practitioner material before synthesizing it into an actionable routine or checklist.

When YOU execute an A7/B7-style practitioner branch (not just author the brief), the evidence file shape that satisfied the A7 contract (human-meta-learning, executed 2026-08-06, file `~/.hermes/evidence/A7_practitioner_sources.md`):

1. **Keep the pre-existing YAML header; flip `status: open` → `complete` at the end.** Append-only below it.
2. **One entry per claim, ID scheme `<branch>-E#`** (A7-E1…E25). Each entry carries: claim text, source category (Reddit sub / forum / blog / communicator), source ID (t3_ id, forum topic id, slug), date (convert Reddit epoch floats — see reddit-rdt-cli), upvotes + comment count + author handle, and TWO judgment fields:
   - **Practitioner label:** `single anecdote` (optionally "high resonance" if upvotes are high — upvotes measure resonance, not verification), `practitioner consensus` (recurring across independent threads), or `community debate` (active split, name the factions).
   - **Literature status:** `SUPPORTED` / `PARTIALLY ADDRESSED` / `UNADDRESSED` / `CONTRADICTS`, each with a one-line citation of the relevant academic anchor (e.g., Roediger & Karpicke 2006).
3. **Explicit gaps section** — every source category you could not mine (nonexistent sub, login-walled Discord, paid course content) gets a named line. Never silently omit.
4. **Practitioner-vs-literature conflict table** — markdown table: claim ID | practitioner consensus | literature status | conflict type (CONTRADICTS / UNADDRESSED). This is a required deliverable of the contract, not optional garnish.
5. **Consolidation notes** — total items, independent-root accounting (repost chains = ONE root), date coverage, per-source-category counts.

### Direct-worker execution pitfalls (B9 RETRY session, 2026-08-06 — individual-differences branch run solo, no delegation per prompt)

- **RETRY-scope pattern works solo.** A retry prompt shaped "DO NOT delegate; batch web_search; APPEND after every 2–3 searches; partial on disk beats complete-in-head" completed all 6 prioritized items in ~8 searches + 1 web_extract with 4 incremental file writes. The append-after-every-2-searches cadence is the right insurance — adopt it for any solo evidence-registry run, not just retries.
- **Person-name searches collide with celebrities.** `Borota 2014 caffeine` returned pages about Petar Borota (Chelsea goalkeeper). Fix: always anchor person-name queries with the topic noun AND venue ("post-encoding memory consolidation Nature Neuroscience") or search the replication author directly once known (Aust & Stahl 2020 surfaced the effect-size verdict faster than the original).
- **Meta-analyses can invert the expected answer — extract the gain-score correlation, not just the pretest-posttest one.** The Simonsmeier et al. 2022 prior-knowledge meta's headline is r_pre→post = .534 but r_pre→*gains* = −.059; quoting only the first would have produced a confidently wrong "knowledge-is-power" claim. When a prompt asks "what predicts learning RATE", the discriminating statistic is the gain/change correlation — check the abstract for both before writing the entry.
- **Developer-run benchmarks (FSRS vs SM-2) are citable but must carry the caveat inline** ("benchmark maintained by the algorithm's developer community; no independent peer review") in the same entry, not buried in a gaps section — prompts here treat flag-replication-failures as a hard contract.
- **Prioritized coverage lists ("if time runs short, earlier items matter more"):** work strictly in order and write each item to disk before starting the next search batch; do not batch-search all items up front.

Orchestration note from that session: `delegate_task` was NOT available in the toolset, so the three leaf investigations (Reddit via rdt-cli / blogs+forums via web_extract / communicators via web_search) were executed directly in the orchestrator session with parallel background processes, then consolidated. This fulfilled the evidence contract; flag the deviation in the final summary rather than pretending delegation happened.

## Deliverable mechanics for inline-executed reports (confirmed shape)

- Chunked writes by design: the first loaded `write_file` for the report **can time out silently mid-stream** if the content is huge — and the system may deliver a correction telling the user the write never landed. Then the *sitting* file is the DIVERGED state. Under write-even-when-unclear plan: write the file in 3-5 append chunks, each ~<3.5KB, each flushed via `execute_code` `open(path,'a')`. Only the first chunk uses `write_file`; all subsequent chunks are appends. This sidesteps stream-timeout failure on large docs entirely.
- Do not rely on the report being 'clean' after chunked writes — run a character-level audit at the end: strip/replace any non-ASCII the chunks dropped (Hermes `write_file`-accepted markdown tolerates CJK, Devanagari, bullets, ×/→; those fragments OCCUR when regenerated prompts drift through tools that re-render text). Check with `[hex(ord(c)) for c in sorted(set(c for c in txt if ord(c)>127))]` and fix in-file before delivering.
- Inline report structure that satisfied this session: Executive answer (one paragraph) -> Method -> Qur'anic anchors -> conditions -> timing table -> adab table -> opening/closing framework -> content layer (Names/tawassul / du'as of distress) -> aftercare (derived-layer labeled) -> contradiction table -> anti-patterns -> practitioner-source source table -> limitations -> practical routine ('tonight-start') -> verification disposition with the embedded research_state YAML block in full.

## Proven instances

- `~/.hermes/cache/documents/hiring_trust_hackathon_win_strategy_deep_research_prompt.md` — decision-strategy brief (pick-one-of-six build options for a hiring-trust hackathon; applied the decision-strategy patterns above).
- `~/.hermes/cache/documents/technical_interview_mastery_deep_research_prompt.md` — interview-prep theory brief (Anthropic/Apple/startups).
- `~/.hermes/cache/documents/shoulder_width_mesocycle_deep_research_prompt.md` — standalone 8-week shoulder-width specialization block brief; treats training research bank as binding intake.
- `~/.hermes/cache/documents/dua_etiquette_deep_research_report.md` (evidence: `~/.hermes/evidence/D_dua_ledger.md`) — inline-executed S1 religious research run (three-layer evidence hierarchy + practitioner conflict table) using Exa/agent-reach; see "Sensitive Islamic research: three-layer discipline" above.

## Sensitive Islamic research: three-layer discipline (confirmed inline run)

When the deep-research topic is religious (du'a etiquette, fiqh of aibah, etc.) the agent-reach skill's `references/islamic-sensitive-research.md` evidence hierarchy becomes a binding INTERNAL requirement of the report too:

1. **Level 1 primary texts** — Qur'an verse numbers + hadith collection/number + named grader (Bukhari/Muslim; Tirmidhi 3476/3479/3477, Abu Dawud 1488/521/2540, Ahmad 11133, Nasa'i 1389, Ibn Majah 1752 + Albani's Silsilah/Sahiha additions) — must appear per claim, not merged into a general bibliography paragraph. Weak chains get named inline (e.g. which narrator is mursal/weak) rather than averaged by a blanket 'traditionally believed'.
2. **Level 2 scholarly interpretation** — separate every named scholar's framework (Ibn al-Qayyim's weapon analogy, Ibn Baz on persistence, the Tawassul debate positions) from the primary-text layer; never blur 'the Prophet said' with 'scholar said'.
3. **Level 3 application** — the personal routine / practical prescription the reader follows is ALWAYS an application layer, labeled as such; never implies a revealed ruling.
4. **The 'guarantee' audit rule:** religious topics often attract a 'guaranteed' framing from practitioners that the graded texts do not support ('guaranteed acceptance', 'guaranteed reward', 'guaranteed answer'). When this happens, audit each guarantee claim as its OWN claim with its own grader chain and separate what the evidence supports from what the community inflates — the contradiction table is the right place for 'common claim X vs the graded evidence' rows.
5. **Practitioner layer for religious topics** — Reddit (r/islam, r/Muslim, r/MuslimLounge etc.) and popular-Ustadh content counts as 'community practice' branch, not as evidence for the ruling; label each entry `practitioner consensus`/`community debate`/`single anecdote` and note the direct link to the classical/manual layer (some claims will be FULLY SUPPORTED by classical hadith (framing original) and others NOT (modern numeric 'wazifa' conventions); report these separately, don't average).
6. **Authority-label audit** — identify whether each secondary source is a named scholar, a fatwa institution, an institutional explainer, or a forum moderator/user. Do not present a community reply as the named scholar's ruling, and do not turn one site's fatwa into an unnamed scholarly consensus.
7. **Mechanism audit for modern claims** — separate evidence that a belief correlates with attention, motivation, risk, or behavior from evidence that the belief's claimed supernatural mechanism is real. A psychology study about people who believe in manifestation does not establish cosmic attraction. Avoid blanket takfir: assess the person's stated attribution of power, distinguishing ordinary goal-setting or visualization from assigning independent causal power to the self or universe.

## Inline report synthesis: verifier expectations (2026-08-06, human meta-learning report)

`verify-deep-research-output.sh` + `validate-evidence-state.py` are stricter than the research-brief template implies. To reach 0 failures without multi-round churn:

- **References heading must be bare.** `## 11. References` fails the regex (`^#{1,6}[[:space:]]+(References|Sources|Bibliography)([[:space:]]|$)`); use `## References` alone on the line.
- **Structured evidence state is schema-validated, not marker-grepped.** The embedded `research_state:` YAML needs `claims` and `evidence` as non-empty LISTS of mappings: claim ids matching `C\d+` (C1, not C01), evidence ids `E\d+`, each evidence item carrying a valid `url`, an `independence_group`, and a `support:` classification (supports/partially_supports/contradicts). Every claim needs `evidence_ids` pointing at evidence items that have `support`. Prose inside the YAML markers does not satisfy this.
- **Stable-ID check greps the report BODY** for `\bC\d{2,}\b` and `\bE\d{2,}\b` — the inline (A#-E#) citation style alone fails it. Use C#/E# ids in the contradiction table (e.g. C1, C2…) so both checks pass.
- **Run a live-link pass on registry URLs before they enter the report.** Subagent registries accumulate 404s (moved PDFs, restructured blogs — Sisk 2018 and Hartshorne & Germine 2015 links died within the run); the verifier hard-counts broken external links. Swap dead links for DOI/PubMed mirrors during synthesis; don't copy registry URLs verbatim.
- **Acceptable residue at PASS:** a publisher DOI returning 403 (paywall) and one restructured practitioner URL flagged in Limitations. These are warnings, not failures.
- **The YAML `research_state` block is additive** — keep the human-readable entries_total / coverage / stopping fields alongside the schema-required lists; the validator ignores extra keys.
