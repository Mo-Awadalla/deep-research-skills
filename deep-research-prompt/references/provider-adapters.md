# Provider Adapters

The evidence contract is provider-neutral. Adapt only the execution wrapper. Provider names, model IDs, parameters, and UI paths change; verify current official documentation before emitting exact code.

## Capability check

Before dispatch, determine whether the target supports:

- autonomous iterative web search;
- URL/file context;
- code execution;
- MCP/connectors or private corpora;
- collaborative plan review;
- background/async execution;
- citations with source metadata;
- visual generation;
- configurable tool or cost budgets.

Do not simulate unavailable capabilities silently. Adjust the contract or state the limitation.

## Gemini Deep Research

Prefer the dedicated Deep Research agent rather than ordinary chat for long investigations. When supported:

- use collaborative planning for expensive/high-stakes work;
- use background execution for long-running tasks;
- enable only the tools required by the contract;
- request visualizations explicitly when they are required deliverables;
- continue plan refinement through the provider’s interaction state rather than restarting without context.

The brief itself should be the direct research task, not “summarize this prompt.”

## OpenAI Deep Research

Use a deep-research-capable model through the current Responses/Agents interface and provide at least one appropriate data source. When supported:

- set a tool-call/effort budget consistent with the contract;
- preserve response state across tool calls;
- log the request, tool calls, and source trajectory;
- use trusted MCP/connectors only;
- separate public-web and sensitive private-data phases to reduce exfiltration risk.

Do not rely on model memory for current model IDs or parameters; inspect official docs.

## Claude Research or agent harnesses

Use the provider’s research mode when available. For custom orchestrator-worker systems:

- give each worker a distinct objective, scope boundary, source/tool guidance, and return schema;
- divide independent branches rather than duplicating the same broad task;
- make the lead agent responsible for coverage, contradiction resolution, and synthesis;
- keep detailed search context in workers and return compact evidence summaries with citations;
- scale worker count to query complexity and budget.

## u14app/deep-research and prompt-override systems

Inspect the installed version or repository to discover currently supported override keys. Do not retain stale keys in the core skill.

Use overrides sparingly:

- pin the evidence/operating contract in the system-level slot;
- override the planning prompt only when the required report architecture cannot be expressed in the user brief;
- re-pin acceptance tests and rendering constraints in the final-write slot if the harness tends to lose them over long runs;
- preserve useful provider defaults rather than replacing an entire system instruction with duplicated prose.

## Generic subagent dispatch

Save the contract first, then dispatch a short instruction pointing to that file. Include a compact hard-constraints block only for requirements likely to drift:

- evidence and citation protocol;
- required counts/fields;
- formulas as text/LaTeX;
- uncertainty labels;
- no invented versions or completed tests;
- verification and repair before return.

Subagent summaries are not proof. Verify external side effects, output paths, citations, and deterministic acceptance tests in the parent session.

## Failure recovery

If provider execution fails:

1. preserve the contract and any gathered evidence;
2. identify whether the failure is provider, authentication, tool, budget, or prompt related;
3. retry only transient failures;
4. switch providers without changing the evidence contract unless capability differences require an explicit adaptation;
5. report missing capabilities and their effect on confidence.
