# Edebina — Oyun Tasarım Dokümanı (GDD)

**Sürüm:** 1.0 · **Tarih:** 15 Mayıs 2026 · **Aşama:** Pre-Production  
**Platform:** Mobile (iOS / Android) — Flutter + Unity Editor Entegrasyonu  
**Tür:** İzometrik Strateji Board Game · Cozy + Tactical  

---

## İçindekiler

1. [High Concept](#1-high-concept)
2. [Core Gameplay Loop](#2-core-gameplay-loop)
3. [Meta Progression](#3-meta-progression)
4. [Tile Türleri](#4-tile-türleri)
5. [Economy Design](#5-economy-design)
6. [Risk / Reward Sistemi](#6-risk--reward-sistemi)
7. [Multiplayer Yapısı](#7-multiplayer-yapısı)
8. [Technical Architecture](#8-technical-architecture)
9. [Unity Folder Structure](#9-unity-folder-structure)
10. [ScriptableObject Architecture](#10-scriptableobject-architecture)
11. [Manager Systems](#11-manager-systems)
12. [Event-Driven Architecture](#12-event-driven-architecture)
13. [Future Scalability](#13-future-scalability)
14. [Art Direction](#14-art-direction)
15. [UI / UX Yaklaşımı](#15-ui--ux-yaklaşımı)
16. [Production Roadmap](#16-production-roadmap)
17. [MVP Scope](#17-mvp-scope)
18. [AI-Assisted Workflow Önerisi](#18-ai-assisted-workflow-önerisi)
19. [ECS'ye Uygun Sistemler](#19-ecsye-uygun-sistemler)
20. [Prefab-Based Olacak Sistemler](#20-prefab-based-olacak-sistemler)

---

## 1. High Concept

> **"Osmanlı kiraathanesinde geçen, Türk edebiyatını keşfettiğin, arkadaşlarınla oynadığın, stratejik bir masa oyunu."**

Edebina, Monopoly'nin taş-mülkiyet ekonomisini, Trivial Pursuit'in bilgi yarışması çekirdeğini ve Türk edebiyatının zenginliğini tek bir izometrik deneyimde birleştiriyor. Oyuncular 26 karelik dikdörtgen bir tahta üzerinde ilerler, sorular yanıtlayarak yıldız kazanır, edebi alıntılar koleksiyon yapar ve 6 kategoride usta seviyesine yükselerek kazanır.

**USP'ler (Benzersiz Satış Noktaları):**

| USP | Detay |
|---|---|
| **Kültürel Derinlik** | 6 edebi kategori, 130+ soru, 25 alıntı, Osmanlı kiraathane atmosferi |
| **Mastery-as-Progress** | Çırak → Kalfa → Usta yükselme sistemi, her kategoride bağımsız ilerleme |
| **Catch-Up Mekaniği** | Underdog bonusu, lead compression, çift zar decay — kimse geride kalmaz |
| **Cozy + Strategic** | Rahatlatıcı görsel + derin ekonomi kararları (al-sat, kategori yatırımı) |

**Hedef Kitle:** 18–45 yaş, kültürel oyun sevenler, arkadaş grubu ile oynayanlar, edebiyat meraklıları.

**Oturum Süresi:** Sprint mode ~15 dakika (2 oyuncu) / ~25 dakika (4 oyuncu).

---

## 2. Core Gameplay Loop

```
┌──────────────────────────────────────────────────┐
│                   TUR BAŞLANGICI                  │
│                  ┌──────────┐                     │
│                  │  Zar At  │                     │
│                  └────┬─────┘                     │
│                       │                           │
│                  ┌────▼─────┐                     │
│            ┌────►│ Hareket  │◄──────┐            │
│            │     └────┬─────┘       │            │
│            │          │             │            │
│   ┌────────┴──┐  ┌───▼──────┐  ┌───┴───────┐   │
│   │Tekrar Zar │  │ Karelere │  │Başlangıç  │   │
│   │  At (Çift) │  │  Varış   │  │ Geçiş +5⭐ │   │
│   └────────┬──┘  └───┬──────┘  └───┬───────┘   │
│            │         │              │            │
│            │    ┌────▼──────────────▼────┐       │
│            │    │    Kare Tipi İşleme    │       │
│            │    ├────────────────────────┤       │
│            │    │ Kategori → Soru        │       │
│            │    │ Şans    → Pozitif Kart │       │
│            │    │ Kader   → Negatif Kart │       │
│            │    │ Kıraathane → Mağaza    │       │
│            │    │ Teşvik  → Bonus Ödül   │       │
│            │    │ Kütüphane → Ceza Turu   │       │
│            │    │ İmza Günü → Etkinlik   │       │
│            │    └────────────┬───────────┘       │
│            │                 │                    │
│            │           ┌────▼─────┐              │
│            │           │ Ödül/Ceza │              │
│            │           └────┬─────┘              │
│            │                │                     │
│            │          ┌─────▼──────┐             │
│            └──────────│  Tur Bitiş  │             │
│                       │Sonraki Oyuncu│             │
│                       └─────────────┘             │
│                                                   │
│              KAZANMA KOŞULU KONTROLÜ               │
│        20 Alıntı + 3 Kategoride Usta              │
└──────────────────────────────────────────────────┘
```

**Her Turun Zamanlaması:**

| Aşama | İnsan | Bot |
|---|---|---|
| Zar animasyonu | 6.1s | 0.5s |
| Karektere varış | 0.45s/adım | 0.05s/adım |
| Soru / Kart | Oyuncu bağımlı | 0.5s |
| Tur geçişi | 1.2s | 0.8s |

---

## 3. Meta Progression

### 3.1 Mastery Sistemi (Uzmanlaşma)

Her kategori bağımsız 4 seviyeye sahiptir:

```
ÇAYLAK (0⭐)  ──►  ÇIRAK (1⭐)  ──►  KALFA (2⭐)  ──►  USTA (3⭐)
   │                 │                  │                  │
   │ 3 Kolay doğru   │ 3 Orta doğru     │ 3 Zor doğru      │
   │                 │                  │                  │
   ▼                 ▼                  ▼                  ▼
Kolay soru       Orta soru          Zor soru           Zor soru
+3⭐/doğru        +5⭐/doğru         +8⭐/doğru          +8⭐/doğru
                  Terfi: +10⭐        Terfi: +20⭐        Terfi: +30⭐
```

**Terfi Ödülleri (Çarpık Getiri):**

| Seviye | Gereksinim | Terfi Ödülü | Soru Çarpanı |
|---|---|---|---|
| Çaylak → Çırak | 3 Kolay doğru | +10 ⭐ | 1x |
| Çırak → Kalfa | 3 Orta doğru | +20 ⭐ | 2x |
| Kalfa → Usta | 3 Zor doğru | +30 ⭐ | 3x |

### 3.2 Kazanma Koşulu (Win Condition)

```
20 Alıntı Koleksiyonu  +  3 Kategoride Usta Seviyesi
```

Sprint modunda (~15 dk) bir oyuncunun ulaşabileceği hedef dengesi:

- Ortalama tur sayısı: 12–18 tur
- Tur başına yıldız: 3–8 arası
- Alıntı düşme oranı: %30 (Zor doğru sonrası)
- Mağazadan alıntı alımı: Kıraathane ziyaretinde

### 3.3 Günlük Giriş Serisi (Daily Streak)

| Gün | Ödül |
|---|---|
| 1–2 | +2 ⭐ |
| 3–4 | +5 ⭐ |
| 5–6 | +8 ⭐ |
| 7+ | +12 ⭐ + Rastgele Alıntı |

Ardışık gün atlanırsa seri sıfırlanır.

---

## 4. Tile Türleri

### 4.1 Tahta Düzeni (26 Kare — 7-6-7-7 Dikdörtgen)

```
[13-KIRAATHANE] [14] [15] [16-ŞANS] [17] [18]  [19-KÜTÜPHANE]
[12]                                                     [20]
[11]                  MERKEZ ALANI                        [21]
[10-KADER]                                               [22-KADER]
[9]                                                      [23]
[8]                                                      [24]
[7]                                                      [25]
[6-İMZA GÜNÜ]   [5]  [4]  [3-ŞANS]  [2]  [1]  [0-BAŞLANGIÇ]
```

### 4.2 Kare Türleri ve Mekanikleri

| Kare Türü | Sayı | Pozisyonlar | Mekanik |
|---|---|---|---|
| **Başlangıç** | 1 | 0 | Geçiş +5⭐, varışta özel etkinlik |
| **Kategori** | 14 | 1,2,4,5,7,9,11,12,14,15,18,20,21,23,24 | Soru kartı çek |
| **Şans** | 2 | 3, 16 | Pozitif etki kartı (+EV: 8⭐) |
| **Kader** | 2 | 10, 22 | Negatif etki kartı (-EV: 8⭐) |
| **İmza Günü** | 1 | 6 | Etkinlik karesi (tur atlatma yok) |
| **Kıraathane** | 1 | 13 | Mağaza — alıntı satın al |
| **Kütüphane** | 1 | 19 | Ceza — 2 tur bekle (%50 erken çıkış şansı) |
| **Teşvik** | 4 | 8, 17, 25 | Bonus ödüllü soru (+10⭐) |

### 4.3 Zorluk Dağılımı

| Bölge | Kareler | Zorluk |
|---|---|---|
| Alt sıra (0–6) | Başlangıç bölgesi | Kolay |
| Sol kolon (7–13) | Orta bölüm | Orta |
| Üst sıra (14–19) | İleri bölüm | Orta–Zor |
| Sağ kolon (20–25) | Uzman bölüm | Zor |

---

## 5. Economy Design

### 5.1 Yıldız Akışı (Star Flow)

```
GELİR (Faucet)                    GİDER (Sink)
─────────────                    ────────────
Soru yanıtlama  ──────►    ┌─────── Kıraathane alımları
  Kolay:    +3 ⭐          │
  Orta:     +5 ⭐          ├─────── Kader kartları
  Zor:      +8 ⭐          │         %30–40 kayıp
  Teşvik:   +10 ⭐         │
                          ├─────── Kütüphane cezası
Başlangıç geçişi +5 ⭐    │         5 ⭐ serbest bırakma
                          │
Şans kartları             ├─────── Kütüphane turları
  Ortalama: +8 ⭐         │         (fırsat maliyeti)
                          │
Terfi bonusları           └─────── İpucu kullanımı
  Çırak:   +10 ⭐              1 ⭐/ipucu
  Kalfa:   +20 ⭐
  Usta:    +30 ⭐
```

### 5.2 Catch-Up Mekanikleri

| Mekanik | Tetikleyici | Etki |
|---|---|---|
| **Underdog Bonus** | Yıldız < Lider × 0.5 | +3 ile +baseStars arası ek ödül |
| **Lead Compression** | Lider ile aralık ≥ 15 | Geridekiler × 1.2 çarpan |
| **Double Decay** | 2+ ardışık çift zar | Ödül × 0.5 |
| **Yüzde Kayıp Sınırı** | Kader kartı | Maksimum %40 kayıp |
| **Borç Koruması** | Her durum | Yıldız asla < 0 olamaz |

### 5.3 Enflasyon Kontrolü

| Parametre | Değer | Amaç |
|---|---|---|
| Başlangıç yıldızı | 0 | Sıfırdan başla |
| Yanlış ceza | 0 | Negatif reinforcement yok |
| Çift zar decay | ×0.5 | Çift zar sömürüsünü engelle |
| Kıraathane fiyatları | 5–15 ⭐ | Yıldız havuzu boşaltma |

---

## 6. Risk / Reward Sistemi

### 6.1 Kart Sistemi (Şans & Kader)

**Şans Kartları (Pozitif, EV: +8⭐)**

| Kart | Efekt | Değer | Açıklama |
|---|---|---|---|
| Telif Ödemesi | moneyChange | +8 | Eserin telif geldi |
| Küçük Edebiyat Ödülü | moneyChange | +10 | Ödül kazandın |
| Dergide Yayınlanan Makale | moneyChange | +12 | Makale yayınlandı |
| İlham Ziyareti | moveRelative | +1 | 1 kare ileri |
| Zaman = Para | rollAgain | 0 | Tekrar zar at |
| Geçici Eleştirmen Bağışıklığı | moneyChange | +5 | Koruma kazandın |
| Okuyucu Mektupları | moneyChange | +8 | Güzel mektuplar |
| Değerli Eser Bulundu | moveRelative | +1 | 1 kare ileri |
| Yayıncı Avansı | moneyChange | +10 | Avans geldi |

**Kader Kartları (Negatif, EV: -8⭐)**

| Kart | Efekt | Değer | Açıklama |
|---|---|---|---|
| Mürekkep Bitti | skipTurn | 1 | Tur atla |
| Matbaa Arızası | skipTurn | 1 | Tur atla |
| Düzeltme Yayınlandı | moveRelative | -1 | 1 kare geri |
| Eser Eleştirildi | moveRelative | -2 | 2 kare geri |
| Cüzdan Düştü | loseStarsPercentage | %40 | Yıldız kaybı |
| Kötü Yatırım | loseStarsPercentage | %30 | Yıldız kaybı |
| Kahve Faturası | moneyChange | -4 | Ödeme yap |
| Kırtasiye Masrafı | moneyChange | -6 | Ödeme yap |
| Kütüphane Cezası | moneyChange | -8 | Ödeme yap |

### 6.2 Stratejik Karar Noktaları

| Karar | Risk | Ödül |
|---|---|---|
| İpucu satın al | 1 ⭐ maliyet | Doğru cevap olasılığı artar |
| Zor soruya gir | Yanlış cevap riski | +8 ⭐ + %30 alıntı düşme |
| Çift zar at | Decay başlar | Ekstra hareket |
| Kıraathaende bekle | Yıldız harca | Alıntı koleksiyonu ilerler |
| Kütüphanede kal | 2 tur kayıp | %50 erken çıkış şansı |

---

## 7. Multiplayer Yapısı

### 7.1 Mevcut Yapı (Yerel)

- **2–4 oyuncu** destekli
- **Hot-seat** (aynı cihazda sırayla)
- **Bot modu:** AI destekli otomatik oyun (%50 doğru cevap oranı)
- **Sıra belirleme:** Zar atma turnuvası, eşitlikte tie-breaker

### 7.2 Çok Oyunculu Genişletilebilirlik

```
Phase 1 (Mevcut)        Phase 2                  Phase 3
───────────────        ────────                 ────────
Hot-seat local         WebSocket relay          Dedicated server
│                      │                        │
├─ StateNotifier       ├─ Socket client         ├─ Room-based lobby
├─ Riverpod state      ├─ State sync            ├─ ELO matchmaking
├─ Bot AI              ├─ Reconnect handling    ├─ Turn timer (30s)
│                      ├─ Spectator mode        ├─ Anti-cheat
│                      │                        ├─ Ranked / Casual
```

**Turn-tabanlı doğası gereği WebSocket maliyeti düşük:**

- State sync sadece tur geçişlerinde
- Tam oyun durumu JSON olarak gönderilebilir
- Lag toleransı yüksek (sıra tabanlı)

### 7.3 State Serialization

```json
{
  "gameId": "uuid",
  "players": [
    {
      "id": "p1",
      "name": "Oyuncu 1",
      "position": 5,
      "stars": 23,
      "categoryLevels": {"edebiSanatlar": 2, "eserKarakter": 1},
      "collectedQuotes": ["q1", "q3"]
    }
  ],
  "currentPlayerIndex": 0,
  "phase": "playerTurn",
  "turnNumber": 8
}
```

---

## 8. Technical Architecture

### 8.1 Mevcut Mimari (Flutter)

```
┌─────────────────────────────────────────────┐
│                 PRESENTATION                │
│  Screens (Setup, MainMenu, Game, Victory)   │
│  Widgets (Board, Dice, Pawn, HUD, Cards)    │
│  Dialogs (Question, Shop, Penalty, Pause)   │
├─────────────────────────────────────────────┤
│                  PROVIDERS                  │
│  GameNotifier (StateNotifier<GameState>)    │
│  DialogProvider  ·  ThemeNotifier           │
│  RepositoryProviders  ·  AppBootstrap       │
├─────────────────────────────────────────────┤
│                   DOMAIN                   │
│  Repositories (Question, Player, Game)      │
│  Interfaces · Use Cases                     │
├─────────────────────────────────────────────┤
│                    DATA                     │
│  DataSources (JSON, Local)                  │
│  Models (Question, Quote, Player mappers)   │
│  Repositories (Impl)                        │
├─────────────────────────────────────────────┤
│                    CORE                     │
│  Services (Movement, Dice, Economy,         │
│            TurnOrder, Streak)               │
│  Constants (Game, Motion)                   │
│  Managers (Audio)                           │
│  Utils (BoardLayout, Logger)                │
├─────────────────────────────────────────────┤
│                   BRIDGE                    │
│  MCP Command Listener (C# Unity Script)     │
│  MCP Command Bridge (Python CLI)            │
│  unity_commands.json (File-based IPC)       │
└─────────────────────────────────────────────┘
```

### 8.2 Unity Editor Entegrasyonu

```
Flutter Game (Production)     Unity Editor (Development/AI Bridge)
─────────────────────        ──────────────────────────────────────
       │                                    │
       │  Game State (Riverpod)             │  Scene Hierarchy
       │  Board Layout                      │  BoardGenerator
       │  MovementService                   │  McpCommandListener
       │                                    │  Visual Preview
       │                                    │
       └──── unity_commands.json ───────────┘
              (File-based Bridge)

AI Agent (Kilo Code)
    │
    ├── mcp_command_bridge.py ──► unity_commands.json
    │
    └── MCP for Unity (HTTP 8080) ──► Unity Editor Direct Control
```

### 8.3 Teknoloji Yığını

| Katman | Teknoloji | Versiyon |
|---|---|---|
| Frontend | Flutter / Dart | 3.x |
| State | Riverpod (StateNotifier) | 2.x |
| Audio | audioplayers | Latest |
| Unity Bridge | MCP for Unity | 9.6+ |
| MCP Protocol | FastMCP (Python) | stdio/http |
| AI Integration | Kilo Code + MCP | VS Code |
| Sürüm Kontrol | Git + GitHub | — |
| CI/CD | GitHub Actions | — |

---

## 9. Unity Folder Structure

```
Assets/
├── Scripts/
│   ├── Core/
│   │   ├── GameManager.cs
│   │   ├── TurnManager.cs
│   │   └── GameState.cs
│   ├── Models/
│   │   ├── PlayerData.cs
│   │   ├── BoardTileData.cs
│   │   └── QuestionData.cs
│   ├── Services/
│   │   ├── MovementService.cs
│   │   ├── DiceService.cs
│   │   ├── EconomyService.cs
│   │   ├── QuestionService.cs
│   │   └── AudioService.cs
│   ├── Board/
│   │   ├── BoardGenerator.cs
│   │   ├── TileLabel.cs
│   │   └── BoardLayout.cs
│   ├── UI/
│   │   ├── HUD/
│   │   ├── Dialogs/
│   │   └── Overlays/
│   ├── Network/
│   │   ├── NetworkManager.cs
│   │   └── StateSyncService.cs
│   ├── MCP/
│   │   └── McpCommandListener.cs
│   └── Utilities/
│       ├── Constants.cs
│       └── Logger.cs
├── ScriptableObjects/
│   ├── Tiles/
│   │   ├── Tile_Start.asset
│   │   ├── Tile_Category_EdebiSanatlar.asset
│   │   └── ...
│   ├── Cards/
│   │   ├── ChanceCards/
│   │   └── FateCards/
│   ├── Questions/
│   │   ├── Questions_Easy.asset
│   │   ├── Questions_Medium.asset
│   │   └── Questions_Hard.asset
│   ├── GameConfig.asset
│   ├── EconomyConfig.asset
│   └── AudioConfig.asset
├── Prefabs/
│   ├── Tiles/
│   │   ├── Tile_Corner.prefab
│   │   ├── Tile_Category.prefab
│   │   ├── Tile_Special.prefab
│   │   └── Tile_ChanceFate.prefab
│   ├── Pawns/
│   │   ├── Pawn_Red.prefab
│   │   ├── Pawn_Blue.prefab
│   │   ├── Pawn_Green.prefab
│   │   └── Pawn_Yellow.prefab
│   ├── UI/
│   │   ├── DiceRollPanel.prefab
│   │   ├── QuestionDialog.prefab
│   │   └── CardPopup.prefab
│   └── Effects/
│       ├── HopEffect.prefab
│       ├── StarCollect.prefab
│       └── Confetti.prefab
├── Art/
│   ├── Sprites/
│   │   ├── Tiles/
│   │   ├── Icons/
│   │   └── UI/
│   ├── Materials/
│   ├── Models/ (3D isometric)
│   └── Animations/
├── Audio/
│   ├── BGM/
│   └── SFX/
├── Scenes/
│   ├── MainMenu.unity
│   ├── GameBoard.unity
│   └── Victory.unity
├── Resources/ (runtime load)
│   └── Questions/
│       └── questions.json
└── StreamingAssets/
    └── Config/
        └── game_config.json
```

---

## 10. ScriptableObject Architecture

### 10.1 Tile Tanımları

```csharp
[CreateAssetMenu(fileName = "Tile_", menuName = "Edebina/Tile")]
public class TileData : ScriptableObject
{
    public string tileId;
    public string displayName;
    public TileType tileType;
    public int boardPosition;
    public string category;
    public Difficulty difficulty;
    public Sprite tileIcon;
    public Color tileColor;
    public GameObject tilePrefab;
    public AudioClip landingSfx;
}

// Kategori tile'ları için genişletilmiş versiyon
public class CategoryTileData : TileData
{
    public QuestionCategory questionCategory;
    public float questionTimeLimit = 45f;
    public int baseReward = 3;
}
```

### 10.2 Kart Tanımları

```csharp
[CreateAssetMenu(fileName = "Card_", menuName = "Edebina/Card")]
public class CardData : ScriptableObject
{
    public string cardId;
    public CardType cardType; // Sans / Kader
    public CardEffectType effectType;
    public int value;
    [TextArea] public string description;
    public Sprite cardArt;
    public AudioClip flipSfx;
}
```

### 10.3 Konfigürasyon

```csharp
[CreateAssetMenu(fileName = "GameConfig", menuName = "Edebina/GameConfig")]
public class GameConfig : ScriptableObject
{
    // Board
    public int boardSize = 26;
    public int startPosition = 0;
    public float tileSize = 1f;
    public float tileSpacing = 0.1f;

    // Economy
    public int initialStars = 0;
    public int passingStartBonus = 5;
    public int hintCost = 1;
    public int jailFee = 5;

    // Mastery
    public int answersRequiredForPromotion = 3;
    public int[] promotionRewards = { 10, 20, 30 };
    public int[] questionRewards = { 3, 5, 8, 10 };

    // Win
    public int quotesToCollect = 20;
    public int requiredMasteries = 3;

    // Animation
    public float hopDuration = 0.45f;
    public float hopHeight = 0.5f;
    public float diceRollDuration = 6.1f;
}
```

### 10.4 Soru Veritabanı

```csharp
[CreateAssetMenu(fileName = "QuestionDB_", menuName = "Edebina/QuestionDB")]
public class QuestionDatabase : ScriptableObject
{
    public List<QuestionEntry> questions;

    public QuestionEntry GetRandom(QuestionCategory cat, Difficulty diff, HashSet<string> excluded)
    {
        var pool = questions.Where(q =>
            q.category == cat &&
            q.difficulty == diff &&
            !excluded.Contains(q.id)
        ).ToList();
        return pool.Count > 0 ? pool[Random.Range(0, pool.Count)] : null;
    }
}
```

---

## 11. Manager Systems

### 11.1 Manager Hiyerarşisi

```
GameManager (Singleton, Scene-root)
├── TurnManager
│   ├── Sıra takibi
│   ├── Çift zar algılama
│   └── Tur geçiş animasyonları
├── BoardManager
│   ├── Tile oluşturma ve yerleşim
│   ├── Kare varış işleme
│   └── Özel kare tetikleyicileri
├── EconomyManager
│   ├── Yıldız akışı
│   ├── Catch-up hesaplamalar
│   └── Mağaza işlemleri
├── QuestionManager
│   ├── Soru havuzu yönetimi
│   ├── Zorluk seçimi (mastery bazlı)
│   └── İstatistik takibi
├── AnimationManager
│   ├── Zar animasyonu
│   ├── Piyon hareketi
│   ├── Kart flip
│   └── UI geçişleri
├── AudioManager
│   ├── BGM çalma listesi
│   ├── SFX tetikleme
│   └── Fade in/out
├── CardManager
│   ├── Şans/Kader destesi
│   ├── Kart çekme
│   └── Efekt uygulama
├── MasteryManager
│   ├── İlerleme takibi
│   ├── Terfi kontrolü
│   └── Zorluk ölçekleme
└── McpCommandListener
    ├── JSON dosya izleme
    ├── Komut kuyruğu
    └── Hareket yürütme
```

### 11.2 Sorumluluk Ayrımı

| Manager | Sahip Olduğu State | Değiştirdiği State |
|---|---|---|
| TurnManager | currentPlayerIndex, phase | phase, isDoubleTurn |
| BoardManager | tiles[], currentTile | player.position |
| EconomyManager | — | player.stars |
| QuestionManager | askedQuestionIds, cachedQuestions | player.categoryProgress |
| AnimationManager | — | Transform (geçici) |
| CardManager | chanceDeck, fateDeck | player.stars, player.position |
| MasteryManager | — | player.categoryLevels |

---

## 12. Event-Driven Architecture

### 12.1 Event Bus Tasarımı

```csharp
public static class GameEvents
{
    // Turn
    public static event Action<int> OnTurnStart;
    public static event Action<int> OnTurnEnd;
    public static event Action<int, int> OnDiceRolled;

    // Movement
    public static event Action<int, int> OnPawnMoved;
    public static event Action<int> OnPawnReachedTile;
    public static event Action<int> OnPassedStart;

    // Question
    public static event Action<QuestionData> OnQuestionAsked;
    public static event Action<bool, int> OnQuestionAnswered;

    // Economy
    public static event Action<int, int> OnStarsChanged;
    public static event Action<int, int> OnStarsEarned;
    public static event Action<int, int> OnStarsLost;

    // Mastery
    public static event Action<int, string, MasteryLevel> OnMasteryPromoted;
    public static event Action<int, string> OnCategoryLevelUp;

    // Cards
    public static event Action<CardData> OnCardDrawn;
    public static event Action<CardData, int> OnCardEffectApplied;

    // Game
    public static event Action OnGameStart;
    public static event Action<int> OnGameOver;
    public static event Action OnGamePaused;
}
```

### 12.2 Event Akışı — Tipik Bir Tur

```
OnTurnStart(playerIndex)
    │
    OnDiceRolled(playerIndex, total)
    │
    OnPawnMoved(playerIndex, newPos)  ← her adım
    │   OnPassedStart(playerIndex)   ← geçişte
    │
    OnPawnReachedTile(tileIndex)
    │
    ├─ Kategori: OnQuestionAsked(q) → OnQuestionAnswered(correct, reward)
    │            → OnStarsEarned(player, amount) → OnMasteryPromoted(...)
    │
    ├─ Şans:    OnCardDrawn(card) → OnCardEffectApplied(card, value)
    │
    ├─ Kader:   OnCardDrawn(card) → OnStarsLost(player, amount)
    │
    └─ Kütüphane: OnStarsLost(player, fee)
    │
    OnTurnEnd(playerIndex)
```

---

## 13. Future Scalability

### 13.1 İçerik Genişletilebilirlik

| Alan | Mevcut | Genişletme |
|---|---|---|
| Sorular | 130+ JSON | Kategori başına 200+ hedef |
| Alıntılar | 25 | Dönem bazlı paketler |
| Kategoriler | 6 | DLC kategoriler |
| Tahta boyutu | 26 | Değişken tahta boyutu |
| Kartlar | 18 (9+9) | Dinamik deste oluşturma |

### 13.2 Modding Desteği

```json
{
  "mod_id": "tanzimat_eklentisi",
  "version": "1.0",
  "type": "content_pack",
  "questions": "questions_tanzimat.json",
  "quotes": "quotes_tanzimat.json",
  "cards": "cards_tanzimat.json",
  "board_overrides": null
}
```

### 13.3 Platform Genişletme

| Platform | Adaptasyon | Öncelik |
|---|---|---|
| iOS/Android | Mevcut (Flutter) | MVP |
| Web | Flutter Web | Phase 2 |
| Windows/Mac | Flutter Desktop | Phase 3 |
| Tablet | Responsive layout | MVP |
| TV | Gamepad desteği | Phase 4 |

---

## 14. Art Direction

### 14.1 Görsel Stil

| Öğe | Stil |
|---|---|
| **Genel** | 2.5D izometrik, sıcak renk paleti |
| **Tahta** | Ahşap doku, el yapımı kağıt hissi |
| **Kareler** | Osmanlı çini desenleri, kategori bazlı renk kodu |
| **Piyonlar** | 3D küre, oyuncu rengi, düşük poly |
| **Kartlar** | Eski el yazısı fontu, parşömen arka plan |
| **UI** | Osmanlı tezhip süslemeleri, altın varak dokunuşlar |

### 14.2 Renk Paleti

| Renk | Hex | Kullanım |
|---|---|---|
| Ahşap Kahve | `#8B6914` | Tahta arka plan |
| Deri Yeşil | `#2D5016` | Kıraathane karesi |
| Kum Beji | `#E8D5A3` | Kart arka plan |
| Altın | `#FFD700` | Yıldız, ödüller |
| Lacivert | `#1B3A5C` | Kütüphane karesi |
| Kiremit | `#C1440E` | Kader karesi |
| Zümrüt | `#50C878` | Şans karesi |
| Koyu Mor | `#4A0E4E` | Teşvik karesi |

### 14.3 Animasyon Prensipleri

| İlkeler | Uygulama |
|---|---|
| **Cozy motion** | easeOutQuart, hiçbir hareket ani değil |
| **Breathing** | Arka plan gradient 8 saniyelik nefes döngüsü |
| **Hop animation** | 450ms, sinüs eğrisi z ekseni |
| **Micro-celebrations** | Yıldız toplama particle effect |
| **Reduced motion** | Accessibility desteği (SafeDuration) |

---

## 15. UI / UX Yaklaşımı

### 15.1 Ekran Akışı

```
[Splash] → [Ana Menü] → [Oyun Kurulumu]
                              │
                         [Oyun Tahtası]
                          │    │    │
                   [Soru] [Kart] [Mağaza]
                          │
                   [Kazanma Ekranı]
```

### 15.2 HUD Düzeni (Oyun İçi)

```
┌─────────────────────────────────────────┐
│  [Oyuncu HUD]  [Sıra Göstergesi]  [⏸]  │
├─────┬───────────────────────────┬───────┤
│     │                           │       │
│ Sol │     TAHTA (İzometrik)     │ Sağ   │
│ K.. │     26 Kare               │ K..   │
│     │     Merkez: Zar + Logo    │       │
│     │                           │       │
├─────┴───────────────────────────┴───────┤
│  [Zar] [Oyuncu Bilgisi] [Oyun Günlüğü] │
└─────────────────────────────────────────┘
```

### 15.3 UX Prensipleri

| İlke | Uygulama |
|---|---|
| **Tek el ile oynanabilir** | Tüm aksiyonlar tek dokunuşla |
| **Bilgi hiyerarşisi** | Yıldız > Sıra > Kategori durumu |
| **Contextual dialoglar** | Her kare tipi için özel dialog |
| **Async barrier pattern** | Dialog kapanmadan tur ilerlemez |
| **Bot watchdog** | 4 saniye donma koruması |
| **Motion respect** | Reduce motion accessibility desteği |

---

## 16. Production Roadmap

### Phase 1 — MVP (6 hafta)

| Hafta | Görev | Teslim |
|---|---|---|
| 1–2 | Core loop: zar → hareket → soru → ödül | Çalışan oyun döngüsü |
| 3 | Ekonomi + kart sistemi | Dengeli yıldız akışı |
| 4 | Mastery + kazanma koşulu | Tam oyun deneyimi |
| 5 | UI/UX: tahta, HUD, dialoglar | Görsel olarak tamamlanmış |
| 6 | Bot modu, ses, polisaj | Oynanabilir MVP |

### Phase 2 — Çok Oyunculu (4 hafta)

| Hafta | Görev |
|---|---|
| 7–8 | WebSocket altyapısı, oda sistemi |
| 9 | State sync, reconnect handling |
| 10 | Matchmaking, ELO sistemi |

### Phase 3 — İçerik & Polisaj (4 hafta)

| Hafta | Görev |
|---|---|
| 11 | 200+ soru, 50+ alıntı |
| 12 | İzometrik görsel overhawl |
| 13 | Animasyon polisaj, VFX |
| 14 | QA, denge ayarı, beta |

### Phase 4 — Lansman (2 hafta)

| Hafta | Görev |
|---|---|
| 15 | Store asset hazırlığı |
| 16 | Lansman, izleme, hotfix |

---

## 17. MVP Scope

### Dahil (In Scope)

- [x] 26 karelik tahta (BoardGenerator)
- [x] 2–4 oyuncu hot-seat
- [x] Zar atma ve hareket sistemi
- [x] 6 kategoride soru sistemi (130+ soru)
- [x] Mastery sistemi (Çaylak → Usta)
- [x] Şans & Kader kartları (18 kart)
- [x] Ekonomi (yıldız sistemi)
- [x] Kıraathane mağazası
- [x] Kütüphane ceza mekanizması
- [x] Catch-up mekanikleri
- [x] Bot modu (AI karşıdan)
- [x] Ses sistemi (BGM + SFX)
- [x] Kazanma koşulu (20 alıntı + 3 usta)
- [x] MCP entegrasyonu (Unity ↔ AI)

### Hariç (Out of Scope — Sonraki Faz)

- [ ] Online multiplayer
- [ ] ELO sıralama sistemi
- [ ] Dinamik tahta boyutu
- [ ] Kullanıcı profilleri / giriş
- [ ] DLC kategori paketleri
- [ ] Tablet optimized layout
- [ ] Erişilebilirlik (VoiceOver, TalkBack)
- [ ] Localization (İngilizce, Arapça)

---

## 18. AI-Assisted Workflow Önerisi

### 18.1 Mevcut AI Pipeline

```
VS Code (Kilo Code)
    │
    ├─► Python Bridge (mcp_command_bridge.py)
    │       └─► unity_commands.json
    │               └─► Unity McpCommandListener.cs
    │                       └─► Piyon hareketi, test
    │
    └─► MCP for Unity (HTTP :8080)
            └─► Unity Editor doğrudan kontrol
                    ├─► Sahne düzenleme
                    ├─► Script oluşturma
                    ├─► Asset yönetimi
                    └─► Build & Deploy
```

### 18.2 AI Kullanım Senaryoları

| Senaryo | Tool | Verimlilik |
|---|---|---|
| **Soru üretimi** | LLM + JSON format | 50 soru/saat |
| **Kart dengesi** | MCP ile simülasyon | Anında test |
| **Tahta düzeni** | BoardGenerator + MCP | Görsel iterasyon |
| **Bug repro** | Bot modu + MCP bridge | Otomatik reproduksiyon |
| **Playtest** | AI bot modu (4 oyuncu) | 10 oyun/dakika |
| **Script oluşturma** | Kilo Code + MCP | Tam Unity entegrasyonu |
| **Balance tuning** | Ekonomi simülasyonu | Veri odaklı denge |

### 18.3 Prompt Şablonları

**Soru Üretimi:**
```
"6 kategori için {difficulty} seviyesinde {count} Türk edebiyatı sorusu üret.
Format: {text, options[], correctIndex, category, difficulty}.
Önceki soruları tekrarlama: {asked_ids}."
```

**Kart Dengesi:**
```
"Mevcut Şans kart EV: +8⭐, Kader kart EV: -8⭐.
{card_type} kartı ekle, mevcut desteyi bozmadan.
Hedef EV'yi koru."
```

**Oyun Testi:**
```
"Bot modunu aktifleştir, 4 oyuncu ile 100 oyun simüle et.
Kazanma sürelerini, yıldız dağılımını ve kategori dengesini raporla."
```

---

## 19. ECS'ye Uygun Sistemler

ECS (Entity Component System) yaklaşımına en uygun sistemler — büyük sayıda benzer varlık, paralel işleme ihtiyacı:

| Sistem | Neden ECS | Component'ler |
|---|---|---|
| **Piyon Hareketi** | N pawn, aynı logic | `PositionComponent`, `MovementComponent`, `AnimationComponent` |
| **Tile Varış İşleme** | 26 kare, aynı pipeline | `TileTypeComponent`, `EffectComponent` |
| **Soru Havuzu** | 130+ soru, filtreleme | `CategoryComponent`, `DifficultyComponent`, `UsedComponent` |
| **Kart Destesi** | 18 kart, çeke-uygula | `CardTypeComponent`, `EffectComponent`, `ValueComponent` |
| **Economy İşlemleri** | Paralel hesaplama | `StarComponent`, `ModifierComponent` |
| **Particle Effects** | 100+ parçacık | `TransformComponent`, `LifetimeComponent`, `ColorComponent` |
| **Audio Sources** | Birden fazla SFX | `AudioClipComponent`, `VolumeComponent` |

**ECS Framework Önerisi:** Unity DOTS (Entities 1.0+) — özellikle particle ve movement sistemleri için.

---

## 20. Prefab-Based Olacak Sistemler

Prefab yaklaşımına uygun sistemler — görsel varyasyon, Inspector yapılandırması, runtime instantiate:

| Sistem | Prefab Türü | Neden Prefab |
|---|---|---|
| **Tile Görselleri** | `Tile_Corner`, `Tile_Category`, `Tile_Special` | Farklı boyut, renk, ikon |
| **Piyonlar** | `Pawn_Red`, `Pawn_Blue`, vs. | Oyuncu rengi, material varyasyon |
| **Dialog Pencereleri** | `QuestionDialog`, `CardDialog`, `ShopDialog` | Farklı layout, buton yapısı |
| **Zar 3D** | `Dice3D` | Animasyon, fizik, material |
| **Kartlar** | `ChanceCard`, `FateCard` | Flip animasyonu, art önyüz |
| **Efektler** | `StarCollect`, `Confetti`, `HopEffect` | Particle sistemi, kısa ömürlü |
| **HUD Elementleri** | `PlayerHUD`, `TurnIndicator`, `StarCounter` | UI layout, binding |
| **Mağaza Öğeleri** | `QuoteShopItem`, `HintButton` | Interaktif UI, fiyat etiketi |
| **Kazanma Ekranı** | `VictoryPanel`, `MasteryBadge` | Tek seferlik, veri odaklı |

### Prefab Variant Stratejisi

```
Tile_Category (Base Prefab)
├── Tile_Category_EdebiSanatlar (Variant: mavi renk, edebiyat ikonu)
├── Tile_Category_EserKarakter (Variant: turuncu, kitap ikonu)
├── Tile_Category_BenKimim (Variant: mor, soru ikonu)
├── Tile_Category_Akimlar (Variant: yeşil, ok ikonu)
├── Tile_Category_Ilkler (Variant: kırmızı, yıldız ikonu)
└── Tile_Category_Tesvik (Variant: altın, ödül ikonu)
```

---

## Ek A — Sayısal Özet

| Metrik | Değer |
|---|---|
| Tahta karesi | 26 |
| Kategori | 6 |
| Toplam soru | 130+ |
| Toplam alıntı | 25 |
| Şans kartı | 9 |
| Kader kartı | 9 |
| Mastery seviye | 4 (Çaylak → Usta) |
| Maks oyuncu | 4 |
| Kazanma: alıntı | 20 |
| Kazanma: usta kategori | 3 |
| Ortalama oyun süresi | 15–25 dk |

---

## Ek B — Terimler Sözlüğü

| Terim | Açıklama |
|---|---|
| **Kıraathane** | Osmanlı kahvehane / sosyal mekan (Shop karesi) |
| **Teşvik** | Teşvik edici bonus soru karesi |
| **İmza Günü** | Yazar imza günü etkinlik karesi |
| **Çaylak → Çırak → Kalfa → Usta** | 4 aşamalı uzmanlaşma sistemi |
| **Yıldız (⭐)** | Oyun içi para birimi |
| **Alıntı** | Edebi eserlerden koleksiyonluk söz |
| **Şans** | Pozitif etki kartı |
| **Kader** | Negatif etki kartı |
| **Catch-up** | Gerideki oyunculara avantaj mekanizması |
| **EV (Expected Value)** | Beklenen değer — kart dengesi metriği |
