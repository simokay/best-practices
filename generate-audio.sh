#!/usr/bin/env bash
# Generates AAC audio files from _readable/ markdown files.
# Output goes to _audio/. Run locally: bash generate-audio.sh

set -euo pipefail

READABLE_DIR="$(dirname "$0")/_readable"
AUDIO_DIR="$(dirname "$0")/_audio"
VOICE="Daniel"
RATE=175

mkdir -p "$AUDIO_DIR"

strip_markdown() {
  sed \
    -e 's/^---*$//' \
    -e 's/^#\+[[:space:]]*//' \
    -e 's/\*\*\([^*]*\)\*\*/\1/g' \
    -e 's/\*\([^*]*\)\*/\1/g' \
    -e 's/`\([^`]*\)`/\1/g' \
    -e 's/^\s*[-*+][[:space:]]*//' \
    -e 's/^\s*[0-9]\+\.[[:space:]]*//' \
    -e 's/\[^\[]*\]([^)]*)//' \
    -e 's/\[[^]]*\](\([^)]*\))/\1/g' \
    -e '/^```/,/^```/d' \
    -e 's/|[^|]*//g' \
    -e '/^[[:space:]]*$/d'
}

for md in "$READABLE_DIR"/*.md; do
  name="$(basename "$md" .md)"
  aiff="$AUDIO_DIR/${name}.aiff"
  aac="$AUDIO_DIR/${name}.aac"

  echo "Generating: $name"

  strip_markdown < "$md" > /tmp/tts_input.txt

  say -v "$VOICE" -r "$RATE" -f /tmp/tts_input.txt -o "$aiff"

  ffmpeg -y -loglevel error -i "$aiff" \
    -c:a aac -b:a 64k -ar 22050 \
    "$aac"

  rm "$aiff"
  echo "  -> _audio/${name}.aac"
done

rm -f /tmp/tts_input.txt
echo "Done. Audio files in _audio/"
