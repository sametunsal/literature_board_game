# GitHub Upload Guide for Roo Code Integration

## Adım 1: GitHub'da Repository Oluşturun

1. [GitHub](https://github.com) sitesine gidin ve giriş yapın
2. Sağ üst köşedeki **+** ikonuna tıklayın ve **New repository**'yi seçin
3. Repository bilgilerini doldurun:
   - **Repository name**: `literature_board_game` (veya istediğiniz bir isim)
   - **Description**: A Flutter-based board game inspired by classic literature
   - **Visibility**: Public veya Private (Roo Code için Public önerilir)
   - ⚠️ **"Initialize this repository"** kutucuklarını İŞARETLEMEYİN (zaten local'de commit yaptık)
4. **Create repository** butonuna tıklayın

## Adım 2: GitHub Linkini Kopyalayın

Repository oluşturulduktan sonra görüntülenen ekranda:
- **Quick setup** bölümünden HTTPS linkini kopyalayın
- Örnek: `https://github.com/kullanici-adi/literature_board_game.git`

## Adım 3: Local Repository'yi GitHub'a Bağlayın

Aşağıdaki komutları terminalde çalıştırın (kopyaladığınız linki kendi repository linkinizle değiştirin):

```bash
# GitHub repository'sini remote olarak ekle
git remote add origin https://github.com/KULLANICI-ADI/literature_board_game.git

# Ana branch'i 'main' olarak yeniden adlandır (opsiyonel ama önerilir)
git branch -M main

# Kodları GitHub'a gönder
git push -u origin main
```

## Adım 4: GitHub Şifresi/Token İsteği

Eğer 2FA (iki faktörlü doğrulama) kullanıyorsanız, GitHub şifre yerine **Personal Access Token** girmeniz gerekebilir:

1. GitHub'da → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. **Generate new token** (classic) → Token'ı oluşturun
3. Bu token'ı şifre yerine kullanın

## Adım 5: GitHub Repository'sini Roo Code'a Paylaşın

GitHub'a yükleme tamamlandıktan sonra:

1. Repository'nize gidin ve URL'yi kopyalayın
2. Örnek URL: `https://github.com/kullanici-adi/literature_board_game`

## Roo Code Kullanımı İçin Bilgiler

Roo Code bu GitHub repository'sini şu şekilde kullanabilir:

### Seçenek A: Repository URL'sini Doğrudan Verme
```
Repository URL: https://github.com/kullanici-adi/literature_board_game
```

### Seçenek B: Clone Komutu ile Yükleme
Roo Code bu komutla projeyi klonlayabilir:
```bash
git clone https://github.com/kullanici-adi/literature_board_game.git
```

### Seçenek C: GitHub CLI ile Yükleme (GH CLI kuruluysa)
```bash
gh repo clone kullanici-adi/literature_board_game
```

## Proje Kurulum Talimatları (Roo Code İçin)

GitHub'dan çekilen proje için kurulum adımları:

```bash
# Proje dizinine gidin
cd literature_board_game

# Flutter bağımlılıklarını yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## Proje Özellikleri Özeti

- **Platform**: Flutter (Cross-platform - Android, iOS, Web, Desktop)
- **State Management**: Riverpod
- **Özellikler**:
  - 40-kareli tahta oyunu
  - Zar atma ve hareket sistemi
  - Para yönetimi
  - Edebiyat soruları
  - Animasyonlar
  - Özel oyun mekanikleri

## Yardımcı Komutlar

```bash
# Durumu kontrol et
git status

# Yeni değişiklikleri görüntüle
git log --oneline

# Değişiklikleri GitHub'a yolla (sonradan)
git add .
git commit -m "Açıklama"
git push
```

## Sorun Giderme

### "Authentication failed" hatası
- GitHub hesabınızda 2FA varsa Personal Access Token kullanın
- Git Credential Manager'ı güncelleyin

### "remote origin already exists" hatası
```bash
git remote remove origin
git remote add origin https://github.com/YENI-KULLANICI/literature_board_game.git
```

### Branch isimlendirme
```bash
git branch -M main
git push -u origin main
```

## Başarı Kontrolü

GitHub repository'sine gittiğinizde şunları görmelisiniz:
- ✅ README.md dosyası
- ✅ lib/ klasörü ve tüm Dart dosyaları
- ✅ pubspec.yaml dosyası
- ✅ Diğer proje dosyaları

---

**Not**: Roo Code bu repository'i klonladıktan sonra projeyi doğrudan çalıştırabilir ve üzerinde geliştirmeler yapabilir.
