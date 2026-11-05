# devret — Opus yönetir, Codex ve Gemini yapar

Claude Code (Opus 5.5) plan yapar ve sonucu doğrular. İşleri `cx` komutu Codex ve Antigravity (`agy`) modellerine devreder. Uzun çıktılar diskte kalır, Opus'a yalnızca birkaç satırlık özet döner.

## Kurulum

```bash
./install.sh /proje/yolu   # o projeye ekle
./install.sh --global      # ya da tüm projelere
```

## Model ve effort dağılımı

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

Tek seferlik değiştirmek için: `CX_MODEL=... CX_EFFORT=... cx kod "..."` (agy modları için `CX_AGY_MODEL=...`)

## Dosyalar

- `bin/cx`: tek betik, tüm modlar
- `skill/devret/SKILL.md`: Opus'a ne zaman ve nasıl devredeceğini anlatır
- `share/sonuc.schema.json`: Codex'in son cevabının biçimi
- `share/CLAUDE.snippet.md`: projenin CLAUDE.md ve AGENTS.md dosyalarına eklenen kural
- Loglar ve token kaydı: `~/.local/state/cx/` (`cx durum` ile özet)
