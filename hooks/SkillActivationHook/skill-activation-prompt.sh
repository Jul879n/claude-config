#!/bin/zsh
# Skill Activation Hook - Optimized & Actionable

RULES_FILE="$HOME/.claude/skills/skill-rules.json"

# Read stdin
INPUT_JSON=$(cat)
[[ -z "$INPUT_JSON" ]] && exit 0

PROMPT=$(echo "$INPUT_JSON" | jq -r '.prompt // .query // ""' 2>/dev/null)
[[ -z "$PROMPT" || "$PROMPT" == "null" ]] && exit 0
[[ ! -f "$RULES_FILE" ]] && exit 0

PROMPT_LC=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Get all skills data in ONE jq call
SKILLS_DATA=$(jq -r '[.skills | to_entries[] | {
  k: .key,
  e: .value.enforcement,
  kw: .value.promptTriggers.keywords,
  pat: .value.promptTriggers.intentPatterns
}]' "$RULES_FILE" 2>/dev/null)

[[ -z "$SKILLS_DATA" || "$SKILLS_DATA" == "null" ]] && exit 0

SKILL_COUNT=$(echo "$SKILLS_DATA" | jq -r 'length')
CRITICAL=""
RECOMMENDED=""

for i in $(seq 0 $((SKILL_COUNT - 1))); do
  SKILL=$(echo "$SKILLS_DATA" | jq -r ".[$i].k")
  ENFORCEMENT=$(echo "$SKILLS_DATA" | jq -r ".[$i].e")
  KEYWORDS_JSON=$(echo "$SKILLS_DATA" | jq -r ".[$i].kw")
  PATTERNS_JSON=$(echo "$SKILLS_DATA" | jq -r ".[$i].pat")

  [[ -z "$SKILL" || "$SKILL" == "null" ]] && continue

  MATCHED=0

  # Keywords - "*" means always match
  if echo "$KEYWORDS_JSON" | grep -qx '"*"'; then
    MATCHED=1
  else
    KEYWORDS=($(echo "$KEYWORDS_JSON" | jq -r '.[]' 2>/dev/null))
    for KW in $KEYWORDS; do
      [[ -z "$KW" || "$KW" == "null" ]] && continue
      if echo "$PROMPT_LC" | grep -qi "$KW"; then
        MATCHED=1
        break
      fi
    done
  fi

  # Intent patterns - skip if null or empty
  if [[ $MATCHED -eq 0 && "$PATTERNS_JSON" != "null" && -n "$PATTERNS_JSON" ]]; then
    PATTERNS=($(echo "$PATTERNS_JSON" | jq -r '.[]' 2>/dev/null))
    for PAT in $PATTERNS; do
      [[ -z "$PAT" || "$PAT" == "null" ]] && continue
      # Validate regex before use - suppress error output
      if echo "$PROMPT" | grep -Eqi "$PAT" 2>/dev/null; then
        MATCHED=1
        break
      fi
    done
  fi

  if [[ $MATCHED -eq 1 ]]; then
    if [[ "$ENFORCEMENT" == "critical" ]]; then
      CRITICAL="$CRITICAL$SKILL "
    else
      RECOMMENDED="$RECOMMENDED$SKILL "
    fi
  fi
done

# Output - Actionable format for Claude
if [[ -n "$CRITICAL" || -n "$RECOMMENDED" ]]; then
  echo ""
  echo "**SKILL ACTIVATION:**"
  [[ -n "$CRITICAL" ]] && echo "LOAD NOW: $CRITICAL"
  [[ -n "$RECOMMENDED" ]] && echo "LOAD IF NEEDED: $RECOMMENDED"
fi

exit 0