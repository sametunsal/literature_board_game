# EDEBİNA - Literatür Temalı Masa Oyunu
## Magic Design Modu için Oyun Tanımı

---

## 🎯 OYUN KONSEPTI

**EDEBİNA**, Monopoly tarzında bir masa oyunu olup **Türk Edebiyatı** temasıyla tasarlanmıştır. Oyuncular 40 karelık bir tahtada hareket ederek:
- Ünlü Türk romanlarının **telif haklarını** satın alırlar
- Edebiyat soruları yanitlarlar
- Para kazanır ve kaybederler
- Diğer oyunculara **kira** öderler

Oyun, klasik bir board game mekaniğini zarif, akademik bir tema ile birleştirir.

---

## 🎲 OYUN MEKANİĞİ

### 1. **Tahta (40 Kare)**

Monopoly benzeri düzen:
- **4 Köşe Kare:**
  - **BAŞLANGIÇ** (0): Başlangıç noktası, buradan her geçişte 200 Yıldız (para birimi) kazanılır
  - **KÜTÜPHANE NÖBETİ** (10): Ceza karesi (jail)
  - **İMZA GÜNÜ** (20): Özel etkinlik karesi
  - **İFLAS RİSKİ** (30): Tehlikeli kare

- **28 Roman Karesi:**
  - Türk edebiyatının ünlü eserleri (Çalıkuşu, Mai ve Siyah, İnce Memed, Tutunamayanlar, vb.)
  - Her romanda **fiyat**, **kira**, **edebiyat sorusu** bulunur
  - **8 renk grubu** ile ayrılır (Kahverengi → Mavi geçiş, fiyatlar artar):
    1. Mor/Kahverengi (en ucuz: 60-80₺)
    2. Açık Mavi (100-140₺)
    3. Pembe (140-180₺)
    4. Turuncu (180-220₺)
    5. Kırmızı (220-260₺)
    6. Sarı (260-300₺)
    7. Yeşil (300-340₺)
    8. Mavi (en pahalı: 350-400₺)

- **Özel Kareler:**
  - **ŞANS KARTI** (4 adet): Pozitif/negatif rastgele olaylar
  - **KADER KARTI** (3 adet): Global/toplumsal olaylar
  - **YAYINEVİ** (4 adet): Utility kareler
  - **GELİR VERGİSİ**, **YAZARLIK VERGİSİ**: Vergi kareleri

### 2. **Oyuncu Akışı**
1. **Zar At**: İki zar atılır (çift gelirse ekstra tur)
2. **Hareket**: Piyonlar zarın toplamı kadar ilerler
3. **Kareye Göre Aksiyon:**
   - **Sahipsiz Roman**: Soru çık → Doğru cevap = satın alma hakkı
   - **Sahipli Roman**: Kira öde
   - **Şans/Kader**: Kart çek
   - **Özel Kareler**: Özel efekt (vergi öde, hapishane, vb.)
4. **Tur Sonu**: Sonraki oyuncu

### 3. **Soru Sistemi**
5 kategori:
- **Ben Kimim?** (Yazar tanıma)
- **Türk Edebiyatında İlkler**
- **Edebiyat Akımları**
- **Edebi Sanatlar**
- **Eser-Karakter** (Karakteri tanıma)

Her soru çoktan seçmeli (4 şık), doğru cevap verince romana sahip olunabilir.

### 4. **Para Sistemi (Yıldız ⭐)**
- Başlangıç parası: **2500 Yıldız**
- Başlangıçtan her geçişte: **+200 Yıldız**
- Roman satın alma: 60-400 Yıldız arası
- Kira ödemeleri: 2-50 Yıldız arası
- Şans/Kader kartları ile değişebilir

---

## 🃏 ŞANS & KADER KARTLARI

**ŞANS Kartları** (Kişisel olaylar):
- "Romanın 'En Çok Satanlar' listesine girdi! 150 Yıldız kazandın"
- "İlham perilerin kaçtı, yazamıyorsun. 50 Yıldız harcadın"
- "Kütüphanede gürültü yaptın! Kütüphane Nöbetine git"
- "Yayınevi toplantısı. 1. Yayınevi'ne git"

**KADER Kartları** (Global olaylar, tüm oyuncuları etkiler):
- "Kağıt fiyatlarına zam! Herkese 20 Yıldız öde"
- "Tüm kalemleri senin kalemim sağlam. Her oyuncu sana 30 Yıldız öder"
- "Korsan kitap baskını! 100 Yıldız ceza"
- "Yılın Yazarı seçildin! Herkes sana 10 Yıldız verir"

---

## 🖼️ UI/UX BİLEŞENLERİ

### Ana Ekranlar:
1. **Splash Screen**: Logo + yükleme animasyonu
2. **Ana Menü**: Oyuna Başla, Ayarlar, Çıkış
3. **Oyuncu Kurulum**: İsim, renk, avatar seçimi (2-4 oyuncu)
4. **Oyun Tahtası**: Ana oyun ekranı
5. **Oyun Bitti**: Kazanan kutlaması

### Oyun Tahtası Bileşenleri:

**1. TAHTA** (Merkezi eleman):
- 40 kare, dörtgen düzen
- Her karenin üzerinde:
  - **Üst kısımda renkli şerit** (renk grubunu gösterir)
  - **Roman adı** (küçük, bold, koyu yazı)
  - **Fiyat bedji** (altın rengi yuvarlak)
- **Köşe kareler** büyük, ikonlu, özel tasarım
- **Merkez alan**: 
  - "EDEBİNA" başlık (altın, büyük, Playfair Display fontu)
  - Kart destesi simgeleri
  - Oyun logosu

**2. HUD (Heads-Up Display)**:
Ekranın üst/yan kısmında:
- **Aktif Oyuncu Paneli**:
  - Avatar/İkon
  - İsim
  - Para miktarı (⭐ 1500)
  - Sahip olunan romanlar (küçük renkli kareler)
- **Zar Butonu**: Büyük, parlak, animasyonlu
- **Pause Butonu**: Sağ üst köşe

**3. DIYALOGLAR**:

**Soru Diyalogu:**
- Koyu arka plan (overlay)
- Beyaz/krem panel (glassmorphism efekti)
- Soru metni (büyük, okunabilir)
- 4 şık (buton şeklinde, hover efekti ile)
- Zamanlayıcı (opsiyonel)

**Kart Diyalogu:**
- Kart illüstrasyonu (büyük, merkezi)
- Kart metni (dekoratif font)
- Kapatma butonu

**Satın Alma Diyalogu:**
- Roman bilgileri (isim, fiyat, kira)
- "Satın Al" / "Vazgeç" butonları

**Duraklatma Menüsü:**
- Devam Et
- Ayarlar
- Ana Menüye Dön
- Oyundan Çık

**4. PİYONLAR**:
- Dairesel avatar (oyuncu rengi)
- Beyaz kenarlık
- Aktif oyuncuda **parlama efekti** (glow)
- **Hop animasyonu**: Kare kare atlayarak hareket eder (hızlı)

**5. ANİMASYONLAR**:
- **Tahta girişi**: Fade in + scale efekti
- **Zar atma**: Lottie animasyon (zar yuvarlanması)
- **Piyon hareketi**: Smooth hop animasyonu (kare kare)
- **Para değişimi**: Floating score (±200 ⭐ yukarı doğru kayar)
- **Kart çekme**: Kart döner, reveal olur
- **Satın alma**: Parıltı/confetti efekti

---

## 📱 PLATFORM & TEKNİK

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Fontlar**: 
  - **Playfair Display** (başlıklar, zarif)
  - **Poppins** (UI metinleri, okunabilir)
- **İkonlar**: Material Icons + Font Awesome
- **Animasyonlar**: Lottie + Flutter Animation
- **Ses Efektleri**: 
  - Zar atma, zar düşme
  - Kare üzerine gelme
  - Doğru/yanlış cevap
  - Satın alma

---

## 🎯 TASARIM HEDEFLERİ

### Görsel Mükemmellik:
1. **Premium Hissi**: 3D gölgeler, smooth animasyonlar, gradient efektler
2. **Okunabilirlik**: Yüksek kontrast, büyük fontlar, net hiyerarşi
3. **Tutarlılık**: Tüm UI elemanları aynı tema ve renk paletini kullanır
4. **Edebiyat/Akademik Vibe**: Zarif, kültürel, bilgi odaklı

### Kullanıcı Deneyimi:
1. **Akıcı Akış**: Minimal popup, net adımlar (Roll → Move → Action → Next)
2. **Anında Feedback**: Her aksiyonda görsel/işitsel geri bildirim
3. **Açık Öncelik**: Aktif oyuncu vurgulanır, geri kalan karartılır
4. **Erişilebilirlik**: Touch target minimum 48px, yüksek kontrast

### Teknik Gereksinimler:
1. **Responsive**: Farklı ekran boyutlarına uyum (tablet, telefon)
2. **Performans**: Smooth animasyonlar (60 FPS)
3. **Temiz Kod**: Component-based yapı, ayrı Provider logic

---

## 📊 OYUN İSTATİSTİKLERİ

- **40 Kare**: 4 köşe + 28 roman + 8 özel kare
- **8 Renk Grubu**: Her grupta 2-4 roman
- **50+ Soru**: 5 kategoride edebiyat soruları
- **2-4 Oyuncu**: Multiplayer desteği
- **~30-45 dk**: Ortalama oyun süresi

---

## 🚀 ÖNE ÇIKAN ÖZELLİKLER

1. **Eğitici İçerik**: Türk Edebiyatı hakkında bilgi öğrenme
2. **Streak Sistemi**: Ardışık doğru cevaplarla bonus
3. **Tema Değiştirme**: Dark/Light mode toggle
4. **Ses Yönetimi**: Müzik ve efekt ayarları
5. **Kaydetme/Yükleme**: Oyunu durdurma ve devam etme (gelecek)

---

## 💡 TASARIM İLHAM KAYNAKLARI

- **Monopoly**: Klasik board game düzeni
- **Modern Mobile Games**: Smooth animasyonlar, premium UI
- **Edebiyat & Kültür**: Türk edebiyatının zengin mirası

---

Bu özet, GLM-4.7 modeline **EDEBİNA** oyununu tam olarak anlatmalı ve oyunun ruhuna uygun UI/UX tasarımları üretmesini sağlamalıdır. 

**Oyunun Ana Özellikleri:** Türk edebiyatı temalı, eğitici, zarif, premium ve eğlenceli bir masa oyunu deneyimi.
