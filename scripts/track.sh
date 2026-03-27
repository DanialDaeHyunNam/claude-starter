#!/usr/bin/env bash
# track.sh — fearnot-ai 진행상황 추적 스크립트
# 사용법:
#   track.sh init <name> <os>              → participant 초기화
#   track.sh update <skillName> <status>   → skill 상태 업데이트 (started|completed)
#   track.sh event <skillName> <type> [detail] → 세부 이벤트 기록
#
# 추적 실패는 절대 skill 진행을 차단하지 않음 (exit 0)

set +e
trap 'exit 0' ERR EXIT

API_URL="${FEARNOT_API_URL:-https://fearnot-ai.vercel.app}"
PARTICIPANT_FILE="$(cd "$(dirname "$0")/.." && pwd)/.fearnot/participant.json"
TIMEOUT=3

# python 명령어 감지 (Windows: python, macOS/Linux: python3)
PYTHON="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")"

# HMAC 키 생성: HMAC-SHA256(key="fearnot.ai", data=YYYYMMDD)
generate_hmac() {
  [ -z "$PYTHON" ] && return 1
  "$PYTHON" -c "import hmac,hashlib,datetime; print(hmac.new(b'fearnot.ai',datetime.date.today().strftime('%Y%m%d').encode(),hashlib.sha256).hexdigest())" 2>/dev/null
}

# JSON 값 추출 (python3 사용, macOS/Linux 기본 내장)
json_get() {
  [ -z "$PYTHON" ] && return 1
  "$PYTHON" -c "import sys,json; print(json.load(sys.stdin).get('$1',''))" 2>/dev/null
}

# --- init: 참여자 등록 ---
cmd_init() {
  local name="$1" os="$2"
  if [ -z "$name" ] || [ -z "$os" ]; then
    echo "사용법: track.sh init <name> <os>" >&2
    exit 0
  fi

  local hmac
  hmac=$(generate_hmac)

  local response
  response=$(curl -s -m "$TIMEOUT" -X POST "$API_URL/api/progress/init" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $hmac" \
    -d "{\"name\":\"$name\",\"os\":\"$os\"}" 2>/dev/null) || { echo "추적 서버 연결 실패 (무시)" >&2; exit 0; }

  local pid
  pid=$(echo "$response" | json_get participantId)

  if [ -z "$pid" ]; then
    echo "참여자 등록 실패 (무시): $response" >&2
    exit 0
  fi

  mkdir -p "$(dirname "$PARTICIPANT_FILE")"
  cat > "$PARTICIPANT_FILE" <<EOF
{"participantId":"$pid","name":"$name","os":"$os"}
EOF

  echo "참여자 등록 완료: $name ($os)" >&2
}

# --- update: skill 상태 업데이트 ---
cmd_update() {
  local skill_name="$1" status="$2"
  if [ -z "$skill_name" ] || [ -z "$status" ]; then
    echo "사용법: track.sh update <skillName> <status>" >&2
    exit 0
  fi

  # participant.json 없으면 조용히 종료
  if [ ! -f "$PARTICIPANT_FILE" ]; then
    exit 0
  fi

  local pid
  pid=$(cat "$PARTICIPANT_FILE" | json_get participantId)
  if [ -z "$pid" ]; then
    exit 0
  fi

  local hmac
  hmac=$(generate_hmac)

  curl -s -m "$TIMEOUT" -X POST "$API_URL/api/progress/update" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $hmac" \
    -d "{\"participantId\":\"$pid\",\"skillName\":\"$skill_name\",\"status\":\"$status\"}" \
    >/dev/null 2>&1 || true
}

# --- event: 세부 이벤트 기록 ---
cmd_event() {
  local skill_name="$1" event_type="$2" detail="$3"
  if [ -z "$skill_name" ] || [ -z "$event_type" ]; then
    echo "사용법: track.sh event <skillName> <type> [detail]" >&2
    exit 0
  fi

  # participant.json 없으면 조용히 종료
  if [ ! -f "$PARTICIPANT_FILE" ]; then
    exit 0
  fi

  local pid
  pid=$(cat "$PARTICIPANT_FILE" | json_get participantId)
  if [ -z "$pid" ]; then
    exit 0
  fi

  local hmac
  hmac=$(generate_hmac)

  local body
  if [ -n "$detail" ]; then
    body="{\"participantId\":\"$pid\",\"skillName\":\"$skill_name\",\"eventType\":\"$event_type\",\"detail\":\"$detail\"}"
  else
    body="{\"participantId\":\"$pid\",\"skillName\":\"$skill_name\",\"eventType\":\"$event_type\"}"
  fi

  curl -s -m "$TIMEOUT" -X POST "$API_URL/api/progress/event" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $hmac" \
    -d "$body" \
    >/dev/null 2>&1 || true
}

# --- 메인 ---
case "${1:-}" in
  init)   shift; cmd_init "$@" ;;
  update) shift; cmd_update "$@" ;;
  event)  shift; cmd_event "$@" ;;
  *)
    echo "사용법: track.sh {init|update|event} ..." >&2
    exit 0
    ;;
esac
