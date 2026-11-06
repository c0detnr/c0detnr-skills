# devret — Opus yönetir, Codex ve Gemini yapar

Claude Code (Opus 5.5) plan yapar ve sonucu doğrular. İşleri `cx` komutu Codex ve Antigravity (`agy`) modellerine devreder. Uzun çıktılar diskte kalır, Opus'a yalnızca birkaç satırlık özet döner.

## Kurulum

```bash
./install.sh /proje/yolu   # o projeye ekle
./install.sh --global      # ya da tüm projelere
```

### Windows

Git Bash gerekir (Claude Code da onu kullanır). Kurulumu Git Bash içinden çalıştırın:

```bash
bash install.sh --global
```

- `~/.local/bin/cx` (Git Bash) ve `~/.local/bin/cx.cmd` (PowerShell/cmd) başlatıcıları yazılır. Bu klasör PATH'te değilse kullanıcı PATH'ine ekleyin.
- Sembolik bağ yerine kopya kullanılır; depoyu güncelledikten sonra `install.sh`'ı yeniden çalıştırın.
- Python olarak `python3`, `python`, `py` sırasıyla denenir (Store taslağı atlanır). Elle seçmek için: `CX_PYTHON=...`
- `codex` ve `agy` yerel Windows exe'leri olduğu için istemlere giden yollar otomatik olarak `C:\...` biçimine çevrilir.
- `.gitattributes` betikleri LF satır sonuyla tutar; `core.autocrlf=true` olsa da bash betikleri bozulmaz.

## Ayarlar: `<proje>/.c0detnr/config`

`./install.sh /proje/yolu` modelleri belirleyen ayar dosyasını projenin içine kurar: `<proje>/.c0detnr/config`. Dosya zaten varsa ona dokunmaz. Her iş için model buradan değişir:

```ini
kod    = gpt-6.1-sol  medium     # mod = model [effort]
hata   = gpt-6-astra  high
tara   = gemini-3.8-flash-medium # agy modlarında effort yok
yedek_acik = 0                   # codex başarısız olunca gemini'ye geçme
```

- `cx`, projenin alt klasörlerinden çalıştırılsa da git kökündeki `.c0detnr/config` dosyasını okur.
- İsteğe bağlı ortak ayar: `~/.c0detnr/config` (`--global` kurulumu oluşturur). Proje dosyası onu ezer.
- Sıra: varsayılan < `~/.c0detnr/config` < `<proje>/.c0detnr/config` < ortam değişkenleri (`CX_MODEL`, `CX_EFFORT`, `CX_AGY_MODEL`).
- Bir satırda effort yazılmazsa `medium` kullanılır.
- `cx config`: etkin değerleri ve okunan dosyaları gösterir; hiç config yoksa projede oluşturur.
- Loglar ve token kaydı ortak yerde tutulur: `~/.c0detnr/runs/`, `~/.c0detnr/usage.csv` (`cx durum`).
- kod/test/hata/zor/basit/devam/resim/incele/commit/pr modları Codex'e, ozet/tara/gor/ikinci/yedek agy'ye gider; her moda o aracın tanıdığı bir model yaz.

## Varsayılan model ve effort dağılımı

| Mod | Model | Effort | Sandbox |
|---|---|---|---|
| kod, test | gpt-6.1-sol | medium | workspace-write |
| hata | gpt-6.1-sol | high | workspace-write |
| zor | gpt-6-astra | high | workspace-write |
| basit | gpt-6-luna | low | workspace-write |
| resim | gpt-6.1-sol | low | workspace-write |
| incele | gpt-6.1-sol | medium | (review) |
| commit, pr | gpt-6-luna | low | read-only |
| ozet | gemini-3.8-flash-low (yedek: luna) | – | salt okuma |
| tara, gor | gemini-3.8-flash-medium (agy) | – | salt okuma |
| ikinci | claude-sonnet-4-6 (agy) | – | salt okuma |

Codex başarısız olursa (kota, hata) kod/test/hata/zor/basit işleri `gemini-3.8-flash-high` ile bir kez daha denenir. Kapatmak için: `CX_YEDEK=0`.

Kalıcı değiştirmek için `<proje>/.c0detnr/config`; tek seferlik için: `CX_MODEL=... CX_EFFORT=... cx kod "..."` (agy modları için `CX_AGY_MODEL=...`)

## Dosyalar

- `bin/cx`: tek betik, tüm modlar
- `skill/devret/SKILL.md`: Opus'a ne zaman ve nasıl devredeceğini anlatır
- `share/sonuc.schema.json`: Codex'in son cevabının biçimi
- `share/CLAUDE.snippet.md`: projenin CLAUDE.md ve AGENTS.md dosyalarına eklenen kural
- `share/config.ornek`: `.c0detnr/config` için şablon
