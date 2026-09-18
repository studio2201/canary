#!/usr/bin/env bash
# ==============================================================================
# studio2201 Canary Reference Testbed — Terminal Demonstration Script
# Asserts intentional failure triggers across all 5 studio2201 tools.
# Doctrine: Pure bash, <= 256 LOC, fail-closed negative verification.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Terminal Styling & Color Detection (NO_COLOR standard)
if [ -n "${CLICOLOR_FORCE:-}" ] && [ "${CLICOLOR_FORCE}" != "0" ]; then
    COLOR=1
elif [ -z "${NO_COLOR:-}" ] && [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    COLOR=1
else
    COLOR=0
fi

if [ "$COLOR" -eq 1 ]; then
    BOLD="\033[1m"
    DIM="\033[2m"
    RED="\033[1;31m"
    GREEN="\033[1;32m"
    CYAN="\033[1;36m"
    RESET="\033[0m"
else
    BOLD=""
    DIM=""
    RED=""
    GREEN=""
    CYAN=""
    RESET=""
fi

# 2. Binary Discovery Hierarchy (5-Tier)
resolve_binary() {
    local tool="$1"
    # Tier 1: STUDIO2201_BIN_DIR override
    if [ -n "${STUDIO2201_BIN_DIR:-}" ] && \
       [ -x "${STUDIO2201_BIN_DIR}/${tool}" ]; then
        echo "${STUDIO2201_BIN_DIR}/${tool}"
        return 0
    fi
    # Tier 2: Sibling directory release build
    local rel_build
    rel_build="${SCRIPT_DIR}/../studio2201/${tool}/target/release/${tool}"
    if [ -x "$rel_build" ]; then
        echo "$rel_build"
        return 0
    fi
    # Tier 3: Absolute local repo release build fallback
    local abs_build
    abs_build="/home/jeryd/Projects/studio2201/${tool}/target/release/${tool}"
    if [ -x "$abs_build" ]; then
        echo "$abs_build"
        return 0
    fi
    # Tier 4: User local bin directory (~/.local/bin)
    local user_bin="${XDG_BIN_HOME:-$HOME/.local/bin}/${tool}"
    if [ -x "$user_bin" ]; then
        echo "$user_bin"
        return 0
    fi
    # Tier 5: System PATH lookup
    if command -v "$tool" >/dev/null 2>&1; then
        command -v "$tool"
        return 0
    fi
    return 1
}

# 3. Pre-Flight Checks
TOOLS=(snip vigil aegis proven boneyard)
declare -A BIN_PATHS

missing_tools=0
for t in "${TOOLS[@]}"; do
    if path="$(resolve_binary "$t")"; then
        BIN_PATHS["$t"]="$path"
    else
        echo -e "${RED}Error:${RESET} Binary '$t' not found." >&2
        missing_tools=$((missing_tools + 1))
    fi
done

if [ "$missing_tools" -gt 0 ]; then
    echo "Install via studio2201.com/install.sh or build via cargo." >&2
    exit 1
fi

FIXTURES=(
    "fixtures/snip/staged.patch"
    "fixtures/vigil/package.json"
    "fixtures/aegis/legacy_crypto.rs"
    "fixtures/proven/canary_artifact"
    "fixtures/proven/attestation.json"
    "fixtures/boneyard/policy.toml"
    "fixtures/boneyard/catalog.json"
)

for f in "${FIXTURES[@]}"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}Error:${RESET} Missing required fixture: $f" >&2
        exit 1
    fi
done

# 4. Banner & Discovered Tools Report
SEP="============================================================================"
DIV="----------------------------------------------------------------------------"
echo "$SEP"
echo -e \
    "${BOLD}${CYAN} studio2201 Canary Reference Testbed — Negative Verification Suite${RESET}"
echo "$SEP"
echo "Discovered Binaries:"
for t in "${TOOLS[@]}"; do
    bin="${BIN_PATHS[$t]}"
    ver="$("$bin" --version 2>&1 | head -n 1)"
    printf "  %-8s -> %-42s %s\n" "$t" "$bin" "(${ver})"
done
echo ""

# 5. Check Execution Engine
SCORECARD=()
ALL_PASSED=1

run_check() {
    local idx="$1"
    local tool="$2"
    local target="$3"
    local expected_verdict="$4"
    shift 4
    local cmd=("$@")

    echo -e "${BOLD}[${idx}/5] ${tool}${RESET}: ${cmd[*]}"
    echo "$DIV"

    set +e
    local output
    output="$("${cmd[@]}" 2>&1)"
    local actual_ec=$?
    set -e

    echo "$output"
    echo "$DIV"

    local status="FAIL"
    local status_disp="${RED}FAIL${RESET}"
    if [ "$actual_ec" -eq 1 ]; then
        status="PASS"
        status_disp="${GREEN}PASS${RESET}"
    else
        ALL_PASSED=0
    fi

    echo -e "Exit Code: ${BOLD}${actual_ec}${RESET} (expected 1) | \
Verdict: ${BOLD}${RED}${expected_verdict}${RESET} | Result: ${status_disp}"
    echo ""

    SCORECARD+=(\
        "${tool}|${target}|1|${actual_ec}|${expected_verdict}|${status}")
}

# 6. Execute 5 Negative Checks
run_check 1 "snip" "snip/staged.patch" "BLOCK" \
    "${BIN_PATHS[snip]}" audit fixtures/snip/staged.patch

run_check 2 "vigil" "vigil/package.json" "DORMANT" \
    "${BIN_PATHS[vigil]}" policy check --max-dormancy 180 \
    fixtures/vigil/package.json

run_check 3 "aegis" "aegis/legacy_crypto.rs" "NON-COMPLIANT" \
    "${BIN_PATHS[aegis]}" policy check fixtures/aegis/legacy_crypto.rs

run_check 4 "proven" "proven/canary_artifact" "TAMPERED" \
    "${BIN_PATHS[proven]}" verify fixtures/proven/canary_artifact \
    --attestation fixtures/proven/attestation.json

run_check 5 "boneyard" "boneyard/catalog.json" "DEBT BREACH" \
    "${BIN_PATHS[boneyard]}" policy check \
    --policy fixtures/boneyard/policy.toml \
    -i fixtures/boneyard/catalog.json

# 7. Scorecard Summary Table (76 Columns)
TABLE_SEP="+----------+--------------------------+-----+-----+---------------+--------+"
echo "$SEP"
echo -e "${BOLD}${CYAN} Canary Failure Verification Scorecard${RESET}"
echo "$SEP"
echo "$TABLE_SEP"
printf "| %-8s | %-24s | %-3s | %-3s | %-13s | %-6s |\n" \
    "Tool" "Target" "Exp" "Act" "Verdict" "Status"
echo "$TABLE_SEP"

for row in "${SCORECARD[@]}"; do
    IFS="|" read -r r_tool r_target r_exp r_act r_verdict r_status <<< "$row"
    if [ "$r_status" = "PASS" ]; then
        disp_st="${GREEN}%-4s${RESET}"
    else
        disp_st="${RED}%-4s${RESET}"
    fi
    printf \
        "| %-8s | %-24s |  %s  |  %s  | ${RED}%-13s${RESET} |  ${disp_st}  |\n" \
        "$r_tool" "$r_target" "$r_exp" "$r_act" "$r_verdict" "$r_status"
done
echo "$TABLE_SEP"
echo ""

if [ "$ALL_PASSED" -eq 1 ]; then
    echo -e "${GREEN}${BOLD}✓ ALL 5 CHECKS PASSED:${RESET} \
All tools failed with exit code 1 as expected."
    echo -e "${DIM}Canary negative verification succeeded.${RESET}\n"
    exit 0
else
    echo -e "${RED}${BOLD}✗ VERIFICATION FAILED:${RESET} \
One or more tools did not return exit code 1." >&2
    exit 1
fi
