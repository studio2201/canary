# Canary (`studio2201/canary`)

[![studio2201 Suite](https://img.shields.io/badge/studio2201-5%2F5%20Verified-2f6f5e?logo=shield)](https://studio2201.com/agents#badges)
[![Release](https://img.shields.io/badge/version-v0.1.3-blue.svg)](https://github.com/studio2201/canary/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

> Reference failure repository providing deliberate, realistic triggers across all studio2201 tools.

Canary is an intentionally broken reference repository engineered for **negative testing**, continuous integration gating, and live technical demonstration of the [studio2201](https://studio2201.com) developer tools suite: **Snip**, **Vigil**, **Aegis**, **Proven**, and **Boneyard**.

## Deliberate Failure Matrix

| Product | Focus | Failure Badge | Expected Verdict | Fixture Target | Exit Code |
| :--- | :--- | :--- | :---: | :--- | :---: |
| [**Snip**](https://studio2201.com/snip) | Vibe-code security gate | [![Vibe-Safe](https://img.shields.io/badge/vibe--safe-BLOCK-red.svg)](https://studio2201.com/canary#snip) | `BLOCK` | `fixtures/snip/staged.patch` | `1` |
| [**Vigil**](https://studio2201.com/vigil) | Supply-chain dormancy scanner | [![Dormancy](https://img.shields.io/badge/dormancy-CRITICAL-red.svg)](https://studio2201.com/canary#vigil) | `DORMANT` | `fixtures/vigil/package.json` | `1` |
| [**Aegis**](https://studio2201.com/aegis) | PQC migration SDK & scanner | [![PQC](https://img.shields.io/badge/PQC-NON--COMPLIANT-red.svg)](https://studio2201.com/canary#aegis) | `NON-COMPLIANT` | `fixtures/aegis/legacy_crypto.rs` | `1` |
| [**Proven**](https://studio2201.com/proven) | PQC-signed supply-chain attestor | [![SLSA](https://img.shields.io/badge/SLSA-TAMPERED-red.svg)](https://studio2201.com/canary#proven) | `TAMPERED` | `fixtures/proven/canary_artifact` | `1` |
| [**Boneyard**](https://studio2201.com/boneyard) | Org-wide tech-debt radar | [![Boneyard](https://img.shields.io/badge/boneyard%20index-72%2F100-red.svg)](https://studio2201.com/canary#boneyard) | `DEBT BREACH` | `fixtures/boneyard/catalog.json` | `1` |

---

## Why Negative CI Verification Is Critical

In software security, verifying that clean code passes is only half the battle. A security linter or supply-chain gate that never fails in CI provides false confidence and is indistinguishable from a no-op.

Negative testing validates that defensive gates reliably detect and intercept real-world violations:
- **Authentic Fixtures**: Flaws are modeled directly on common production mistakes—live secret leaks (GitGuardian), unpatched supply-chain dependencies (CVE-2024-3094, `colors.js`), post-quantum policy violations (OMB M-26-15), corrupted build attestations (SolarWinds), and runaway technical debt.
- **Fail-Closed Verification**: Every tool in the suite must flag its respective defect, emit actionable remediation diagnostics, and exit with code `1`.
- **Automated Gates Beat Manual Discipline**: Developers rarely run negative sanity tests manually. Loading Canary checks into automated CI guarantees that gates never degrade into silent passes.

---

## Autonomous Agent Integration

Deploy Canary negative verification into CI using an AI coding assistant or copy the workflow below.

### Prompt for your AI Agent

Copy and paste this prompt to Cursor, Claude Code, Copilot Workspace, or Devin:

```text
Add a GitHub Actions workflow to this repository at .github/workflows/canary.yml that executes the Canary negative testbed (./demo.sh) on every push and pull request. The workflow must assert that all 5 studio2201 security tools correctly intercept their deliberate failure fixtures and exit with code 1, verifying fail-closed enforcement.
```

### GitHub Actions Workflow

Commit this workflow at `.github/workflows/canary.yml`:

```yaml
name: Canary Failure Testbed
on:
  push:
    branches: [ master, main ]
  pull_request:
    branches: [ master, main ]
permissions:
  contents: read
jobs:
  canary:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run studio2201 Suite Gate
        uses: studio2201/studio2201@master
        with:
          tools: 'all'
          fail-on: 'block'
        continue-on-error: true
      - name: Execute Canary Verification
        run: |
          curl -fsSL https://studio2201.com/install.sh | sh -s all
          ./demo.sh
```

---

## Single-Command Demo (`demo.sh`)

Canary provides `./demo.sh` to execute the full negative verification suite in a single terminal command:

```bash
./demo.sh
```

### Script Execution & Discovery
`demo.sh` automatically locates compiled binaries via `STUDIO2201_BIN_DIR`, sibling workspaces, `~/.local/bin`, or `$PATH`. It evaluates each tool against its fixture, asserts exit code `1`, and displays a concise verification scorecard:

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

---

## Tool Failure Breakdowns

### 1. Snip — Vibe-Code Secret & SQL Safety Gate

[![Vibe-Safe](https://img.shields.io/badge/vibe--safe-BLOCK-red.svg)](https://studio2201.com/canary#snip)

- **Deliberate Flaw**:
  - `fixtures/snip/api_keys.ts`: Contains hardcoded Stripe live secrets (`sk_live_...`) and Anthropic API keys (`sk-ant-...`).
  - `fixtures/snip/migrations/001_create_accounts.sql`: Creates a sensitive database table without enabling PostgreSQL Row Level Security.
  - `fixtures/snip/staged.patch`: Unified git diff staging both violations.
- **Inspection Command**:
  ```bash
  snip audit fixtures/snip/staged.patch
  ```
- **Terminal Failure Output (`BLOCK`, exit 1)**:
  ```text
  snip verdict: BLOCK (exit code 1)
  findings: 2 CRITICAL secrets (Stripe/OpenAI), 1 HIGH migration (missing RLS)
  ```
- **Rationale**: Prevents accidental leakage of live payment credentials and API keys in commit history. Enforces strict multi-tenant isolation by blocking un-RLS database migrations.

---

### 2. Vigil — Supply-Chain Dependency Dormancy Scanner

[![Dormancy](https://img.shields.io/badge/dormancy-CRITICAL-red.svg)](https://studio2201.com/canary#vigil)

- **Deliberate Flaw**:
  - `fixtures/vigil/package.json`: References historically abandoned npm packages (`colors` at 561 days dormant, `nom` at 573 days, `request` at 458 days), breaching the 180-day dormancy ceiling.
- **Inspection Command**:
  ```bash
  vigil policy check --max-dormancy 180 fixtures/vigil/package.json
  ```
- **Terminal Failure Output (`DORMANT`, exit 1)**:
  ```text
  vigil policy check: FAILED (exit code 1)
  Critical dependencies: colors (561d), nom (573d), request (458d) > 180d
  ```
- **Rationale**: Mitigates software supply-chain takeovers. Long-abandoned upstream dependencies harbor unpatched vulnerabilities and are frequent targets of malicious maintainer transfers.

---

### 3. Aegis — Post-Quantum Cryptography (PQC) Migration Gate

[![PQC](https://img.shields.io/badge/PQC-NON--COMPLIANT-red.svg)](https://studio2201.com/canary#aegis)

- **Deliberate Flaw**:
  - `fixtures/aegis/legacy_crypto.rs`: Implements classical 1024-bit RSA key generation and encryption alongside classical `secp256k1` ECDSA signatures.
- **Inspection Command**:
  ```bash
  aegis policy check fixtures/aegis/legacy_crypto.rs
  ```
- **Terminal Failure Output (`NON-COMPLIANT`, exit 1)**:
  ```text
  aegis policy check: FAILED (exit code 1)
  Legacy sites: 4 RSA call sites, 6 classical ECC call sites (exceeds cap 0)
  ```
- **Rationale**: Enforces compliance with OMB M-26-15 and NIST FIPS 203/204 mandates against "harvest now, decrypt later" attacks.

---

### 4. Proven — PQC-Signed Provenance & Tamper Verification

[![SLSA](https://img.shields.io/badge/SLSA-TAMPERED-red.svg)](https://studio2201.com/canary#proven)

- **Deliberate Flaw**:
  - `fixtures/proven/canary_artifact`: Payload signed with ML-DSA-65 into SLSA L3+ provenance predicate `fixtures/proven/attestation.json`.
  - The payload was modified by 1 byte post-attestation (`rc1` altered to `rc2`), producing a digest and Merkle root mismatch.
- **Inspection Command**:
  ```bash
  proven verify fixtures/proven/canary_artifact --attestation fixtures/proven/attestation.json
  ```
- **Terminal Failure Output (`TAMPERED`, exit 1)**:
  ```text
  proven verification: FAILED (exit code 1)
  ✗ SHA-256 and Merkle root mismatch against ML-DSA-65 attestation
  ```
- **Rationale**: Verifies binary and build-artifact supply-chain integrity. Disallows execution or deployment of any artifact that diverges from its cryptographically attested provenance.

---

### 5. Boneyard — Org-Wide Technical Debt Radar

[![Boneyard](https://img.shields.io/badge/boneyard%20index-72%2F100-red.svg)](https://studio2201.com/canary#boneyard)

- **Deliberate Flaw**:
  - `fixtures/boneyard/catalog.json`: Service catalog containing abandoned repositories with 1,200 days dormancy, 95% unreviewed bot commits, and zero active maintainers.
  - `fixtures/boneyard/policy.toml`: Enforces org ceilings of `max_avg_boneyard_index = 50.0` and `max_critical_repos = 0`. Canary's catalog scores 72.0 with 2 critical repositories.
- **Inspection Command**:
  ```bash
  boneyard policy check --policy fixtures/boneyard/policy.toml -i fixtures/boneyard/catalog.json
  ```
- **Terminal Failure Output (`DEBT BREACH`, exit 1)**:
  ```text
  boneyard policy check: FAILED (exit code 1)
  Average Boneyard Index 72.0 > max 50.0 | 2 critical repositories > 0
  ```
- **Rationale**: Architectural tech-debt governance. Prevents accumulation of unmaintained services that degrade engineering velocity and create security blindspots.

---

## Governance & Standards

- **Line Count**: All repository files strictly adhere to $\le 256$ LOC.
- **Zero External Dependencies**: All studio2201 tools are built with pure `std::` Rust.
- **Security & Privacy**: No interactive authentication prompts or elevated privileges required.

## License

Apache-2.0. See [LICENSE](LICENSE) for details.
