#!/bin/bash
# merge-pkgbuild.sh - Apply custom CachyOS settings to a fresh PKGBUILD
#
# Overlays your personal preferences from old-pkg onto a new upstream PKGBUILD.
# Leaves version numbers, sources, and checksums untouched.
#
# Usage: ./merge-pkgbuild.sh [path/to/PKGBUILD]
#   (defaults to ./PKGBUILD if no argument given)

set -euo pipefail

PKGBUILD="${1:-PKGBUILD}"
[ -f "$PKGBUILD" ] || { echo "Usage: $0 [path/to/PKGBUILD]"; exit 1; }

echo "Merging custom settings into $PKGBUILD..."

# ────────────────────────────────────────────
# Step 1: Override variable defaults
# ────────────────────────────────────────────
sed -i \
    -e 's/^: "${_localmodcfg:=no}"$/: "${_localmodcfg:=yes}"/' \
    -e 's/^: "${_per_gov:=no}"$/: "${_per_gov:=yes}"/' \
    -e 's/^: "${_tcp_bbr3:=no}"$/: "${_tcp_bbr3:=yes}"/' \
    -e 's/^: "${_processor_opt:=}"$/: "${_processor_opt:=native}"/' \
    -e 's/^: "${_use_llvm_lto:=none}"$/: "${_use_llvm_lto:=thin}"/' \
    -e 's/^: "${_build_r8125:=no}"$/: "${_build_r8125:=yes}"/' \
    "$PKGBUILD"

# ────────────────────────────────────────────
# Step 2: Inject _mitigations variable and the
#         mitigations-disable block in prepare()
# ────────────────────────────────────────────
ed -s "$PKGBUILD" <<'BLOCK'
/^### Enable TCP_CONG_BBR3$/i
### Disable CPU vulnerability mitigations (performance over security)
: "${_mitigations:=no}"

.
/^    ### Optionally use running kernel/i
    ### Disable CPU mitigations
    if [ "$_mitigations" = "no" ]; then
        echo "Disabling CPU vulnerability mitigations..."
        scripts/config \
            -d MITIGATION_PAGE_TABLE_ISOLATION \
            -d MITIGATION_RETPOLINE \
            -d MITIGATION_RETHUNK \
            -d MITIGATION_UNRET_ENTRY \
            -d MITIGATION_CALL_DEPTH_TRACKING \
            -d MITIGATION_IBPB_ENTRY \
            -d MITIGATION_IBRS_ENTRY \
            -d MITIGATION_SRSO \
            -d MITIGATION_SLS \
            -d MITIGATION_GDS \
            -d MITIGATION_RFDS \
            -d MITIGATION_SPECTRE_BHI \
            -d MITIGATION_MDS \
            -d MITIGATION_TAA \
            -d MITIGATION_MMIO_STALE_DATA \
            -d MITIGATION_L1TF \
            -d MITIGATION_RETBLEED \
            -d MITIGATION_SPECTRE_V1 \
            -d MITIGATION_SPECTRE_V2 \
            -d MITIGATION_SRBDS \
            -d MITIGATION_SSB \
            -d MITIGATION_ITS \
            -d MITIGATION_TSA \
            -d MITIGATION_VMSCAPE
    fi

.
w
q
BLOCK

echo "Done! Custom settings merged into $PKGBUILD"
