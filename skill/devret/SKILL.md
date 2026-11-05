---
name: devret
description: Kod yazma, test, hata ayıklama, refactor, kod tabanı araştırma, kod incelemesi, resim üretme/analiz, commit/PR ve log özetleme işlerini `cx` ile Codex ve Gemini (agy) modellerine devret. Bu işlerden birini yapmadan önce yükle.
---

# Devret

Sen yöneticisin: anla, planla, talimat yaz, sonucu doğrula. İşi `cx` yapar. Amaç senin bağlamını temiz tutmak.

## Modlar

| Komut | İş |
|---|---|
| `cx kod` | özellik, refactor, çok dosyalı değişiklik |
| `cx test` | test yaz, geçene kadar düzelt |
| `cx hata` | hata ayıklama (yeniden üret → kök neden → düzelt) |
| `cx zor` | `kod`/`hata` iki kez başarısız olduysa ya da ikinci görüş gerekiyorsa |
| `cx basit` | lint, rename, docstring, README, çeviri, boilerplate |
| `cx resim "prompt" yol.png` | görsel üret |
| `cx tara "soru"` | kod tabanı sorusu (Gemini okur, sen dosya açmazsın). Explore ajanı yerine bunu kullan |
| `cx gor resim.png ["soru"]` | ekran görüntüsü/görsel analizi; resmi kendin açma |
| `cx incele` | commit öncesi kod incelemesi |
| `cx ikinci` | riskli değişiklikte farklı model ailesiyle (Sonnet 4.6) ikinci inceleme |
| `cx commit ["bağlam"]` | mesaj yazar ve commit atar (yalnızca kullanıcı isteyince) |
| `cx pr [base]` | PR açıklaması dosyası |
| `<komut> 2>&1 \| cx ozet ["odak"]` | uzun çıktıyı özetle; ham logu sen okuma |
| `cx devam <id> "..."` | aynı oturumda düzeltme iste (bağlam Codex'te kalır) |

## Talimat şablonu (kısa tut, kod yapıştırma)

```
cx kod <<'G'
HEDEF: ...
DOSYALAR: src/x.ts, src/y/*   (yalnızca yol; Codex kendisi okur)
KABUL: `npm test` geçer; ... davranışı
YAPMA: ...
G
```

## Kurallar

- 3 satırdan küçük düzeltmeyi kendin yap; devretme maliyeti daha yüksek.
- Doğrulama: `cx` çıktısındaki özet ve diff istatistiği çoğu zaman yeter. Yalnızca riskli dosyada `git diff -- <dosya>` oku.
- Düzeltme gerekirse yeni görev açma, `cx devam <id>` kullan.
- `log=` dizinini yalnızca hata olursa ve hedefli oku (`tail`, `grep`), asla tamamını okuma.
- 2 dakikadan uzun sürecek görevleri `run_in_background` ile çalıştır. Aynı dosyalara dokunan iki görevi paralel çalıştırma.
- Resimleri (üretilen ya da kullanıcının verdiği) kendin açma; gerekiyorsa `cx gor`.
- Codex başarısız olursa `cx` işi otomatik olarak Gemini'ye bir kez daha dener; çıktıda "(gemini yedeği)" görürsen sonucu daha dikkatli doğrula.
- `sorular` alanı doluysa: kendin karar verebiliyorsan `cx devam` ile ilet, veremiyorsan kullanıcıya sor.
