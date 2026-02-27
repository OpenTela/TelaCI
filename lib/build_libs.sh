#!/bin/bash
# Build dependencies for EOS compiler tests
# ckdl: built from local source (lib/ckdl/src/)
# lua:  downloaded and built from lua.org
#
# Usage:
#   ./lib/build_libs.sh          # build all
#   ./lib/build_libs.sh lua      # build only Lua
#   ./lib/build_libs.sh ckdl     # build only ckdl
#   ./lib/build_libs.sh clean    # remove build artifacts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="${SCRIPT_DIR}/.build_tmp"
LUA_VERSION="5.4.7"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
info()  { echo -e "${GREEN}[OK]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

download() {
    local url="$1" dest="$2"
    if command -v curl &>/dev/null; then
        curl -sL "$url" -o "$dest"
    elif command -v wget &>/dev/null; then
        wget -q "$url" -O "$dest"
    else
        error "Neither curl nor wget found"; exit 1
    fi
}

# --- ckdl (from local source) ---
build_ckdl() {
    local dir="${SCRIPT_DIR}/ckdl"
    local lib="${dir}/build/libkdl.a"

    if [ -f "$lib" ]; then
        info "ckdl already built ($(du -h "$lib" | cut -f1)), use 'clean' to rebuild"
        return 0
    fi

    if [ ! -d "${dir}/src" ]; then
        error "ckdl source not found at ${dir}/src/"; exit 1
    fi

    info "Building ckdl from local source..."
    mkdir -p "${dir}/build"

    # C sources
    for f in "${dir}"/src/*.c; do
        gcc -c -fPIC -O2 -I "${dir}/include" -I "${dir}/src" "$f" \
            -o "${dir}/build/$(basename "${f%.c}.o")"
    done

    # C++ binding (needs C++20 for full kdlpp, compile what we can)
    if command -v g++ &>/dev/null; then
        g++ -c -fPIC -O2 -std=c++20 \
            -I "${dir}/include" -I "${dir}/bindings/cpp/include" \
            "${dir}/bindings/cpp/src/kdlpp.cpp" \
            -o "${dir}/build/kdlpp.o" 2>/dev/null && true
    fi

    ar rcs "$lib" "${dir}"/build/*.o
    rm -f "${dir}"/build/*.o

    info "ckdl → $(du -h "$lib" | cut -f1)"
}

# --- Lua 5.4 (download + build) ---
build_lua() {
    local dir="${SCRIPT_DIR}/lua54"
    local lib="${dir}/build/liblua54.a"

    if [ -f "$lib" ] && [ -f "${dir}/include/lua.h" ]; then
        info "Lua ${LUA_VERSION} already built ($(du -h "$lib" | cut -f1)), use 'clean' to rebuild"
        return 0
    fi

    info "Building Lua ${LUA_VERSION}..."
    mkdir -p "$TMP_DIR" "${dir}/include" "${dir}/build"

    # Download
    local tar="${TMP_DIR}/lua-${LUA_VERSION}.tar.gz"
    if [ ! -f "$tar" ]; then
        info "  Downloading from lua.org..."
        download "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" "$tar" || {
            error "Download failed. Install manually:"
            echo "  apt install liblua5.4-dev"
            echo "  cp /usr/include/lua5.4/*.h ${dir}/include/"
            echo "  cp /usr/lib/*/liblua5.4.a ${dir}/build/liblua54.a"
            exit 1
        }
    fi

    # Build
    cd "$TMP_DIR"
    rm -rf "lua-${LUA_VERSION}"
    tar xzf "$tar"
    cd "lua-${LUA_VERSION}"
    make -j"$(nproc)" posix MYCFLAGS="-fPIC" 2>&1 | tail -1

    # Install
    cp src/lua.h src/luaconf.h src/lauxlib.h src/lualib.h "${dir}/include/"
    cp src/liblua.a "${dir}/build/liblua54.a"
    rm -rf "${TMP_DIR}"

    info "Lua ${LUA_VERSION} → $(du -h "$lib" | cut -f1)"
}

# --- Clean ---
do_clean() {
    rm -rf "$TMP_DIR"
    rm -f "${SCRIPT_DIR}/ckdl/build/libkdl.a"
    rm -f "${SCRIPT_DIR}/lua54/build/liblua54.a"
    rm -f "${SCRIPT_DIR}/lua54/include/"*.h
    info "Cleaned. Run build_libs.sh to rebuild."
}

# --- Main ---
command -v gcc &>/dev/null || { error "gcc not found"; exit 1; }

case "${1:-all}" in
    ckdl)  build_ckdl ;;
    lua)   build_lua ;;
    clean) do_clean ;;
    all)   build_ckdl; build_lua; echo ""; info "All libraries ready." ;;
    *)     echo "Usage: $0 [ckdl|lua|clean|all]"; exit 1 ;;
esac
