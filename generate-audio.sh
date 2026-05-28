#!/usr/bin/env bash
# Generates MP3 audio files from _readable/ markdown files using Google Cloud TTS Neural2.
# Requires: GOOGLE_TTS_API_KEY env var, python3, ffmpeg, curl
#
# Setup:
#   1. Enable Cloud Text-to-Speech API at console.cloud.google.com
#   2. Create an API key (APIs & Services > Credentials) restricted to TTS API
#   3. export GOOGLE_TTS_API_KEY=your_key_here
#   4. bash generate-audio.sh

set -euo pipefail

READABLE_DIR="$(dirname "$0")/_readable"
AUDIO_DIR="$(dirname "$0")/_audio"
VOICE_NAME="en-GB-Neural2-D"   # Natural British male — change to en-US-Neural2-D for US English
LANGUAGE_CODE="en-GB"
SPEAKING_RATE="0.92"           # Slightly slower than default for technical content
MAX_CHARS=4800                  # Google TTS limit is 5000; keep a buffer

if [[ -z "${GOOGLE_TTS_API_KEY:-}" ]]; then
  echo "Error: GOOGLE_TTS_API_KEY is not set."
  echo "  export GOOGLE_TTS_API_KEY=your_key_here"
  exit 1
fi

mkdir -p "$AUDIO_DIR"
TMPDIR_LOCAL=$(mktemp -d)
trap "rm -rf '$TMPDIR_LOCAL'" EXIT

# Strip markdown formatting to plain prose
strip_markdown() {
  sed \
    -e 's/^---*$//' \
    -e 's/^#\+[[:space:]]*//' \
    -e 's/\*\*\([^*]*\)\*\*/\1/g' \
    -e 's/\*\([^*]*\)\*/\1/g' \
    -e 's/`[^`]*`//g' \
    -e 's/^\s*[-*+][[:space:]]*//' \
    -e 's/^\s*[0-9]\+\.[[:space:]]*//' \
    -e 's/\[[^]]*\]([^)]*)//g' \
    -e '/^```/,/^```/d' \
    -e 's/|[^|]*//g' \
    -e '/^[[:space:]]*$/d'
}

# Split a plain-text file into chunks of at most MAX_CHARS, breaking at paragraph boundaries.
# Prints one chunk file path per line.
split_into_chunks() {
  python3 - "$1" "$MAX_CHARS" <<'PYEOF'
import sys, os

input_file, max_chars = sys.argv[1], int(sys.argv[2])
text = open(input_file).read()
paragraphs = [p.strip() for p in text.split('\n\n') if p.strip()]

chunks = []
current_parts, current_len = [], 0

for para in paragraphs:
    if len(para) > max_chars:
        # Paragraph itself too long: split at sentence boundaries
        for sent in para.replace('. ', '.\n').split('\n'):
            sent = sent.strip()
            if not sent:
                continue
            if current_len + len(sent) + 1 > max_chars and current_parts:
                chunks.append(' '.join(current_parts))
                current_parts, current_len = [sent], len(sent)
            else:
                current_parts.append(sent)
                current_len += len(sent) + 1
    elif current_len + len(para) + 2 > max_chars and current_parts:
        chunks.append('\n\n'.join(current_parts))
        current_parts, current_len = [para], len(para)
    else:
        current_parts.append(para)
        current_len += len(para) + 2

if current_parts:
    chunks.append('\n\n'.join(current_parts))

base = os.path.splitext(input_file)[0]
for i, chunk in enumerate(chunks):
    path = f"{base}.chunk{i:03d}.txt"
    open(path, 'w').write(chunk)
    print(path)
PYEOF
}

# Call Google TTS API, write MP3 to output path.
# Exits with code 2 on quota/billing errors so the caller can stop cleanly.
synthesize_chunk() {
  local text_file="$1"
  local mp3_out="$2"

  python3 - "$text_file" "$mp3_out" "$VOICE_NAME" "$LANGUAGE_CODE" "$SPEAKING_RATE" <<PYEOF
import json, base64, sys, urllib.request, urllib.error

text_file, mp3_out, voice, lang, rate = sys.argv[1:]
text = open(text_file).read().strip()
if not text:
    sys.exit(0)

payload = json.dumps({
    "input": {"text": text},
    "voice": {"languageCode": lang, "name": voice},
    "audioConfig": {"audioEncoding": "MP3", "speakingRate": float(rate)}
}).encode()

req = urllib.request.Request(
    f"https://texttospeech.googleapis.com/v1/text:synthesize?key=${GOOGLE_TTS_API_KEY}",
    data=payload,
    headers={"Content-Type": "application/json"},
    method="POST"
)

try:
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
        open(mp3_out, 'wb').write(base64.b64decode(data['audioContent']))
except urllib.error.HTTPError as e:
    body = e.read().decode()
    try:
        msg = json.loads(body).get('error', {}).get('message', body)
    except Exception:
        msg = body
    # 429 = quota exhausted; 403 with billingNotEnabled = no billing account
    if e.code in (429, 403):
        print(f"\nQuota or billing error: {msg}", file=sys.stderr)
        print("Free tier (1M chars/month) may be exhausted, or billing is not enabled.", file=sys.stderr)
        print("Check: console.cloud.google.com > Billing > Budgets & alerts", file=sys.stderr)
        sys.exit(2)
    print(f"API error {e.code}: {msg}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

for md in "$READABLE_DIR"/*.md; do
  name="$(basename "$md" .md)"
  final_mp3="$AUDIO_DIR/${name}.mp3"
  plain_txt="$TMPDIR_LOCAL/${name}.txt"

  echo "Generating: $name"
  strip_markdown < "$md" > "$plain_txt"

  # Collect chunk file paths
  chunk_files=()
  while IFS= read -r chunk_file; do
    chunk_files+=("$chunk_file")
  done < <(split_into_chunks "$plain_txt")

  echo "  ${#chunk_files[@]} chunk(s)"

  chunk_mp3s=()
  quota_hit=0
  for i in "${!chunk_files[@]}"; do
    chunk_mp3="$TMPDIR_LOCAL/${name}_chunk${i}.mp3"
    set +e
    synthesize_chunk "${chunk_files[$i]}" "$chunk_mp3"
    exit_code=$?
    set -e
    if [[ $exit_code -eq 2 ]]; then
      quota_hit=1
      break
    elif [[ $exit_code -ne 0 ]]; then
      echo "  Error on chunk $i — skipping $name" >&2
      break
    fi
    chunk_mp3s+=("$chunk_mp3")
  done

  if [[ $quota_hit -eq 1 ]]; then
    echo ""
    echo "Stopped: quota or billing limit reached. Files generated so far are in _audio/."
    break
  fi

  if [[ ${#chunk_mp3s[@]} -eq 1 ]]; then
    mv "${chunk_mp3s[0]}" "$final_mp3"
  else
    # Concatenate chunks without re-encoding
    concat_list="$TMPDIR_LOCAL/${name}_concat.txt"
    printf '' > "$concat_list"
    for mp3 in "${chunk_mp3s[@]}"; do
      echo "file '$mp3'" >> "$concat_list"
    done
    ffmpeg -y -loglevel error -f concat -safe 0 -i "$concat_list" -c copy "$final_mp3"
  fi

  duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$final_mp3" 2>/dev/null | awk '{printf "%.0f min %02d sec", $1/60, $1%60}')
  echo "  -> _audio/${name}.mp3 ($duration)"
done

echo "Done."
