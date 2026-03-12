#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  update-skill.sh [repo_url] [branch] [skill_name] [source_subdir] [target_dir]

Args:
  repo_url      Public git repository URL (default: https://github.com/onektrading/agent-skills)
  branch        Git branch (default: main)
  skill_name    Skill folder name (default: 1keeper)
  source_subdir Path inside repo to the skill (default: skills/<skill_name>)
  target_dir    OpenClaw skill target directory (default: ~/.openclaw/skills/<skill_name>)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

REPO_URL="${1:-https://github.com/onektrading/agent-skills}"
BRANCH="${2:-main}"
SKILL_NAME="${3:-1keeper}"
SOURCE_SUBDIR="${4:-skills/${SKILL_NAME}}"
TARGET_DIR="${5:-${HOME}/.openclaw/skills/${SKILL_NAME}}"
WORK_ROOT="${HOME}/.openclaw/.skill-updater"
CLONE_DIR="${WORK_ROOT}/${SKILL_NAME}-repo"
STAMP_FILE="${WORK_ROOT}/${SKILL_NAME}.last_update"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is required but not found in PATH." >&2
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "ERROR: rsync is required but not found in PATH." >&2
  exit 3
fi

mkdir -p "${WORK_ROOT}"

if [[ -d "${CLONE_DIR}/.git" ]]; then
  git -C "${CLONE_DIR}" fetch --depth=1 origin "${BRANCH}"
  git -C "${CLONE_DIR}" checkout -q "${BRANCH}"
  git -C "${CLONE_DIR}" reset --hard "origin/${BRANCH}"
else
  git clone --depth=1 --branch "${BRANCH}" "${REPO_URL}" "${CLONE_DIR}"
fi

SOURCE_DIR="${CLONE_DIR}/${SOURCE_SUBDIR}"
if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source skill directory not found: ${SOURCE_DIR}" >&2
  exit 4
fi

mkdir -p "${TARGET_DIR}"
rsync -a --delete "${SOURCE_DIR}/" "${TARGET_DIR}/"

UPDATED_AT="$(date '+%Y-%m-%d %H:%M:%S %z')"
printf '%s\nrepo=%s\nbranch=%s\nsource=%s\ntarget=%s\n' \
  "${UPDATED_AT}" "${REPO_URL}" "${BRANCH}" "${SOURCE_SUBDIR}" "${TARGET_DIR}" > "${STAMP_FILE}"

echo "Skill updated successfully: ${SKILL_NAME}"
echo "Target: ${TARGET_DIR}"
echo "OpenClaw was NOT restarted."
echo "Restart OpenClaw manually when you decide to apply runtime changes."
