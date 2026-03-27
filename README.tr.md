[![English](https://img.shields.io/badge/Lang-English-blue)](README.md)

# 📚 Edebina: Türk Edebiyatı Masa Oyunu

**Edebina**, Türk Edebiyatı dönemlerini, yazarlarını ve eserlerini öğrenmeyi interaktif ve eğlenceli hale getirmek için **Flutter** ile geliştirilmiş, etkileyici bir çok oyunculu mobil masa oyunudur. Klasik Monopoly tarzı mekanikleri eğitici quizler, "Şans/Kader" kartları ve zengin işitsel-görsel deneyimle birleştirir.

## 🚀 Temel Özellikler

### 🎮 Oynanış
- **Yerel Çok Oyunculu:** Tek cihazda **2-6 oyuncu** desteği
- **Dinamik Sıra Belirleme:** Özyineli beraberlik kırıcı sistemli otomatik zar atışı
- **Eğitici Quizler:** Türk edebiyatını kapsayan 7 soru kategorisi
- **İlerleme Sistemi:** Ustalık rütbeleri (Çırak → Kalfa → Usta) bonus ödüllerle
- **Özel Karolar:** Kütüphane (Hapishane), İmza Günü, Kıraathane, Teşvik

### 🎨 Görsel Tasarım
- **Dark Academia Teması:** Şık tipografi ile sıcak, samimi kütüphane estetiği
- **3D Zar Animasyonu:** 6 yüzeli gerçekçi küp animasyonu, görünür dönüş, köşe boşlukları giderilmiş
- **Çevre HUD:** Oyuncu panelleri tahta kenarlarında konumlandırılır (4 ve altı için köşeler, 5-6 için köşeler + orta kenarlar)
- **Duyarlı Düzen:** SafeArea desteği ile çeşitli ekran boyutları için optimize edilmiş

### 🔊 Ses Sistemi
- **Bağlam Farklı BGM:** Menü ve Oyun içi için ayrı çalma listeleri, sorunsuz geçişler
- **Ses Kontrolleri:** Müzik (35% kazanç sınırı) ve SFX için bağımsız kaydırıcılar
- **Geçiş Efektleri:** Yumuşak 2 saniyelik açılış, 1 saniyelik kapanış
- **Zengin SFX:** Zar atışları, piyon adımları, kart çevirmeleri, doğru/yanlış cevaplar

## 🛠️ Teknolojiler

### Çerçeve ve Dil
- **Flutter** (Dart) - Çok platformlu mobil UI çerçevesi
- **Dart** - Programlama dili (SDK ^3.10.4)

### Durum Yönetimi
- **flutter_riverpod** (^2.4.9) - Reaktif durum yönetimi
- **Provider** pattern - Temiz mimari durum kapları

### UI ve Animasyonlar
- **flutter_animate** (^4.5.0) - Bildirimsel animasyon kütüphanesi
- **google_fonts** (^6.1.0) - Tipografi (Cinzel Decorative, Pinyon Script, Poppins, Crimson Text)
- **font_awesome_flutter** (^10.6.0) - İkonlar
- **confetti** (^0.7.0) - Zafer kutlama efektleri
- **lottie** (^3.1.0) - JSON tabanlı animasyonlar
- **shimmer** (^3.0.0) - Yükleme efektleri

### Ses
- **audioplayers** (^6.1.0) - Bağlam farkında çalma listeleri ile ses oynatma

### Firebase (İsteğe Bağlı)
- **firebase_core** (^3.6.0)
- **firebase_auth** (^5.3.1)
- **cloud_firestore** (^5.4.4)

### Araçlar
- **uuid** (^4.3.3) - Benzersiz oyuncu tanımlama
- **auto_size_text** (^3.0.0) - Duyarlı metin boyutlandırma
- **shared_preferences** (^2.2.2) - Yerel kalıcılık
- **equatable** (^2.0.8) - Değer eşitliği karşılaştırmaları
- **http** (^1.2.1) - Ağ istekleri

## 📁 Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası, Firebase başlatma
│
├── core/                             # Paylaşılan araçlar ve sabitler
│   ├── constants/
│   │   └── game_constants.dart       # Oyun dengesi, animasyon zamanlamaları
│   ├── managers/
│   │   ├── audio_manager.dart         # Bağlam farkında BGM sistemi (Menü/Oyun)
│   │   └── sound_manager.dart         # Eski ses yöneticisi
│   ├── motion/
│   │   └── motion_constants.dart      # Animasyon süreleri ve eğrileri
│   ├── theme/
│   │   ├── game_theme.dart           # Ana tema tanımlamaları
│   │   └── theme_tokens.dart         # Tema tokenları (açık/koyu)
│   └── utils/
│       ├── board_layout_config.dart   # 7x8 ızgara düzeni hesaplamaları
│       └── board_layout_helper.dart   # Düzen yardımcı fonksiyonları
│
├── models/                           # Etki alanı modelleri
│   ├── board_config.dart             # Tahta yapılandırması (26 karo)
│   ├── game_card.dart                # Şans/Kader kartı tanımlamaları
│   ├── game_enums.dart               # Enum'lar (QuestionCategory, TileType, GamePhase, vb.)
│   ├── player.dart                   # Ustalık sistemli oyuncu varlığı
│   ├── question.dart                 # Soru modeli
│   └── tile_type.dart                # Karo türü tanımlamaları
│
├── providers/                        # Durum yönetimi (Riverpod)
│   ├── app_bootstrap.dart            # Uygulama başlatma sağlayıcısı
│   ├── firebase_providers.dart       # Firebase sağlayıcıları
│   ├── game_notifier.dart            # Ana oyun durumu ve mantığı
│   ├── repository_providers.dart     # Depo sağlayıcıları
│   └── theme_notifier.dart           # Tema durumu yönetimi
│
├── presentation/                     # UI katmanı
│   ├── dialogs/
│   │   ├── pause_dialog.dart         # Oyun içi duraklatma menüsü
│   │   ├── settings_dialog.dart      # Ses ayarları (ses kaydırıcıları)
│   │   ├── modern_question_dialog.dart # Gerilim gecikmeli quiz diyaloğu
│   │   ├── card_dialog.dart          # Şans/Kader kartı diyaloğu
│   │   ├── notification_dialogs.dart # Kütüphane, Sıra Atlama diyalogları
│   │   └── ...
│   ├── screens/
│   │   ├── splash_screen.dart        # Açılış ekranı
│   │   ├── main_menu_screen.dart     # Ana menü
│   │   ├── setup_screen.dart         # Oyuncu kurulumu (2-6 oyuncu)
│   │   ├── victory_screen.dart       # Zafer kutlama ekranı
│   │   └── collection_screen.dart   # Koleksiyon görüntüleme
│   └── widgets/
│       ├── board_view.dart           # Efekt katmanlı ana oyun tahtası
│       ├── board/
│       │   ├── effects_overlay.dart   # Diyaloglar, konfeti, yüzen efektler
│       │   ├── player_hud.dart        # Oyuncu HUD panelleri (çevre düzeni)
│       │   ├── center_area.dart       # Zar atıcılı merkez alan
│       │   ├── tile_grid.dart         # 7x8 karo ızgarası
│       │   └── turn_order_dialog.dart # Sıra belirleme sonuc diyaloğu
│       ├── animations/
│       │   └── card_deal_transition.dart # Kart dağıtma animasyonu
│       ├── quiz/
│       │   └── option_button.dart      # Soru seçenek butonları
│       ├── common/
│       │   ├── bouncing_button.dart    # Animasyonlu zıplayan buton
│       │   └── game_button.dart        - Standartlaştırılmış buton bileşeni
│       ├── dice_roller.dart          # Zar animasyonu bileşeni
│       ├── pawn_widget.dart           # 3D tarzı piyon bileşeni
│       ├── game_log.dart              # Oyun içi olay günlüğü
│       └── player_scoreboard.dart     # Oyuncu skor panosu bileşeni
│
├── data/                             # Veri katmanı
│   ├── board_config.dart             # Tahta yapılandırması (26 karo)
│   ├── game_cards.dart               # Şans/Kader kartı tanımlamaları
│   ├── datasources/                  # Veri kaynakları
│   ├── models/                       # Veri aktarım nesneleri
│   ├── mappers/                      # Model ↔ Varlık eşleştirme
│   └── repositories/                 # Depo uygulamaları
│
├── domain/                           # İş mantığı (Saf Dart)
│   ├── domain.dart                   # Domain dışa aktarımları
│   └── repositories/                 # Depo arayüzleri
│
└── services/                         # Uygulama düzeyi hizmetler
    └── streak_service.dart           # Kullanıcı sergi takibi
```

## 🎯 Soru Kategorileri

| Kategori | Türkçe Adı | Açıklama |
|----------|------------|----------|
| Ben Kimim? | Ben Kimim? | Kişisel tanımlama soruları |
| Türk Edebiyatında İlkler | Edebiyatta İlkler | Öncü eserler ve yazarlar |
| Edebiyat Akımları | Edebiyat Akımları | Sanat akımları ve dönemler |
| Edebi Sanatlar | Edebi Sanatlar | Şiir, nesir ve teknikler |
| Eser-Karakter | Eser-Karakter | Kitap ve karakter tanımlama |
| Teşvik | Teşvik | Bonus ödüller ve bilginler |

## 🎲 Oyun Mekanikleri

### Sıra Belirleme
- **Otomatik Zar Atışı:** Tüm oyuncular animasyonlu zarlarla otomatik atar
- **Beraberlik Kırıcı Sistem:** Benzersiz en yüksek atış belirlenene kadar özyineli yeniden atışlar
- **Görsel Geri Bildirim:** Sıra belirleme diyaloğu nihai oyuncu sırasını gösterir

### Hareket ve Zar
- **Çift Zar Kuralları:**
  - **1. veya 2. Çift:** Tekrar at (bonus tur)
  - **3. Ardışık Çift:** 2 tur için Kütüphaneye gönderilir
- **Kütüphane Önceliği:** Kütüphaneye iniş anında turu sonlandırır (Çift bonusunu geçersiz kılar)
- **Piyon Hareketi:** Adım başına 450ms, eşzamanlı ses geri bildirimi

### Ustalık Sistemi
Aynı kategori/zorlukta **3 soruyu doğru cevaplayarak** rütbeler elde edin:
- **Çırak** → 1x ödül çarpanı
- **Kalfa** → 2x ödül çarpanı (Çırak gerektirir)
- **Usta** → 3x ödül çarpanı (Kalfa gerektirir)

### Özel Karolar
| Karo | Etki |
|------|------|
| 📚 **Kütüphane** | Hapishane - Sonraki 2 turu atla |
| ✍️ **İmza Günü** | İmza Günü - Hayran buluşma etkinliği |
| 🏛️ **Kıraathane** | Dükkan - Edebi alıntıları yıldızlarla satın al |
| 🎲 **Teşvik** | Bonus - Ücretsiz yıldız ödülü |
| ⚖️ **Şans/Kader** - Rastgele efektli Şans/Kader kartları |

## ✨ Son Eklenen Özellikler

### Yeni Kart Etkileşimleri
- **Yazıcı/Mürekkep Sorunu Dialogu:** "Yazıcı tıkandı" ve "Mürekkep bitti" kartları için özel themed popup
- **Otomatik Kapanma:** 1.8 saniye sonra otomatik kapanır
- **Mürekkep Lekesi Teması:** Görsel olarak uyumlu tasarım

### Oyuncu Deneyimi İyileştirmeleri
- **Soru Karıştırma:** Her oyunda sorular kendi kategorilerinde rastgele sırayla gelir
- **Zar Animasyonu:** Köşe boşlukları giderilmiş gerçekçi 3D zar animasyonu

## 🚀 Kurulum ve Başlangıç

### Ön Koşullar
- Flutter SDK 3.10.4 veya üzeri
- Dart 3.10.4 veya üzeri
- Android Studio / VS Code (Flutter uzantısı ile)
- Test için fiziksel cihaz veya emülatör

### Kurulum Adımları

1. **Depoyu klonlayın:**
   ```bash
   git clone https://github.com/sametunsal/literature_board_game.git
   cd literature_board_game
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

### Sürüm İçin Oluşturma

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🎮 Nasıl Oynanır

1. **Ana Menü:** "Oyunu Başlat"a tıklayın
2. **Kurulum:** 2-6 oyuncu seçin, avatarlar ve isimler belirleyin
3. **Sıra Belirleme:** Oyuncuların başlangıç sırasını belirlemek için zar attığını izleyin
4. **Zar At:** Tahta etrafında hareket etmek için zar butonuna dokunun
5. **Soruları Cevapla:** Kategori karolarına indiğinizde yıldız kazanmak için doğru cevaplayın
6. **Kazanma Koşulu:** "Usta" rütbesine ulaşan ilk oyuncu kazanır!

## 📸 Ekran Görüntüleri

*Not: Ekran görüntüleri eklenecek*

- Dark Academia temalı Ana Menü
- Oyuncu Kurulum ekranı (6 oyuncu desteği)
- Çevre HUD düzenli Oyun tahtası
- Gerilim gecikmeli Soru diyaloğu
- Konfetili Zafer kutlaması

## 🔧 Geliştirme İlkeleri

### Yeni Özellikler Ekleme

1. **Önce Durum:** `GameNotifier.dart` içinde durum tanımlayın veya yeni notifier'lar oluşturun
2. **Etki Alanı Mantığı:** İş mantığını `domain/` katmanında saf tutun
3. **UI Bileşenleri:** `presentation/widgets/` içinde yeniden kullanılabilir widget'lar oluşturun
4. **Animasyonlar:** `MotionDurations` ve `MotionCurves` sabitlerini kullanın
5. **Ses:** Tüm ses oynatma için `AudioManager.instance` kullanın

### Ses İlkeleri

**Ses Efektleri Çalma:**
```dart
// SFX (ses efektleri)
AudioManager.instance.playSfx('audio/dice_roll.wav');
AudioManager.instance.playClick();
AudioManager.instance.playPawnStep();
```

**Müzik Bağlamı Değiştirme:**
```dart
// Oyun müziğine geç (oyun başladığında)
await AudioManager.instance.playInGameBgm();

// Menü müziğine geç (menüye döndüğünüzde)
await AudioManager.instance.playMenuBgm();

// Ses seviyelerini ayarla
AudioManager.instance.setBgmVolume(0.7); // 0.0 - 1.0
AudioManager.instance.setSfxVolume(1.0);
```

### Animasyon Standartları

**Her zaman proje sabitlerini kullanın:**
```dart
// ✅ İyi
await Future.delayed(MotionDurations.slow.safe);
curve: MotionCurves.emphasized;

// ❌ Kötü
await Future.delayed(const Duration(milliseconds: 300));
curve: Curves.easeInOut;
```

### Bileşen Kullanımı

**Standart Buton:**
```dart
GameButton(
  text: 'Zar At',
  onPressed: () => gameNotifier.rollDice(),
  variant: GameButtonVariant.primary,
)
```

## 📖 Belgeler

- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Detaylı mimari belgeleri
- [`STATE_MANAGEMENT.md`](docs/STATE_MANAGEMENT.md) - Durum yönetimi kılavuzu
- [`CLAUDE.md`](CLAUDE.md) - Proje bağlamı ve kodlama standartları

## 🐛 Bilinen Sorunlar

Şu anda yok.

## 🔄 Sürüm Geçmişi

- **v1.0.1** - Yazıcı/Mürekkep sorunu themed dialog, soru karıştırma, zar köşe boşlukları giderildi
- **v1.0.0** - 6 oyuncu desteği, bağlam farkında ses ve çevre HUD düzeni ile ilk sürüm

## 📄 Lisans

Bu proje eğitim amaçlı oluşturulmuştur.

## 👥 Emekler

Flutter ve Dart kullanılarak ❤️ ile geliştirilmiştir.

---

**Edebina** - Türk Edebiyatını interaktif hale getiriyor, bir soru bir soru.
