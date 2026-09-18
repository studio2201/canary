# Canary (`studio2201/canary`)

> Reference failure repository providing deliberate, realistic triggers across all studio2201 tools.

Canary is an intentionally broken reference repository engineered for **negative testing**, continuous integration gating, and live technical demonstration of the [studio2201](https://studio2201.com) developer tools suite: **Snip**, **Vigil**, **Aegis**, **Proven**, and **Boneyard**.

---

## Negative Testing Philosophy

In software security, verifying that clean code passes is only half the battle. A security linter or supply-chain gate that never fails is indistinguishable from a no-op.

Negative testing validates that defensive gates reliably detect and intercept real-world violations:
- **Authentic Fixtures**: Flaws are modeled directly on common production mistakes—live secret patterns, unpatched supply-chain dependencies, post-quantum policy violations, corrupted build attestations, and runaway technical debt.
- **Fail-Closed Verification**: Every tool in the suite must flag its respective defect, emit clear remediation diagnostics, and exit with code `1`.
- **Inverted CI Success**: In automated CI, a green build indicates that all five negative tests successfully caught their deliberate defects.

---

## Single-Command Demo (`demo.sh`)

Canary provides `./demo.sh` to execute the full negative verification suite in a single terminal command:

```bash
./demo.sh
```

### Script Execution & Discovery
`demo.sh` automatically locates compiled binaries via `STUDIO2201_BIN_DIR`, sibling workspaces (`../studio2201/*/target/release`), `~/.local/bin`, or `$PATH`. It evaluates each tool against its fixture, asserts exit code `1`, and displays a 76-column colorized scorecard:

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
Canary negative verification succeeded.
```

The script supports `NO_COLOR=1` and detects non-interactive pipes to ensure clean scriptability in automation.

---

## Tool Failure Breakdowns

### 1. Snip — Vibe-Code Secret & SQL Safety Gate

- **Deliberate Flaw**:
  - `fixtures/snip/api_keys.ts`: Contains hardcoded Stripe live secrets (`sk_live_...`) and Anthropic API keys (`sk-ant-...`).
  - `fixtures/snip/migrations/001_create_accounts.sql`: Creates a sensitive database table without enabling PostgreSQL Row Level Security (`CREATE TABLE accounts (...)` omitting `ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;`).
  - `fixtures/snip/staged.patch`: Unified git diff staging both violations.
- **Inspection Command**:
  ```bash
  snip audit fixtures/snip/staged.patch
  ```
- **Terminal Failure Output (`BLOCK`, exit 1)**:
  ```text
  snip verdict: BLOCK
  findings: 3
    [CRITICAL] fixtures/snip/api_keys.ts:12 — Hardcoded Stripe Production Secret Key
    [CRITICAL] fixtures/snip/api_keys.ts:13 — Hardcoded OpenAI / LLM API Key
    [HIGH] fixtures/snip/migrations/001_create_accounts.sql:1 — Table created in SQL migration without enabling Row Level Security
    blocked: Critical finding threshold exceeded: 2 detected (max 0)
    blocked: High severity finding threshold exceeded: 1 detected (max 0)
  ```
- **Rationale**: Prevents accidental leakage of live payment credentials and API keys in commit history. Enforces strict multi-tenant isolation by blocking un-RLS database migrations.

---

### 2. Vigil — Supply-Chain Dependency Dormancy Scanner

- **Deliberate Flaw**:
  - `fixtures/vigil/package.json`: References historically abandoned npm packages (`colors` at 561 days dormant, `nom` at 573 days, `request` at 458 days), breaching the 180-day dormancy ceiling.
- **Inspection Command**:
  ```bash
  vigil policy check --max-dormancy 180 fixtures/vigil/package.json
  ```
- **Terminal Failure Output (`DORMANT`, exit 1)**:
  ```text
  vigil policy check: FAILED
    - Critical dependencies count 3 exceeds threshold 0
    - Average risk score 98.4 exceeds threshold 45.0
    - Dependency 'colors' (561 days dormant) exceeds max dormancy of 180 days
    - Dependency 'nom' (573 days dormant) exceeds max dormancy of 180 days
    - Dependency 'request' (458 days dormant) exceeds max dormancy of 180 days
  ```
- **Rationale**: Mitigates software supply-chain takeovers. Long-abandoned upstream dependencies harbor unpatched vulnerabilities and are frequent targets of malicious maintainer transfers.

---

### 3. Aegis — Post-Quantum Cryptography (PQC) Migration Gate

- **Deliberate Flaw**:
  - `fixtures/aegis/legacy_crypto.rs`: Implements classical 1024-bit RSA key generation and encryption (`RSA_generate_key(1024, ...)`, `RSA_public_encrypt`) alongside classical `secp256k1` ECDSA signatures (`ECDSA_sign`, `ES256`).
- **Inspection Command**:
  ```bash
  aegis policy check fixtures/aegis/legacy_crypto.rs
  ```
- **Terminal Failure Output (`NON-COMPLIANT`, exit 1)**:
  ```text
  aegis policy check: FAILED
    - Policy strictly prohibits RSA past 2030 (found 4 call sites)
    - Policy prohibits classical ECC algorithms without PQC encapsulation (found 6 call sites)
    - Total legacy cryptographic sites 10 exceeds policy cap 0
  ```
- **Rationale**: Enforces compliance with OMB M-26-15 and NIST FIPS 203/204 mandates. Cryptanalytically relevant quantum computers (CRQCs) threaten classical public-key cryptography via "harvest now, decrypt later" attacks.

---

### 4. Proven — PQC-Signed Provenance & Tamper Verification

- **Deliberate Flaw**:
  - `fixtures/proven/canary_artifact`: Payload signed with ML-DSA-65 into SLSA L3+ provenance predicate `fixtures/proven/attestation.json`.
  - The payload was modified by 1 byte post-attestation (`rc1` altered to `rc2`), producing a digest and Merkle root mismatch.
- **Inspection Command**:
  ```bash
  proven verify fixtures/proven/canary_artifact --attestation fixtures/proven/attestation.json
  ```
- **Terminal Failure Output (`TAMPERED`, exit 1)**:
  ```text
  proven verification: FAILED
    ✗ SHA-256 mismatch! Artifact=6ea18a..., Attestation=ebbaec...
    ✗ Merkle root mismatch! Re-derived=6ea18a..., Attestation=ebbaec...
  ```
- **Rationale**: Verifies binary and build-artifact supply-chain integrity. Disallows execution or deployment of any artifact that diverges from its cryptographically attested provenance.

---

### 5. Boneyard — Org-Wide Technical Debt Radar

- **Deliberate Flaw**:
  - `fixtures/boneyard/catalog.json`: Service catalog containing abandoned repositories with 1,200 days dormancy, 95% unreviewed bot commits, and zero active maintainers.
  - `fixtures/boneyard/policy.toml`: Enforces org ceilings of `max_avg_boneyard_index = 50.0` and `max_critical_repos = 0`. Canary's catalog scores 72.0 with 2 critical repositories.
- **Inspection Command**:
  ```bash
  boneyard policy check --policy fixtures/boneyard/policy.toml -i fixtures/boneyard/catalog.json
  ```
- **Terminal Failure Output (`DEBT BREACH`, exit 1)**:
  ```text
  boneyard policy check: FAILED
    - Org average Boneyard Index 72.0 exceeds maximum allowed 50.0
    - Critical repository count 2 exceeds threshold 0
  ```
- **Rationale**: Architectural tech-debt governance. Prevents accumulation of unmaintained "zombie" services and unpinned dependencies that degrade engineering velocity and create security blindspots.

---

## Continuous Integration (`.github/workflows/canary.yml`)

Canary runs automated negative regression gating on GitHub Actions for pushes and pull requests to `master`:

1. **Doctrine Check**: Validates the studio2201 governance rule that all files remain $\le 256$ lines of code.
2. **Suite Installation**: Fetches and installs the latest studio2201 binaries via:
   ```bash
   curl -fsSL https://studio2201.com/install.sh | sh -s all
   ```
3. **Negative Testbed Execution**: Executes `./demo.sh`, ensuring all 5 tools correctly reject their deliberate fixtures with exit code `1`.
4. **CI Assertion**: The workflow passes (`exit 0`) if and only if all negative assertions are satisfied.

---

## Governance & Standards

- **Line Count**: All repository files strictly adhere to $\le 256$ LOC.
- **Zero External Dependencies**: All studio2201 tools are built with pure `std::` Rust.
- **Security & Privacy**: No interactive authentication prompts or elevated privileges required.

## License

Apache-2.0. See [LICENSE](LICENSE) for details.
