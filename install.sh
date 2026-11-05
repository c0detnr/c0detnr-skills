#!/usr/bin/env bash
# Kullanım:
#   ./install.sh                 -> yalnızca `cx` komutunu ~/.local/bin'e bağlar
#   ./install.sh /proje/yolu     -> + skill'i ve CLAUDE.md + AGENTS.md kuralını o projeye ekler
#   ./install.sh --global        -> + skill'i tüm projeler için ~/.claude/skills'e ekler
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"

chmod +x "$KIT/bin/cx"
mkdir -p "$HOME/.local/bin"
ln -sf "$KIT/bin/cx" "$HOME/.local/bin/cx"
echo "✓ cx -> ~/.local/bin/cx"

hedef="${1:-}"
[ -z "$hedef" ] && exit 0

if [ "$hedef" = "--global" ]; then
  mkdir -p "$HOME/.claude/skills"
  ln -sfn "$KIT/skill/devret" "$HOME/.claude/skills/devret"
  echo "✓ skill: ~/.claude/skills/devret"
  exit 0
fi

proje="$(realpath "$hedef")"
mkdir -p "$proje/.claude/skills"
rm -rf "$proje/.claude/skills/devret"
cp -r "$KIT/skill/devret" "$proje/.claude/skills/devret"
echo "✓ skill: $proje/.claude/skills/devret"

for ad in CLAUDE.md AGENTS.md; do
  md="$proje/$ad"
  if ! grep -q "<!-- devret -->" "$md" 2>/dev/null; then
    { [ -s "$md" ] && echo; cat "$KIT/share/CLAUDE.snippet.md"; } >> "$md"
    echo "✓ kural eklendi: $md"
  fi
done

# cx için izin (varsa mevcut ayarlarla birleştirir)
ayar="$proje/.claude/settings.json"
python3 -I - "$ayar" <<'P'
import json,os,sys
p=sys.argv[1]; d=json.load(open(p)) if os.path.exists(p) else {}
a=d.setdefault("permissions",{}).setdefault("allow",[])
for r in ("Bash(cx:*)","Bash(cx *)"):
    if r not in a: a.append(r)
json.dump(d,open(p,"w"),indent=2,ensure_ascii=False); print("✓ izin: "+p)
P
