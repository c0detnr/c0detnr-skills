#!/usr/bin/env bash
# Kullanım:
#   ./install.sh                 -> yalnızca `cx` komutunu ~/.local/bin'e bağlar
#   ./install.sh /proje/yolu     -> + skill'i ve CLAUDE.md + AGENTS.md kuralını o projeye ekler
#   ./install.sh --global        -> + skill'i tüm projeler için ~/.claude/skills'e ekler
# Windows: Git Bash içinden çalıştırın (Claude Code da Git Bash kullanır).
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;; *) IS_WIN=0 ;; esac

# Gerçekten çalışan Python 3'ü bul (Windows'ta python3 çoğu zaman Store taslağıdır)
PY="${CX_PYTHON:-}"
if [ -z "$PY" ]; then
  for c in python3 python py; do
    "$c" -c 'import sys;sys.exit(sys.version_info<(3,6))' >/dev/null 2>&1 && { PY="$c"; break; }
  done
fi
[ -n "$PY" ] || { echo "✗ Python 3 bulunamadı (CX_PYTHON ile belirtin)" >&2; exit 1; }
export PYTHONUTF8=1

chmod +x "$KIT/bin/cx"
mkdir -p "$HOME/.local/bin"
if [ "$IS_WIN" = 1 ]; then
  # Git Bash'te ln -s sessizce kopyalar; bu yüzden kit dizinini bilen küçük bir başlatıcı yaz.
  rm -f "$HOME/.local/bin/cx"
  printf '#!/usr/bin/env bash\nexport CX_KIT_DIR=%q\nexec bash %q "$@"\n' "$KIT" "$KIT/bin/cx" > "$HOME/.local/bin/cx"
  chmod +x "$HOME/.local/bin/cx"
  # PowerShell / cmd için
  bash_w="$(cygpath -w "$(command -v bash)")"
  printf '@echo off\r\nset "CX_KIT_DIR=%s"\r\n"%s" "%s" %%*\r\n' \
    "$(cygpath -w "$KIT")" "$bash_w" "$(cygpath -u "$KIT")/bin/cx" > "$HOME/.local/bin/cx.cmd"
  echo "✓ cx -> ~/.local/bin/cx (+ cx.cmd)"
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
    echo "! ~/.local/bin PATH'te değil. Kullanıcı PATH'ine ekleyin: $(cygpath -w "$HOME/.local/bin")" ;;
  esac
else
  ln -sf "$KIT/bin/cx" "$HOME/.local/bin/cx"
  echo "✓ cx -> ~/.local/bin/cx"
fi

# ~/.c0detnr: ayarlar + loglar. Var olan config'e dokunma.
CX_HOME="${CX_HOME:-$HOME/.c0detnr}"
mkdir -p "$CX_HOME"
if [ -f "$CX_HOME/config" ]; then
  echo "✓ config korundu: $CX_HOME/config"
else
  cp "$KIT/share/config.ornek" "$CX_HOME/config"
  echo "✓ config: $CX_HOME/config (modelleri buradan değiştirin)"
fi

hedef="${1:-}"
[ -z "$hedef" ] && exit 0

if [ "$hedef" = "--global" ]; then
  mkdir -p "$HOME/.claude/skills"
  if [ "$IS_WIN" = 1 ]; then   # sembolik bağ yerine kopya (güncellemek için install.sh'ı yeniden çalıştırın)
    rm -rf "$HOME/.claude/skills/devret"
    cp -r "$KIT/skill/devret" "$HOME/.claude/skills/devret"
  else
    ln -sfn "$KIT/skill/devret" "$HOME/.claude/skills/devret"
  fi
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
"$PY" -I -X utf8 - "$ayar" <<'P'
import json,os,sys
p=sys.argv[1]; d=json.load(open(p,encoding="utf-8")) if os.path.exists(p) else {}
a=d.setdefault("permissions",{}).setdefault("allow",[])
for r in ("Bash(cx:*)","Bash(cx *)"):
    if r not in a: a.append(r)
json.dump(d,open(p,"w",encoding="utf-8"),indent=2,ensure_ascii=False); print("✓ izin: "+p)
P
