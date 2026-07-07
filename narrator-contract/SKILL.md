---
name: narrator-contract 
description: Generates a deterministic narrator contract from a hardware chip specification for device <device>
---

The Narrator Contract is the canonical behavioral specification shared by every
downstream code-generation skill. Rather than allowing each generator to invent
its own logging, command ordering, or naming, this skill defines the exact
observable behaviour of a minimal successful interaction with the device —
and produces that definition in a form that can be **mechanically checked**,
not just read and interpreted.

Consumers include:

* esphome_yaml
* rust_test
* rust_examples
* wokwi_custom_chip
* documentation generators
* regression tests

The generated contract becomes the single source of truth for all generated
examples. Compliance is not aspirational — every consumer either passes the
generated conformance suite or is not considered a valid implementation.

---

## Inputs

`<original_pwd>`: run pwd this is <original_pwd>
`<spec>`: file is <original_pwd>/artifacts/prompt0/<device>.md
---

## Outputs

`<narrator_contract_file>`: file is human readable, is <original_pwd>/artifacts/prompt2a/narrator_contract.md
`<narrator_contract_json>`: file is machine-readable, canonical, authoritative, is <original_pwd>/artifacts/prompt2a/narrator_contract.json                           

---

Two artifacts, always generated together and never allowed to diverge:

```
narrator_contract.md      # human-readable
narrator_contract.json    # machine-readable, canonical, authoritative
```

**The JSON file is the source of truth.** The Markdown file is a rendered
view of it, generated *from* the JSON, never written independently. If the
two ever disagree, the JSON wins and the Markdown is regenerated. This is the
single biggest change from the original design: prose can't be diffed,
hashed, or validated by downstream tooling. JSON can.

A third artifact is generated whenever `--with-fixtures` is requested:

```
narrator_contract.fixtures.json   # golden trace(s) for conformance testing
```

---

## Responsibilities

The skill must determine:

1. The minimum command sequence proving the device works.
2. Which features are intentionally outside scope — and which *behaviors*
   are explicitly forbidden (not just which commands are omitted).
3. The canonical event names and stable event IDs.
4. The canonical log strings, in a target-neutral template syntax.
5. The expected command ordering, expressed as a state machine, not prose.
6. Timing expectations, each tagged as NORMATIVE or ADVISORY.
7. Observable state transitions.
8. Expected measurement formatting, with an explicit per-language mapping.
9. Error reporting.
10. Retry behaviour, with explicit scope (is the retry *count* part of the
    contract, or only the *event on failure*?).
11. A content hash identifying this exact version of the contract, so
    consumers can detect drift automatically.
12. A machine-checkable conformance fixture downstream generators can run
    their output against.

---

## System Prompt

You are an expert embedded systems architect responsible for designing
deterministic behavioural specifications for embedded device drivers.

The Narrator Contract is not documentation. It is the canonical behavioural
specification shared by every generated implementation, and it must be
precise enough that conformance can be checked by a script, not just by a
careful reader.

Every downstream generator must produce output that is byte-identical, on the
observable surface defined below, regardless of target language. Where two
compliant implementations are *allowed* to differ (e.g. retry backoff
timing), the contract must say so explicitly — silence is not permission to
vary, it is an oversight to be fixed.

---

## Instructions

### Step 1 — Read the full specification

Understand purpose, transport, measurement model, operating modes, startup
requirements, timing requirements, and command set before writing anything.

### Step 2 — Determine Core Scope

> Why would someone actually buy this chip?

Ignore manufacturing, diagnostics, configuration, calibration, firmware
updates, and rarely-used commands unless essential to demonstrating correct
operation.

### Step 3 — Determine the Minimal Command Subset

The smallest command sequence that proves communication works, measurement
works, and returned data is parsed correctly.

### Step 4 — Determine Explicit Non-Goals *and Forbidden Behaviors*

List every excluded command and explain why. Then go further: list behaviors
a compliant implementation must **never** do, even if well-intentioned —
e.g. "must not log a retry attempt count," "must not emit a startup banner,"
"must not reorder the serial-number read after the first measurement start."
Generators reliably introduce non-compliant "helpful" extras (extra logging,
reordered setup) unless those are explicitly forbidden, not just omitted.

### Step 5 — Determine Driver States and Transitions

Identify observable states, then express legal transitions as a table, not
prose:

| From State | Event (ID) | To State |
|---|---|---|
| Initialising | N001 | ReadingSerial |
| ReadingSerial | N002→N003 | Idle |
| Idle | N004 | Measuring |
| ... | | |

Any transition not in this table is non-compliant. This replaces ordering
described only in words, which is where independent implementations diverge.

### Step 6 — Define Canonical Events with Stable IDs

Every event gets a stable ID (`N001`, `N002`, ...) independent of its log
text. IDs are permanent once assigned; they are never reused or renumbered,
even if an event is later deprecated (mark it `deprecated: true` instead).

### Step 7 — Define Canonical Log Templates in a Target-Neutral Format

Templates must not use language-specific format specifiers directly (e.g.
Python's `{x:.1f}`). Instead define a small closed registry of format types
and let each target language map them:

| Contract type | Example | Rust | Python | C |
|---|---|---|---|---|
| `hex12` | `012345ABCDEF` | `{:012X}` | `{:012X}` | `%012X` |
| `fixed1` | `23.4` | `{:.1}` | `{:.1f}` | `%.1f` |
| `int` | `100234` | `{}` | `{}` | `%d` |

The contract's log templates reference `{co2_ppm:int}`,
`{temperature_c:fixed1}` etc. — never a host-language-specific spec string.
This is what makes "byte-identical across languages" actually achievable
instead of aspirational.

### Step 8 — Define Timing, Tagged by Enforcement Level

Every timing statement is one of:

* **NORMATIVE** — must match exactly (e.g. "event N004 fires immediately
  before the command byte is written").
* **ADVISORY** — implementation may vary, contract states the allowed range
  (e.g. "retry backoff may be any value between 10–100ms; only the fact of
  a retry, and its event ID, is normative").

Untagged timing statements are a contract authoring error and must be
rejected before release.

### Step 9 — Define Formatting Rules

Same as before, but every entry must point to a registry type from Step 7,
not a free-text description.

### Step 10 — Define Error Events

Observable failures only (CRC failure, timeout, data not ready, invalid
response length, communication failure). No internal implementation detail.

### Step 11 — Generate the Golden Trace Fixture

Produce a literal, ordered list of every event ID + rendered log line that a
correct implementation emits for the minimal command sequence in Step 3,
using placeholder sample values. This becomes `narrator_contract.fixtures.json`
and is the thing downstream generators' test suites diff their actual output
against — turning "please match the contract" into "run this test and it
either passes or it doesn't."

### Step 12 — Hash and Version

Compute a content hash (e.g. SHA-256 of the canonical JSON with whitespace
normalized) and embed it as `contract_hash`. Bump `contract_version` on any
change to event IDs, log templates, formatting types, or state transitions.
Additive, backward-compatible changes (new optional event) may keep the same
major version; anything that changes existing observable output is a major
version bump.

---

## Output Format (JSON — authoritative)

```json
{
  "contract_version": 1,
  "contract_hash": "sha256:...",
  "chip": "SCD41",
  "core_scope": "...",
  "minimal_command_subset": ["..."],
  "non_goals": [
    {"item": "...", "reason": "..."}
  ],
  "forbidden_behaviors": [
    {"behavior": "...", "reason": "..."}
  ],
  "states": ["Initialising", "ReadingSerial", "Idle", "Measuring", "Error"],
  "transitions": [
    {"from": "Initialising", "event": "N001", "to": "ReadingSerial"}
  ],
  "events": [
    {
      "id": "N001",
      "name": "Driver initialised",
      "log_template": "Initialising {chip_name:str}",
      "timing": {"enforcement": "NORMATIVE", "when": "before any I2C transaction"},
      "deprecated": false
    }
  ],
  "format_types": {
    "hex12": {"description": "12-char uppercase hex"},
    "fixed1": {"description": "one decimal place"}
  },
  "error_events": ["..."],
  "fixtures_ref": "narrator_contract.fixtures.json"
}
```

## Output Format (Markdown — rendered view, generated from JSON)

Same structure as the original design (Overview / Core Scope / Minimal
Command Subset / Explicit Non-Goals / Forbidden Behaviors / Driver States /
State Transitions / Canonical Events / Formatting Rules / Error Events /
Version + Hash) — but every table is rendered *from* the JSON above, never
authored separately.

---

## Additional Rules

* Never invent commands not present in the specification.
* Never include optional features unless essential to proving correct operation.
* Prefer the smallest complete behavioural contract.
* Every generated log string must be deterministic and use only registered format types.
* Treat canonical log strings, event IDs, and state transitions as a stable public interface.
* Downstream generators must never modify wording, capitalization, spacing, punctuation, numeric formatting, command hex values, or event ordering.
* Downstream generators must declare, in a header comment of their generated output, the `contract_version` and `contract_hash` they were generated against.
* Downstream generators must include or reference a test that replays `narrator_contract.fixtures.json` and fails on any mismatch.
* A contract is not "released" until it passes the authoring checklist below.

---

## Contract Authoring Checklist (must pass before release)

- [ ] Every event has a unique, permanent ID
- [ ] Every log template uses only registered format types (no host-language syntax)
- [ ] Every timing statement is tagged NORMATIVE or ADVISORY
- [ ] Every state transition appears in the transitions table (none implied only by prose)
- [ ] Forbidden behaviors list is non-empty if any non-goal could plausibly be "helpfully" added by a generator
- [ ] `contract_hash` computed and embedded
- [ ] Golden trace fixture generated and included
- [ ] Markdown file regenerated from JSON (not hand-edited separately)

---

