# Unity Editor Setup Rehberi

> Bu doküman Unity Editor'de adım adım ne yapılacağını anlatır.
> Kod YAZILMAZ. Sadece Editor üzerindeki işlemler.

---

## 1. Unity Version

| Öneri | Açıklama |
|-------|----------|
| **Unity 2022.3 LTS** | Uzun süreli destek, stabil, geniş dokümantasyon |
| **Unity 6 (6000.0 LTS)** | Daha yeni, URP gelişmiş, ama LTS sürümü seç |

> Unity Hub'da "Installs" → "Install Editor" → **LTS** sekmesinden seç.
> Modules: **Windows Build (IL2CPP)** + **Android Build** (mobil hedef varsa)

---

## 2. Yeni Proje Oluşturma

1. Unity Hub → **New Project**
2. Template: **3D (URP)** — "Universal 3D" template
   - Neden URP? Mobil uyumlu, modern, 3D zar için uygun
   - Neden 3D? Board XZ düzleminde, 3D zar animasyonu var
3. Project Name: `LiteratureBoardGame`
4. Location: istediğin klasör

> **NOT:** 3D template seç ama oyun aslında top-down 2D görünümlü.
> Camera yukarıdan bakacak, board düz zeminde duracak.

---

## 3. Render Pipeline: URP

Template zaten URP ile geliyor, ekstra bir şey yapmana gerek yok.

Kontrol etmek için:
- `Edit` → `Project Settings` → `Graphics`
- `Scriptable Render Pipeline Settings` alanında bir URP asset görmelisin
- Eğer boşsa: `Assets/_Project/Settings/` klasörüne sağ tık → `Create` → `Rendering` → `URP Asset` → adını `URPSettings` koy → buraya ata

---

## 4. 2D mi 3D mü?

**3D Proje** ama **2D gibi görünen** bir oyun:

| Öğe | Yaklaşım |
|-----|----------|
| Board tiles | 3D cube/quad, XZ düzleminde, y=0 |
| Zar | 3D objeler, fizik ile atılır |
| Pawn'lar | 3D silindir/küre, tile'ların üzerinde |
| Kamera | **Orthographic**, yukarıdan aşağı bakış |
| UI (Dialog, HUD) | Unity Canvas (Screen Space - Overlay) |

### Kamera Ayarları

Main Camera objesini seç ve Inspector'da şunları ayarla:

```
Position:    X: 3.0   Y: 12.0   Z: 3.5
Rotation:    X: 90     Y: 0      Z: 0
Projection:  Orthographic
Size:        6
Background:  #1A1A2E (koyu lacivert)
```

> Bu ayar board'u yukarıdan tam olarak gösterir.
> Board merkez noktası yaklaşık (3, 0, 3.5) civarında.

---

## 5. Gerekli Package'lar

`Window` → `Package Manager` → her biri aratıp **Install** et:

| Package | Neden? | Package Manager'de Adı |
|---------|--------|----------------------|
| **TextMeshPro** | Tile isimleri, UI text'leri | "TextMeshPro" |
| **Universal RP** | Render pipeline (zaten yüklü olmalı) | "Universal RP" |
| **2D Sprite** | Tile ikonları, pawn sprite'ları | "2D Sprite" |
| **Input System** | İleride touch input için | "Input System" |
| **Cinemachine** | Kamera animasyonları (opsiyonel) | "Cinemachine" |
| **Addressables** | Büyük veri yönetimi (opsiyonel) | "Addressables" |

### Zorunlu Olmayan Ama Faydalı

| Package | Açıklama |
|---------|----------|
| **ProBuilder** | Basit 3D şekiller (zar, tile) |
| **ProGrids** | Grid tabanlı yerleştirme |
| **Animation Rigging** | Pawn animasyonları |

---

## 6. Project Settings Ayarları

### 6.1 Player Settings

`Edit` → `Project Settings` → `Player`:

```
Company Name:     LiteratureBoardGame
Product Name:     Edebiyat Oyunu
Default Icon:     (sonra eklenecek)
Resolution:       Landscape Left (yatay)
Fullscreen Mode:  Fullscreen Window
Target FPS:       60
```

### 6.2 Quality Settings

`Edit` → `Project Settings` → `Quality`:

- Sadece **1 level** bırak: "Medium"
- Diğerlerini sil
- Medium level'da:
  - `Pixel Light Count`: 4
  - `Texture Quality`: Full Res
  - `Anisotropic Textures`: Disabled
  - `Anti Aliasing`: 4x Multi Sampling
  - `V Sync Count`: Every V Blank

---

## 7. Tags (Etiketler)

`Edit` → `Project Settings` → `Tags and Layers` → `Tags` bölümüne ekle:

```
Manager
Player
Tile
Pawn
Dice
Camera
UI
```

### Ne işe yarar?
Tag'ler objeleri koda bulmamızı sağlar. Örneğin "Player" tag'i olan
objeleri bulup üzerinde işlem yapabiliriz.

---

## 8. Layers (Katmanlar)

Aynı yerde `Layers` bölümüne ekle:

```
Layer 6:  Board
Layer 7:  Pawn
Layer 8:  Dice
Layer 9:  UI3D
Layer 10: Ground
```

### Ne işe yarar?
Layer'lar kameranın neyi göreceğini, fiziklerin nelerle etkileşime
gireceğini kontrol eder. Örneğin UI kamerası sadece UI layer'ı görür.

### Layer-Based Camera Ayarı (İleride)

Main Camera → `Culling Mask`:
- ✅ Default
- ✅ Board
- ✅ Pawn
- ✅ Dice
- ✅ Ground
- ❌ UI3D (UI3D ayrı kamera)

---

## 9. Sorting Layers (UI için)

**NOT:** Sorting Layer'lar SpriteRenderer kullanan 2D objeler içindir.
Bizim projemizde Canvas UI kullandığımız için Sorting Layer çok kritik değil,
ama varsa sırası şu olsun:

`Edit` → `Project Settings` → `Tags and Layers` → `Sorting Layers`:

```
0: Background
1: Board
2: Tile
3: Pawn
4: Effect
5: UI
```

---

## 10. Klasör Yapısını Oluştur

Unity'de **Project penceresinde** sağ tık → `Create` → `Folder`:

```
Assets/
├── _Project/
│   ├── 0_Core/
│   │   ├── Constants/
│   │   ├── Events/
│   │   ├── StateMachine/
│   │   └── Utils/
│   ├── 1_Data/
│   │   ├── ScriptableObjects/
│   │   └── DataAssets/
│   │       ├── Questions/
│   │       ├── Cards/
│   │       ├── Quotes/
│   │       └── Board/
│   ├── 2_Models/
│   │   └── Enums/
│   ├── 3_Services/
│   ├── 4_Board/
│   ├── 5_Player/
│   ├── 6_UI/
│   │   ├── Screens/
│   │   ├── HUD/
│   │   ├── Dialogs/
│   │   └── Components/
│   └── 7_Audio/
│
├── Scenes/
├── Prefabs/
│   ├── Board/
│   ├── Players/
│   ├── UI/
│   │   ├── Dialogs/
│   │   └── HUD/
│   └── Dice/
│
├── Art/
│   ├── Tiles/
│   ├── Players/
│   ├── UI/
│   ├── Cards/
│   └── Background/
│
├── Audio/
│   ├── SFX/
│   └── Music/
│
├── Fonts/
├── ThirdParty/
├── Resources/
└── Settings/           ← URP asset'leri burada
```

> `_` ön eki ile başlayan klasörUnity'de üste çıkar, kolay bulursun.

---

## 11. Scenes

### 11.1 Scene Oluşturma

`File` → `New Scene` → `Basic (URP)` → kaydet:

| Scene Adı | Yol | Açıklama |
|-----------|-----|----------|
| `MainMenu` | `Assets/Scenes/MainMenu.unity` | Başlangıç ekranı |
| `Game` | `Assets/Scenes/Game.unity` | Ana oyun sahnesi |

> Şimdilik sadece **Game** sahnesiyle çalışacağız.

### 11.2 Build Settings

`File` → `Build Settings`:
1. `Add Open Scenes` ile her iki sahneyi ekle
2. Sıralama:
   - `0: Scenes/MainMenu`
   - `1: Scenes/Game`

---

## 12. Game Scene Hierarchy (Nesne Ağacı)

**Game.unity** sahnesini aç. Hierarchy penceresinde şu boş GameObject'leri oluşturacaksın.

### Nasıl Oluşturulur?
- Hierarchy'de sağ tık → `Create Empty`
- Inspector'da ismini değiştir
- Position'ı sıfırla (Transform → sağ üst ⚙️ → Reset)

### Tam Hierarchy Yapısı:

```
Game (Scene)
│
├── [MANAGERS]                    ← Boş GameObject, parent
│   ├── GameManager               ← Oyun döngüsü
│   ├── TurnManager               ← Sıra yönetimi
│   ├── DiceService               ← Zar sistemi
│   ├── TileEffectService         ← Tile efektleri
│   ├── QuestionService           ← Soru çekme
│   ├── CardService               ← Şans/Kader kart
│   ├── ShopService               ← Kıraathane
│   ├── MasteryService            ← Level sistemi
│   ├── RewardService             ← Ödül hesaplama
│   ├── AudioManager              ← Ses yönetimi
│   └── BotService                ← Bot AI
│
├── [BOARD]                       ← Boş GameObject, parent
│   ├── BoardParent               ← Tile'lar bunun altında oluşur
│   │   ├── Tile_0_BASLANGIÇ      ← (runtime'da oluşur)
│   │   ├── Tile_1_TürkEd...     ← (runtime'da oluşur)
│   │   └── ...                   ← (26 tile)
│   └── BoardCenter               ← Board ortasının referans noktası
│       Position: X:3 Y:0 Z:3.5
│
├── [PLAYERS]                     ← Boş GameObject, parent
│   ├── Player_0                  ← Oyuncu pawn'ı (sonradan prefab'dan)
│   ├── Player_1                  ←
│   ├── Player_2                  ←
│   └── Player_3                  ← (max 4 oyuncu)
│
├── [DICE]                        ← Boş GameObject, parent
│   ├── DiceTray                  ← Zar atma alanı
│   │   Position: X:3 Y:1 Z:-2   ← Board'un altında
│   ├── Dice_1                    ← İlk zar (3D)
│   └── Dice_2                    ← İkinci zar (3D)
│
├── [CAMERA]                      ← Boş GameObject, parent
│   ├── Main Camera               ← Board kamerası (orthographic)
│   └── Dice Camera               ← Zar close-up (opsiyonel)
│
├── [LIGHTING]                    ← Boş GameObject, parent
│   ├── Directional Light         ← Ana ışık (güneş)
│   │   Rotation: X:50 Y:-30 Z:0
│   │   Color: Beyaz, Intensity: 1
│   └── Ambient Light             ← Global illumination
│       Window → Rendering → Lighting → Settings
│       Ambient: Dark Blue (#1A1A2E)
│
├── [GROUND]                      ← Board altı zemin
│   └── GroundPlane
│       Position: X:3 Y:-0.5 Z:3.5
│       Scale: X:10 Y:1 Z:10
│       Material: Koyu renk
│       Layer: Ground
│
└── [UI]                          ← Canvas (otomatik oluşur)
    └── GameCanvas                ← Ana UI Canvas
        ├── HUD                   ← Üst bar bilgileri
        │   ├── TopBar
        │   │   ├── PlayerNameText
        │   │   ├── StarCounter
        │   │   ├── TurnIndicator
        │   │   └── PhaseText
        │   └── DiceButton
        │       └── DiceButton_BG
        ├── DialogContainer       ← Tüm dialoglar burada
        │   ├── QuestionDialog
        │   ├── CardDialog
        │   ├── ShopDialog
        │   ├── LibraryPenaltyDialog
        │   ├── TurnSkippedDialog
        │   ├── TurnOrderDialog
        │   ├── PromotionDialog
        │   └── SigningDayDialog
        ├── PlayerPanels          ← Tüm oyuncu bilgileri
        │   ├── PlayerPanel_0
        │   ├── PlayerPanel_1
        │   ├── PlayerPanel_2
        │   └── PlayerPanel_3
        └── FloatingEffects       ← Popup yıldız/text efektleri
```

### Manager Objelerine Tag Atama

Her manager objesini seç → Inspector → `Tag` → **Manager**:

```
GameManager       → Tag: Manager
TurnManager       → Tag: Manager
DiceService       → Tag: Manager
TileEffectService → Tag: Manager
QuestionService   → Tag: Manager
CardService       → Tag: Manager
ShopService       → Tag: Manager
MasteryService    → Tag: Manager
RewardService     → Tag: Manager
AudioManager      → Tag: Manager
BotService        → Tag: Manager
```

### BoardParent'a Tag Atama

```
BoardParent → Tag: Tile
Tile_*      → Tag: Tile (runtime'da oluşur)
```

### Pawn'lara Tag Atama

```
Player_* → Tag: Player
```

---

## 13. İlk Prefab'lar

Prefab = Tekrar kullanılabilir şablon obje. Bir kere yap, her yerde kullan.

### Prefab Oluşturma Yöntemi

1. Hierarchy'de objeyi oluştur
2. Project penceresinde `Prefabs/` altındaki hedef klasöre sürükle
3. Mavi renge dönerse prefab olmuştur

### Oluşturulacak Prefab'lar

#### 13.1 `Prefabs/Board/Tile.prefab`

1. Hierarchy'de sağ tık → `3D Object` → `Cube`
2. İsim: `Tile`
3. Inspector ayarları:
   ```
   Position:    X:0  Y:0  Z:0
   Scale:       X:0.9  Y:0.15  Z:0.9
   ```
4. `Add Component` → arat: `Box Collider` → ekle (yoksa)
5. Material ata: `Assets/Art/Tiles/Tile_Default.mat` (sonradan oluşturulacak)
6. `Assets/Prefabs/Board/` klasörüne sürükle → prefab oluşur
7. Hierarchy'dekiini sil (prefab olarak kullanacağız)

#### 13.2 `Prefabs/Players/PlayerPawn.prefab`

1. Hierarchy'de sağ tık → `3D Object` → `Cylinder`
2. İsim: `PlayerPawn`
3. Inspector ayarları:
   ```
   Position:    X:0  Y:0.2  Z:0
   Scale:       X:0.3  Y:0.15  Z:0.3
   Rotation:    X:90  Y:0  Z:0   (yatarak disk gibi)
   Tag:         Player
   Layer:       Pawn
   ```
4. `Add Component` → `Mesh Renderer` (zaten var)
5. Renk: Her oyuncu için farklı material (sonradan)
6. `Assets/Prefabs/Players/` klasörüne sürükle

#### 13.3 `Prefabs/Dice/Dice.prefab`

1. Hierarchy'de sağ tık → `3D Object` → `Cube`
2. İsim: `Dice`
3. Inspector ayarları:
   ```
   Scale:       X:0.5  Y:0.5  Z:0.5
   Tag:         Dice
   Layer:       Dice
   ```
4. `Add Component` → `Rigidbody` (fizik için)
   - Mass: 1
   - Drag: 1
   - Angular Drag: 5
5. Zar yüzeylerine sayı texture'ları (sonradan)
6. `Assets/Prefabs/Dice/` klasörüne sürükle
7. İkinci zar için aynı prefab'ı kullan (2 kez instantiate)

#### 13.4 `Prefabs/Board/BoardParent.prefab`

1. Hierarchy'de boş GameObject oluştur → isim: `BoardParent`
2. `Assets/Prefabs/Board/` klasörüne sürükle
3. Runtime'da BoardGenerator tile'ları bunun altına ekleyecek

#### 13.5 UI Prefab'ları (Her biri ayrı prefab)

`Prefabs/UI/Dialogs/` altına:

| Prefab Adı | İçerik |
|------------|--------|
| `QuestionDialog.prefab` | Panel + Soru text + 4 buton + İpucu buton |
| `CardDialog.prefab` | Panel + Kart görseli + Açıklama text + Tamam butonu |
| `ShopDialog.prefab` | Panel + Quote listesi + Satın al butonları + Kapat |
| `LibraryPenaltyDialog.prefab` | Panel + Ceza mesajı + Tamam butonu |
| `TurnSkippedDialog.prefab` | Panel + Atlama mesajı + Tamam butonu |
| `TurnOrderDialog.prefab` | Panel + Oyuncu sıralaması listesi + Başla butonu |
| `PromotionDialog.prefab` | Panel + Level artış mesajı + Tamam butonu |
| `SigningDayDialog.prefab` | Panel + Flavor text + Tamam butonu |

`Prefabs/UI/HUD/` altına:

| Prefab Adı | İçerik |
|------------|--------|
| `PlayerPanel.prefab` | İkon + İsim + Yıldız sayısı + Level bilgisi |
| `DiceButton.prefab` | Zar ikonu buton |
| `StarCounter.prefab` | Yıldız ikonu + Sayı text |
| `TurnIndicator.prefab` | Ok/şerit göstergesi |

### UI Prefab Oluşturma Yöntemi

1. Hierarchy'de: sağ tık → `UI` → `Panel` (veya Button, Text)
2. Alt elemanlarını ekle (text, buton, image vs.)
3. `Rect Transform` ile boyut ve pozisyon ayarla
4. `Assets/Prefabs/UI/Dialogs/` (veya HUD/) klasörüne sürükle
5. Hierarchy'dekini sil

---

## 14. Material'lar

`Assets/Art/Tiles/` klasöründe sağ tık → `Create` → `Material`:

| Material Adı | Renk | Kullanım |
|-------------|------|----------|
| `Mat_Tile_Start` | Yeşil (#4CAF50) | Başlangıç tile |
| `Mat_Tile_Category` | Açık Mavi (#64B5F6) | Kategori soru tile |
| `Mat_Tile_Chance` | Sarı (#FFD54F) | Şans tile |
| `Mat_Tile_Fate` | Kırmızı (#EF5350) | Kader tile |
| `Mat_Tile_Shop` | Turuncu (#FF9800) | Kıraathane tile |
| `Mat_Tile_Library` | Mor (#9C27B0) | Kütüphane tile |
| `Mat_Tile_SigningDay` | Pembe (#E91E63) | İmza günü tile |
| `Mat_Tile_Tesvik` | Cyan (#00BCD4) | Teşvik tile |
| `Mat_Tile_Corner` | Gri (#9E9E9E) | Köşe tile |
| `Mat_Ground` | Koyu Lacivert (#1A1A2E) | Zemin |

`Assets/Art/Players/` klasöründe:

| Material Adı | Renk | Oyuncu |
|-------------|------|--------|
| `Mat_Pawn_Red` | Kırmızı | Oyuncu 1 |
| `Mat_Pawn_Blue` | Mavi | Oyuncu 2 |
| `Mat_Pawn_Green` | Yeşil | Oyuncu 3 |
| `Mat_Pawn_Yellow` | Sarı | Oyuncu 4 |

---

## 15. Özet Kontrol Listesi

Unity Editor'de şu adımları tamamla (sırayla):

- [ ] Unity 2022.3 LTS kur
- [ ] 3D (URP) template ile proje aç
- [ ] Package Manager'dan TextMeshPro + 2D Sprite + Input System kur
- [ ] Tags ekle: Manager, Player, Tile, Pawn, Dice, Camera, UI
- [ ] Layers ekle: Board, Pawn, Dice, UI3D, Ground
- [ ] Sorting Layers ekle: Background, Board, Tile, Pawn, Effect, UI
- [ ] Klasör yapısını oluştur (_Project altında tüm klasörler)
- [ ] Game sahnesini oluştur ve Build Settings'e ekle
- [ ] Hierarchy'de [MANAGERS] parent oluştur, altına 11 boş manager objesi ekle
- [ ] [BOARD] parent oluştur, BoardParent ekle
- [ ] [PLAYERS] parent oluştur
- [ ] [DICE] parent oluştur, DiceTray + 2 zar ekle
- [ ] [CAMERA] parent oluştur, Main Camera ayarla (orthographic, pos, rot)
- [ ] [LIGHTING] parent oluştur, Directional Light ayarla
- [ ] [GROUND] parent oluştur, GroundPlane ekle
- [ ] [UI] Canvas oluştur, alt yapıyı kur
- [ ] Tile prefab'ını oluştur (Cube → scale → collider → prefab)
- [ ] PlayerPawn prefab'ını oluştur (Cylinder → scale → prefab)
- [ ] Dice prefab'ını oluştur (Cube → rigidbody → prefab)
- [ ] Material'ları oluştur (tile tipleri + pawn renkleri + zemin)
- [ ] Tüm objelere tag ve layer ata

---

## 16. Kısayol İpuçları

| İşlem | Kısayol |
|-------|---------|
| Scene görünümü | Alt + sürükle = döndür, Scroll = zoom |
| Obje konumlandırma | W = move, E = rotate, R = scale |
| Snap (grid'e yapış) | Ctrl basılı tut + sürükle |
| Prefab düzenle | Project'de prefab'a çift tıkla |
| Game penceresi | Play butonuna bas (▶) test için |
| Reset Transform | Inspector → Transform → ⚙️ → Reset |
