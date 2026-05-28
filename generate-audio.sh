#!/usr/bin/env bash
# Generates AAC audio files from _readable/ markdown files.
# Uses the macOS Fiona (Enhanced) voice via the built-in say command.
# Requires: ffmpeg  —  brew install ffmpeg

set -euo pipefail

READABLE_DIR="$(dirname "$0")/_readable"
AUDIO_DIR="$(dirname "$0")/_audio"
VOICE="Fiona (Enhanced)"
RATE=165

mkdir -p "$AUDIO_DIR"
TMPDIR_LOCAL=$(mktemp -d)
trap "rm -rf '$TMPDIR_LOCAL'" EXIT

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

for md in "$READABLE_DIR"/*.md; do
  name="$(basename "$md" .md)"
  aiff="$TMPDIR_LOCAL/${name}.aiff"
  aac="$AUDIO_DIR/${name}.aac"

  echo "Generating: $name"

  strip_markdown < "$md" > "$TMPDIR_LOCAL/${name}.txt"

  say -v "$VOICE" -r "$RATE" -f "$TMPDIR_LOCAL/${name}.txt" -o "$aiff"

  ffmpeg -y -loglevel error -i "$aiff" \
    -c:a aac -b:a 64k -ar 22050 \
    "$aac"

  duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$aac" 2>/dev/null | awk '{printf "%.0f min %02d sec", $1/60, $1%60}')
  echo "  -> _audio/${name}.aac ($duration)"
done

echo "Done."
