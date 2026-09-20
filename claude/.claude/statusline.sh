#!/usr/bin/env bash
# Context badge (Matt Pocock style).
input=$(cat)

read -r transcript model <<<"$(printf '%s' "$input" | jq -r '[.transcript_path, .model.id] | @tsv')"

# ponytail: window inferred from the model id, no table of per-model limits to maintain
case "$model" in
    *"[1m]"*|*"-1m"*) window=1000000 ;;
    *) window=200000 ;;
esac

if [ -f "$transcript" ]; then
    used=$(jq -s 'map(select(.message.usage)) | last | .message.usage
                  | (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens + .output_tokens) // 0' \
           "$transcript" 2>/dev/null)
    case "$used" in
        ''|null) used=0 ;;
    esac
    if [ "$used" -gt 0 ]; then
        printf '\033[38;5;179m%s\033[0m \033[38;5;244m(%s)\033[0m ' \
            "$(awk -v u="$used" 'BEGIN{printf "%.1fk", u/1000}')" \
            "$(awk -v u="$used" -v w="$window" 'BEGIN{printf "%.1f%%", 100*u/w}')"
    fi
fi
