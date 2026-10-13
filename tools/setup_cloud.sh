#!/usr/bin/env bash
# Install static-analysis tooling for Linux cloud sessions (Ubuntu 24.04).
# Idempotent. Never touches a serial port, radio or firmware input.
#
#   bash tools/setup_cloud.sh            # JDK 25, C-SKY binutils, Ghidra 12.1.4 + CSKY module
#   bash tools/setup_cloud.sh --with-gcc # also upstream GCC 13.3 for csky-elfabiv2 (~25 min)
#
# Tools land in /opt. Sources come from the Ubuntu archive (binutils, gcc-13),
# the official Ghidra GitHub release and the legacy CSKY module in analysis/ghidra_csky_module.
set -euo pipefail

PREFIX=/opt/csky-binutils
SRC=/opt/src
GHIDRA_VERSION=12.1.4
GHIDRA_DATE=20260921
GHIDRA_DIR=/opt/ghidra_${GHIDRA_VERSION}_PUBLIC
GHIDRA_ZIP_SHA256=ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db
REPO=$(cd "$(dirname "$0")/.." && pwd)
WITH_GCC=0
for arg in "$@"; do
    case $arg in
        --with-gcc) WITH_GCC=1 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done
JOBS=$(nproc)
export DEBIAN_FRONTEND=noninteractive

log() { printf '\n== %s\n' "$*"; }

log "Ubuntu packages"
if ! grep -q '^Types: deb deb-src' /etc/apt/sources.list.d/ubuntu.sources; then
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
fi
apt-get update -qq
apt-get install -y -qq openjdk-25-jdk-headless build-essential texinfo bison flex \
    libgmp-dev libmpfr-dev libmpc-dev zstd xxd unzip >/dev/null
pip install -q pyelftools 2>/dev/null || true
JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64

mkdir -p "$SRC"

if [ ! -x "$PREFIX/bin/csky-elfabiv2-objdump" ]; then
    log "C-SKY binutils from Ubuntu binutils source"
    (cd "$SRC" && apt-get source -qq binutils >/dev/null 2>&1)
    BINUTILS_SRC=$(find "$SRC" -maxdepth 1 -type d -name 'binutils-2.*' | head -1)
    mkdir -p "$SRC/binutils-build"
    (cd "$SRC/binutils-build" &&
        "$BINUTILS_SRC/configure" --target=csky-elfabiv2 --prefix="$PREFIX" \
            --disable-nls --disable-werror --disable-gdb --disable-sim --disable-gprofng >/dev/null &&
        make -j"$JOBS" >/dev/null && make install >/dev/null)
fi

if [ "$WITH_GCC" = 1 ] && [ ! -x "$PREFIX/bin/csky-elfabiv2-gcc" ]; then
    log "Upstream GCC 13 for csky-elfabiv2 (not the pinned T-HEAD 6.3.0 build)"
    (cd "$SRC" && apt-get source -qq --download-only gcc-13 >/dev/null 2>&1)
    ORIG=$(find "$SRC" -maxdepth 1 -name 'gcc-13_*.orig.tar.gz' | head -1)
    INNER=$(tar tzf "$ORIG" | grep -m1 '/gcc-13\.[0-9.]*\.tar\.xz$')
    tar xzf "$ORIG" -C "$SRC" "$INNER"
    tar xJf "$SRC/$INNER" -C "$SRC"
    GCC_SRC=$(find "$SRC" -maxdepth 1 -type d -name 'gcc-13.*' | head -1)
    mkdir -p "$SRC/gcc-build"
    (cd "$SRC/gcc-build" && export PATH="$PREFIX/bin:$PATH" &&
        "$GCC_SRC/configure" --target=csky-elfabiv2 --prefix="$PREFIX" \
            --with-as="$PREFIX/bin/csky-elfabiv2-as" --with-ld="$PREFIX/bin/csky-elfabiv2-ld" \
            --enable-languages=c --without-headers --with-newlib --disable-nls --disable-shared \
            --disable-threads --disable-libssp --disable-libquadmath --disable-libgomp \
            --disable-multilib --with-cpu=ck803 >/dev/null &&
        make -j"$JOBS" all-gcc >/dev/null && make install-gcc >/dev/null &&
        make -j"$JOBS" all-target-libgcc >/dev/null && make install-target-libgcc >/dev/null)
fi

if [ ! -x "$GHIDRA_DIR/support/analyzeHeadless" ]; then
    log "Ghidra $GHIDRA_VERSION"
    ZIP="$SRC/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip"
    curl -sS -L -o "$ZIP" \
        "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip"
    echo "$GHIDRA_ZIP_SHA256  $ZIP" | sha256sum -c -
    unzip -q "$ZIP" -d /opt
    rm -f "$ZIP"
fi

CSKY_DIR="$GHIDRA_DIR/Ghidra/Processors/CSKY"
MODULE="$REPO/analysis/ghidra_csky_module"
FIXED_SINC="$REPO/analysis/ghidra_scripts/32b_data.fixed.sinc"
if [ ! -f "$CSKY_DIR/data/languages/csky_v2.sla" ] ||
   ! cmp -s "$FIXED_SINC" "$CSKY_DIR/data/languages/32b_data.sinc" ||
   ! diff -rq -x 32b_data.sinc -x '*.sla' "$MODULE/data" "$CSKY_DIR/data" >/dev/null; then
    log "Ghidra CSKY module (legacy v0.2) + DM32 32b_data.sinc fix"
    rm -rf "$CSKY_DIR"
    mkdir -p "$CSKY_DIR"
    cp -r "$MODULE/data" "$MODULE/Module.manifest" "$CSKY_DIR/"
    cp "$FIXED_SINC" "$CSKY_DIR/data/languages/32b_data.sinc"
    JAVA_HOME=$JAVA_HOME PATH="$JAVA_HOME/bin:$PATH" \
        "$GHIDRA_DIR/support/sleigh" -a "$CSKY_DIR/data/languages" >/dev/null
fi

log "Environment file /opt/dm32-tools.env"
cat > /opt/dm32-tools.env <<EOF
export JAVA_HOME=$JAVA_HOME
export GHIDRA_INSTALL_DIR=$GHIDRA_DIR
export PATH=$PREFIX/bin:$GHIDRA_DIR/support:\$JAVA_HOME/bin:\$PATH
EOF

log "Summary"
"$PREFIX/bin/csky-elfabiv2-objdump" --version | head -1
if [ -x "$PREFIX/bin/csky-elfabiv2-gcc" ]; then "$PREFIX/bin/csky-elfabiv2-gcc" --version | head -1; fi
"$JAVA_HOME/bin/java" -version 2>&1 | grep -v JAVA_TOOL_OPTIONS | head -1
echo "Ghidra: $GHIDRA_DIR (language CSKY_V2:LE:32:default)"
echo "Load with: source /opt/dm32-tools.env"
