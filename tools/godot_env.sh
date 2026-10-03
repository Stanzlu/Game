#!/usr/bin/env bash
# Shared, pinned toolchain settings for REAL. Source this file; do not execute it.
# Changing GODOT_VERSION is an architecture decision: update docs/DECISIONS.md (ADR-001).

GODOT_VERSION="4.7.2"
GODOT_FLAVOR="stable"
GODOT_TAG="${GODOT_VERSION}-${GODOT_FLAVOR}"
GODOT_RELEASE_URL="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}"

GODOT_ARCHIVE="Godot_v${GODOT_TAG}_linux.x86_64.zip"
GODOT_BIN_NAME="Godot_v${GODOT_TAG}_linux.x86_64"
GODOT_TEMPLATES_ARCHIVE="Godot_v${GODOT_TAG}_export_templates.tpz"

REAL_CACHE_DIR="${REAL_CACHE_DIR:-$HOME/.cache/real}"
GODOT_CACHE_DIR="${REAL_CACHE_DIR}/godot/${GODOT_TAG}"
# GODOT_BIN may be overridden (e.g. a local editor install on macOS or Windows/WSL).
GODOT_BIN="${GODOT_BIN:-${GODOT_CACHE_DIR}/${GODOT_BIN_NAME}}"
GODOT_TEMPLATES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${GODOT_VERSION}.${GODOT_FLAVOR}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
