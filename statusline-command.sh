#!/usr/bin/env bash
# Claude Code status line — EVA-01 theme
# Propuesta B: feature/JA_IMPORT  ·  Sonnet 4.6  ·  ▰▰▰▰▱▱▱▱▱▱ 41%  ·  5h 8%  ·  ↺ 3h42m · 18:00
#
# Colors:
#   Violet  #4A0E8F  → closest ANSI 256: \e[38;5;55m  (dim for separators/labels)
#   Lime    #A8FF00  → closest ANSI 256: \e[38;5;154m (bright, for bar and key values)

input=$(cat)

# ── ANSI helpers ──────────────────────────────────────────────────────────────
RESET='\e[0m'
# Violet dim for separators and secondary labels
VIOLET_DIM='\e[2;38;5;55m'
# Lime green for bar fill and important values
LIME='\e[1;38;5;154m'
# Lime dim for bar empty chars
LIME_DIM='\e[2;38;5;154m'
# Violet bold for branch (EVA-01 body color)
VIOLET='\e[1;38;5;55m'
# Separator: violet dim " · "
SEP="${VIOLET_DIM} · ${RESET}"

# ── Data extraction ───────────────────────────────────────────────────────────
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$(pwd)" symbolic-ref --short HEAD 2>/dev/null)
model_raw=$(echo "$input"       | jq -r '.model.display_name // empty')
used=$(echo "$input"            | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input"        | jq -r '.context_window.context_window_size // empty')
# Billing session limits (Claude.ai subscription)
five_hour_pct=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── Segment builder ───────────────────────────────────────────────────────────
segments=()

# 1. Git branch — violet bold (EVA-01 body), truncated after last slash
if [ -n "$branch" ]; then
  branch_short="${branch##*/}"
  # Keep full branch if no slash found
  [ "$branch_short" = "$branch" ] && branch_short="$branch"
  segments+=("$(printf "${VIOLET}%s${RESET}" "$branch_short")")
fi

# 2. Model — strip "Claude " prefix, lime green
if [ -n "$model_raw" ]; then
  model_short="${model_raw#Claude }"
  segments+=("$(printf "${LIME}%s${RESET}" "$model_short")")
fi

# 3. Context bar — ▰▰▰▰▱▱▱▱▱▱ N%
#    Bar: 10 blocks. Filled ▰ in lime, empty ▱ in lime dim. Percentage in lime.
#    At >=80% bar turns red, >=60% yellow.
if [ -n "$used" ] && [ -n "$ctx_size" ]; then
  used_int=$(printf '%.0f' "$used")

  # 10-block bar
  filled=$(( used_int * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))

  # Color thresholds for bar and percentage
  if   [ "$used_int" -ge 80 ]; then
    bar_fill_color='\e[1;31m'   # red — critical
    pct_color='\e[1;31m'
  elif [ "$used_int" -ge 60 ]; then
    bar_fill_color='\e[1;33m'   # yellow — warning
    pct_color='\e[1;33m'
  else
    bar_fill_color="$LIME"      # lime — healthy
    pct_color="$LIME"
  fi

  bar=""
  i=0
  while [ $i -lt $filled ]; do bar="${bar}$(printf "${bar_fill_color}\xe2\x96\xb0${RESET}")"; i=$(( i + 1 )); done
  i=0
  while [ $i -lt $empty ];  do bar="${bar}$(printf "${LIME_DIM}\xe2\x96\xb1${RESET}")"; i=$(( i + 1 )); done

  segments+=("$(printf "%b${pct_color}%d%%${RESET}" "$bar" "$used_int")")
fi

# 4. 5-hour session usage — "5h N%"
#    Color: lime <60%, yellow 60-79%, red >=80%
if [ -n "$five_hour_pct" ]; then
  five_int=$(printf '%.0f' "$five_hour_pct")

  if   [ "$five_int" -ge 80 ]; then sess_color='\e[1;31m'
  elif [ "$five_int" -ge 60 ]; then sess_color='\e[1;33m'
  else                               sess_color="$LIME"
  fi

  segments+=("$(printf "${VIOLET_DIM}5h${RESET} ${sess_color}%d%%${RESET}" "$five_int")")
fi

# 5. Countdown to 5-hour reset — "↺ 3h42m · 18:00" or "↺ 42m · 18:00" (< 60 min)
#    Countdown in lime green; separator · and reset time in violet dim
if [ -n "$five_hour_reset" ]; then
  now=$(date +%s)
  diff=$(( five_hour_reset - now ))
  if [ "$diff" -gt 0 ]; then
    diff_h=$(( diff / 3600 ))
    diff_m=$(( (diff % 3600) / 60 ))
    if [ "$diff_h" -ge 1 ]; then
      countdown="${diff_h}h${diff_m}m"
    else
      countdown="${diff_m}m"
    fi
    reset_time=$(date -r "$five_hour_reset" +%H:%M 2>/dev/null || date -d "@$five_hour_reset" +%H:%M 2>/dev/null)
    segments+=("$(printf "${VIOLET_DIM}\xe2\x86\xba ${RESET}${LIME}%s${RESET}${VIOLET_DIM} \xc2\xb7 %s${RESET}" "$countdown" "$reset_time")")
  fi
fi

# 6. 7-day weekly usage — "7d N%"
#    Color: lime <60%, yellow 60-79%, red >=80%
if [ -n "$seven_day_pct" ]; then
  week_int=$(printf '%.0f' "$seven_day_pct")

  if   [ "$week_int" -ge 80 ]; then week_color='\e[1;31m'
  elif [ "$week_int" -ge 60 ]; then week_color='\e[1;33m'
  else                               week_color="$LIME"
  fi

  segments+=("$(printf "${VIOLET_DIM}7d${RESET} ${week_color}%d%%${RESET}" "$week_int")")
fi

# 7. Countdown to 7-day reset — "↺7d 2d14h · lun 09:00"
if [ -n "$seven_day_reset" ]; then
  now=$(date +%s)
  diff7=$(( seven_day_reset - now ))
  if [ "$diff7" -gt 0 ]; then
    diff7_d=$(( diff7 / 86400 ))
    diff7_h=$(( (diff7 % 86400) / 3600 ))
    diff7_m=$(( (diff7 % 3600) / 60 ))
    if [ "$diff7_d" -ge 1 ]; then
      countdown7="${diff7_d}d${diff7_h}h"
    elif [ "$diff7_h" -ge 1 ]; then
      countdown7="${diff7_h}h${diff7_m}m"
    else
      countdown7="${diff7_m}m"
    fi
    reset7_time=$(date -r "$seven_day_reset" "+%a %H:%M" 2>/dev/null || date -d "@$seven_day_reset" "+%a %H:%M" 2>/dev/null)
    segments+=("$(printf "${VIOLET_DIM}\xe2\x86\xba7d ${RESET}${LIME}%s${RESET}${VIOLET_DIM} \xc2\xb7 %s${RESET}" "$countdown7" "$reset7_time")")
  fi
fi

# ── Assemble output ───────────────────────────────────────────────────────────
out=""
for seg in "${segments[@]}"; do
  if [ -z "$out" ]; then
    out="$seg"
  else
    out="${out}${SEP}${seg}"
  fi
done

printf '%b' "$out"
