# Canary (`studio2201/canary`)

[![studio2201 Suite](https://img.shields.io/badge/studio2201-5%2F5%20Verified-2f6f5e?logo=shield)](https://studio2201.com/agents#badges)
[![Release](https://img.shields.io/badge/version-v0.1.4-blue.svg)](https://github.com/studio2201/canary/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

<details>
<summary>
  <a href="https://studio2201.com/agents#badges">
    <img src="https://img.shields.io/badge/studio2201-5%2F5%20Verified-2f6f5e?logo=shield" alt="studio2201 Suite">
  </a> <b>Detailed Governance Scorecard</b>
</summary>

| Tool | Focus | Verdict | Status Badge |
| :--- | :--- | :---: | :---: |
| [**Snip**][u-snip] | Vibe-Code & Secrets Gate | `SHIP` | [![Vibe-Safe][b-snip]][u-snip] |
| [**Vigil**][u-vigil] | Supply-Chain Dormancy | `HEALTHY` | [![Dormancy][b-vigil]][u-vigil] |
| [**Aegis**][u-aegis] | PQC & Post-Quantum Scans | `QUANTUM-SAFE` | [![PQC][b-aegis]][u-aegis] |
| [**Proven**][u-proven] | ML-DSA-65 Attestation | `VERIFIED` | [![SLSA][b-proven]][u-proven] |
| [**Boneyard**][u-boneyard] | Tech-Debt Radar | `0/100 DEBT` | [![Boneyard][b-boneyard]][u-boneyard] |

[u-snip]: https://studio2201.com/snip
[u-vigil]: https://studio2201.com/vigil
[u-aegis]: https://studio2201.com/aegis
[u-proven]: https://studio2201.com/proven
[u-boneyard]: https://studio2201.com/boneyard
[b-snip]: https://img.shields.io/badge/vibe--safe-SHIP-brightgreen.svg
[b-vigil]: https://img.shields.io/badge/dormancy-healthy-2f6f5e.svg
[b-aegis]: https://img.shields.io/badge/PQC-Quantum--Safe-blueviolet.svg
[b-proven]: https://img.shields.io/badge/SLSA-Level%203%2B-blue.svg
[b-boneyard]: https://img.shields.io/badge/boneyard%20index-0%2F100-brightgreen.svg

</details>

> Reference failure repository providing deliberate, realistic triggers across all studio2201 tools.

Canary is an intentionally broken reference repository engineered for **negative testing**,
continuous integration gating, and live technical demonstration of the
[studio2201](https://studio2201.com) developer tools suite:
**Snip**, **Vigil**, **Aegis**, **Proven**, and **Boneyard**.

## Deliberate Failure Matrix

| Product | Focus | Failure Badge | Expected Verdict | Fixture Target | Exit Code |
| :--- | :--- | :--- | :---: | :--- | :---: |
| [**Snip**][u-snip] | Vibe-code security gate | [![Vibe-Safe][fb-snip]][c-snip] | `BLOCK` | `fixtures/snip/staged.patch` | `1` |
| [**Vigil**][u-vigil] | Supply-chain dormancy scanner | [![Dormancy][fb-vigil]][c-vigil] | `DORMANT` | `fixtures/vigil/package.json` | `1` |
| [**Aegis**][u-aegis] | PQC migration SDK & scanner | [![PQC][fb-aegis]][c-aegis] | `NON-COMPLIANT` | `fixtures/aegis/legacy_crypto.rs` | `1` |
| [**Proven**][u-proven] | PQC supply-chain attestor | [![SLSA][fb-proven]][c-proven] | `TAMPERED` | `fixtures/proven/canary_artifact` | `1` |
| [**Boneyard**][u-boneyard] | Org-wide tech-debt radar | [![Boneyard][fb-boneyard]][c-boneyard] | `DEBT BREACH` | `fixtures/boneyard/catalog.json` | `1` |

[c-snip]: https://studio2201.com/canary#snip
[c-vigil]: https://studio2201.com/canary#vigil
[c-aegis]: https://studio2201.com/canary#aegis
[c-proven]: https://studio2201.com/canary#proven
[c-boneyard]: https://studio2201.com/canary#boneyard
[fb-snip]: https://img.shields.io/badge/vibe--safe-BLOCK-red.svg
[fb-vigil]: https://img.shields.io/badge/dormancy-CRITICAL-red.svg
[fb-aegis]: https://img.shields.io/badge/PQC-NON--COMPLIANT-red.svg
[fb-proven]: https://img.shields.io/badge/SLSA-TAMPERED-red.svg
[fb-boneyard]: https://img.shields.io/badge/boneyard%20index-72%2F100-red.svg

## Why Negative CI Verification Is Critical

In software security, verifying that clean code passes is only half the battle.
A security linter or supply-chain gate that never fails in CI provides false confidence
and is indistinguishable from a no-op.

Negative testing validates that defensive gates reliably detect and intercept real-world violations:
- **Authentic Fixtures**: Flaws are modeled directly on common production mistakes—live secret leaks
  (GitGuardian), unpatched dependencies (CVE-2024-3094), PQC violations (OMB M-26-15),
  corrupted build attestations (SolarWinds), and runaway technical debt.
- **Fail-Closed Verification**: Every tool in the suite must flag its respective defect,
  emit actionable remediation diagnostics, and exit with code `1`.
- **Automated Gates Beat Manual Discipline**: Developers rarely run negative sanity tests manually.
  Loading Canary checks into automated CI guarantees that gates never degrade into silent passes.

## Autonomous Agent Integration

Deploy Canary negative verification into CI using an AI coding assistant or copy the workflow below.

### Prompt for your AI Agent

Copy and paste this prompt to Cursor, Claude Code, Copilot Workspace, or Devin:

```text
Add a GitHub Actions workflow to this repository at .github/workflows/studio2201.yml using studio2201/studio2201@master.
Trigger on pull_request and push to master/main, and workflow_dispatch.
Configure concurrency with cancel-in-progress on pull requests.
Set permissions to contents: read, checkout with fetch-depth: 0, run studio2201/studio2201@master with tools: 'all' and fail-on: 'block'.
Retain audit findings using actions/upload-artifact@v4 with if: always().
Finally, add the Option 1 Single Suite Badge or Option 2 Governance Scorecard to README.md.
```

### GitHub Actions Workflow

Commit this complete, production-ready workflow at `.github/workflows/studio2201.yml`:

```yaml
name: studio2201 Security Gate
on:
  push:
    branches: [ master, main ]
  pull_request:
    branches: [ master, main ]
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions:
  contents: read

jobs:
  security-gate:
    name: studio2201 Security Gate
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run studio2201 Security Gate
        uses: studio2201/studio2201@master
        with:
          tools: 'all'
          fail-on: 'block'

      - name: Retain Audit Findings
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: studio2201-audit-findings
          path: |
            *_report.md
          if-no-files-found: ignore
```

## Single-Command Demo (`demo.sh`)

Canary provides `./demo.sh` to execute the full negative verification suite in a single terminal command:

```bash
./demo.sh
```

### Script Execution & Discovery
`demo.sh` automatically locates compiled binaries via `STUDIO2201_BIN_DIR`, sibling workspaces,
`~/.local/bin`, or `$PATH`. It evaluates each tool against its fixture, asserts exit code `1`,
and displays a concise verification scorecard:

```text
+----------+--------------------------+-----+-----+---------------+--------+
| Tool     | Target                   | Exp | Act | Verdict       | Status |
+----------+--------------------------+-----+-----+---------------+--------+
| snip     | snip/staged.patch        |  1  |  1  | BLOCK         |  PASS  |
| vigil    | vigil/package.json       |  1  |  1  | DORMANT       |  PASS  |
| aegis    | aegis/legacy_crypto.rs   |  1  |  1  | NON-COMPLIANT |  PASS  |
| proven   | proven/canary_artifact   |  1  |  1  | TAMPERED      |  PASS  |
| boneyard | boneyard/catalog.json    |  1  |  1  | DEBT BREACH   |  PASS  |
+----------+--------------------------+-----+-----+---------------+--------+
✓ ALL 5 CHECKS PASSED: All tools failed with exit code 1 as expected.
```

The script supports `NO_COLOR=1` and detects non-interactive pipes for automation.

## Tool Failure Breakdowns

### 1. Snip — Vibe-Code Secret & SQL Safety Gate

[![Vibe-Safe](https://img.shields.io/badge/vibe--safe-BLOCK-red.svg)](https://studio2201.com/canary#snip)

- **Deliberate Flaw**: `fixtures/snip/api_keys.ts` has live keys; `001_create_accounts.sql` lacks RLS.
- **Command & Verdict (`BLOCK`, exit 1)**:
  ```text
  $ snip audit fixtures/snip/staged.patch
  snip verdict: BLOCK (exit 1) — 2 CRITICAL secrets, 1 HIGH migration (missing RLS)
  ```
- **Rationale**: Prevents accidental leakage of live payment credentials and API keys. Enforces multi-tenant isolation.

### 2. Vigil — Supply-Chain Dependency Dormancy Scanner

[![Dormancy](https://img.shields.io/badge/dormancy-CRITICAL-red.svg)](https://studio2201.com/canary#vigil)

- **Deliberate Flaw**: `fixtures/vigil/package.json` references abandoned npm packages (`colors`, `nom`, `request`).
- **Command & Verdict (`DORMANT`, exit 1)**:
  ```text
  $ vigil policy check --max-dormancy 180 fixtures/vigil/package.json
  vigil policy check: FAILED (exit 1) — colors (561d), nom (573d), request (458d) > 180d
  ```
- **Rationale**: Mitigates software supply-chain takeovers from abandoned upstream dependencies.

### 3. Aegis — Post-Quantum Cryptography (PQC) Migration Gate

[![PQC](https://img.shields.io/badge/PQC-NON--COMPLIANT-red.svg)](https://studio2201.com/canary#aegis)

- **Deliberate Flaw**: `fixtures/aegis/legacy_crypto.rs` implements classical 1024-bit RSA and `secp256k1` ECDSA.
- **Command & Verdict (`NON-COMPLIANT`, exit 1)**:
  ```text
  $ aegis policy check fixtures/aegis/legacy_crypto.rs
  aegis policy check: FAILED (exit 1) — 4 RSA call sites, 6 classical ECC call sites
  ```
- **Rationale**: Enforces compliance with OMB M-26-15 and NIST FIPS 203/204 against retrospective decryption.

### 4. Proven — PQC-Signed Provenance & Tamper Verification

[![SLSA](https://img.shields.io/badge/SLSA-TAMPERED-red.svg)](https://studio2201.com/canary#proven)

- **Deliberate Flaw**: `fixtures/proven/canary_artifact` was modified by 1 byte post-attestation.
- **Command & Verdict (`TAMPERED`, exit 1)**:
  ```text
  $ proven verify fixtures/proven/canary_artifact --attestation fixtures/proven/attestation.json
  proven verification: FAILED (exit 1) — SHA-256 and Merkle root mismatch
  ```
- **Rationale**: Verifies binary and build-artifact supply-chain integrity against post-compilation tampering.

### 5. Boneyard — Org-Wide Technical Debt Radar

[![Boneyard](https://img.shields.io/badge/boneyard%20index-72%2F100-red.svg)](https://studio2201.com/canary#boneyard)

- **Deliberate Flaw**: `fixtures/boneyard/catalog.json` contains abandoned repos; scores 72.0 vs 50.0 max.
- **Command & Verdict (`DEBT BREACH`, exit 1)**:
  ```text
  $ boneyard policy check --policy fixtures/boneyard/policy.toml -i fixtures/boneyard/catalog.json
  boneyard policy check: FAILED (exit 1) — Average Boneyard Index 72.0 > 50.0 max
  ```
- **Rationale**: Architectural tech-debt governance preventing unmaintained services from accumulating rot.

## Governance & Standards

- **Line Count**: All repository files strictly adhere to $\le 256$ LOC.
- **Zero External Dependencies**: All studio2201 tools are built with pure `std::` Rust.
- **Security & Privacy**: No interactive authentication prompts or elevated privileges required.

## License

Apache-2.0. See [LICENSE](LICENSE) for details.
