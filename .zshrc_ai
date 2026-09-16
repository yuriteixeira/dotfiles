### AI

alias shipit="p /shipit"
alias commit="p commit"
alias reflect="$HOME/.pi/agent/extensions/pi-memories/bin/reflect"

# Pi, but a bit "dumb"
function p() {
  local -a args=(
    "${piDumbModel[@]}"
    "$@"
  )

  pi ${args[@]}
}

function q() {
  local question="$*"

  local -a args=(
    ${piDumbModel[@]}
    ${piOnlyBasicsAndWebSearch[@]}
    --no-session
    -- "$question"
  )

  pi ${args[@]}
}

# Quick Questions (Non-interactive, streamable)
function qq() {
  setopt local_options pipe_fail

  local question="$*"

  local -a args=(
    ${piDumbModel[@]}
    ${piOnlyBasicsAndWebSearch[@]}
    --no-session
    --mode json
    -- "$question"
  )

  echo ""
  echo "# Question: $question"
  echo ""

  pi "${args[@]}" |
    jq --unbuffered --join-output '
      select(
        .type == "message_update" and
        .assistantMessageEvent.type == "text_delta"
      ) |
      .assistantMessageEvent.delta
    '

  local pipelineStatus=$?
  echo ""

  return $pipelineStatus
}

local -a piDumbModel=(
  --model openai-codex/gpt-5.6-luna
  --thinking low
)

local -a piOnlyBasicsAndWebSearch=(
  --no-skills
  --no-prompt-templates
  --no-extensions
  --no-context-files
  --extension "$HOME/.pi/agent/npm/node_modules/pi-web-access/index.ts"
  --extension "$HOME/.pi/agent/npm/node_modules/pi-context-inspector/index.ts"
  --tools read,grep,find,ls,web_search,fetch_content,source_check,get_search_content
)
