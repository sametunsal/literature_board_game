# Git Repository Update Guide / Git Depo Güncelleme Rehberi

> **English / Türkçe**: This guide provides comprehensive instructions for updating your local Git repository from the remote repository.  
> **English / Türkçe**: Bu rehber, yerel Git deponuzu uzak depodan güncellemek için kapsamlı talimatlar sağlar.

---

## Section 1: Current Repository Analysis / Bölüm 1: Mevcut Depo Analizi

### Git State Findings / Git Durum Bulguları

**Current Branch / Mevcut Dal:**
- Branch: `main`
- Status: Up to date with `origin/main`
- Working Tree: Clean (no uncommitted changes)

**Current Branch / Mevcut Dal:**
- Dal: `main`
- Durum: `origin/main` ile güncel
- Çalışma Ağacı: Temiz (işlenmemiş değişiklik yok)

### Configured Remote Repositories / Yapılandırılmış Uzak Depolar

| Remote Name | Fetch URL | Push URL |
|-------------|-----------|----------|
| origin | https://github.com/sametunsal/literature_board_game.git | https://github.com/sametunsal/literature_board_game.git |

| Uzak Depo Adı | Fetch URL | Push URL |
|---------------|-----------|----------|
| origin | https://github.com/sametunsal/literature_board_game.git | https://github.com/sametunsal/literature_board_game.git |

### All Branches / Tüm Dallar

**Local Branches / Yerel Dallar:**
- `main` (current branch / mevcut dal)

**Remote Branches / Uzak Dallar:**
- `remotes/origin/HEAD -> origin/main`
- `remotes/origin/main`
- `remotes/origin/card-effect-refactor-13437587480305317399`
- `remotes/origin/codex/analyze-file-for-errors-and-improvements`
- `remotes/origin/fix/game-loop-stuck-turn-phase-11239026255399861438`
- `remotes/origin/main-9326817233495729813`

### Recent Commits / Son İşlemeler

```
6659206 feat: Add My Collection screen, update Pause Menu, and cleanup UI
26da838 chore: Add .vscode/settings.json to repository
03db1fe fix: Add literary_quotes.json to pubspec assets
99118ac fix: Remove _isProcessing guard from _drawCard to fix Chance tile deadlock
fdc1473 fix: Prevent deadlock in answerQuestion with flag pattern
```

### Fetch Status / Getirme Durumu

**Git Fetch Dry-Run Result / Git Fetch Dry-Run Sonucu:**
- No new changes to fetch from remote / Uzak depodan getirilecek yeni değişiklik yok
- Repository is already up to date / Depo zaten güncel

---

## Section 2: Step-by-Step Git Update Process / Bölüm 2: Adım Adım Git Güncelleme Süreci

### 2.1 Fetching Latest Changes from Remote / Uzak Depodan Son Değişiklikleri Getirme

#### Git Fetch / Git Fetch

**Command / Komut:**
```bash
git fetch
```

**Explanation / Açıklama:**
- Downloads all the latest changes from the remote repository to your local machine / Uzak depodan tüm son değişiklikleri yerel makinenize indirir
- Does NOT merge these changes into your working files / Bu değişiklikleri çalışma dosyalarınızla BİRLEŞTİRMEZ
- Updates the remote-tracking branches (e.g., `origin/main`) / Uzak izleme dallarını günceller (örn. `origin/main`)
- Safe to run anytime without affecting your work / Çalışmanızı etkilemeden her zaman güvenle çalıştırılabilir

**When to use / Ne zaman kullanılır:**
- Before checking what's new in the remote repository / Uzak depoda neyin yeni olduğunu kontrol etmeden önce
- Before merging or rebasing / Birleştirme veya rebase yapmadan önce
- When you want to see what changes are available without applying them / Değişiklikleri uygulamadan neyin mevcut olduğunu görmek istediğinizde

**Alternative: Fetch specific branch / Alternatif: Belirli dal getirme:**
```bash
git fetch origin main
```

---

### 2.2 Comparing Local and Remote Branches / Yerel ve Uzak Dalları Karşılaştırma

#### View differences between local and remote / Yerel ve uzak arasındaki farkları görüntüleme

**Command / Komut:**
```bash
git log HEAD..origin/main --oneline
```

**Explanation / Açıklama:**
- Shows commits that exist in `origin/main` but not in your local `main` branch / `origin/main`'de var olan ancak yerel `main` dalınızda olmayan işlemleri gösterir
- Helps you understand what changes will be merged / Hangi değişikliklerin birleştirileceğini anlamanıza yardımcı olur

**When to use / Ne zaman kullanılır:**
- After fetching but before merging / Getirdikten sonra ancak birleştirmeden önce
- To preview incoming changes / Gelen değişiklikleri önizlemek için

#### View detailed diff / Detaylı fark görüntüleme

**Command / Komut:**
```bash
git diff HEAD origin/main
```

**Explanation / Açıklama:**
- Shows the actual code differences between your local branch and the remote branch / Yerel dalınız ve uzak dal arasındaki gerçek kod farklarını gösterir
- Useful for reviewing changes before merging / Birleştirmeden önce değişiklikleri gözden geçirmek için kullanışlıdır

---

### 2.3 Merging Remote Changes into Local Branch / Uzak Değişiklikleri Yerel Dala Birleştirme

#### Git Merge / Git Merge

**Command / Komut:**
```bash
git merge origin/main
```

**Explanation / Açıklama:**
- Integrates the changes from `origin/main` into your current local branch / `origin/main`'den gelen değişiklikleri mevcut yerel dalınıza entegre eder
- Creates a merge commit if there are divergent histories / Farklı geçmişler varsa bir birleştirme işlemesi oluşturur
- Preserves the complete history of both branches / Her iki dalın tam geçmişini korur

**When to use / Ne zaman kullanılır:**
- When you want to keep a complete, linear history of all changes / Tüm değişikliklerin tam, doğrusal bir geçmişini tutmak istediğinizde
- When working in a team where merge commits are acceptable / Birleştirme işlemlerinin kabul edildiği bir ekipte çalışırken
- When you want to clearly see when merges happened / Birleşmelerin ne zaman olduğunu net bir şekilde görmek istediğinizde

**Example output / Örnek çıktı:**
```
Updating 6659206..a1b2c3d
Fast-forward
 file1.txt | 2 +-
 file2.txt | 10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)
```

---

### 2.4 Alternative: Rebase Local Changes on Top of Remote / Alternatif: Yerel Değişiklikleri Uzak Deponun Üstüne Rebase Etme

#### Git Rebase / Git Rebase

**Command / Komut:**
```bash
git rebase origin/main
```

**Explanation / Açıklama:**
- Takes your local commits and re-applies them on top of the latest remote commits / Yerel işlemlerinizi alır ve en son uzak işlemlerin üzerine yeniden uygular
- Creates a linear history without merge commits / Birleştirme işlemleri olmadan doğrusal bir geçmiş oluşturur
- Rewrites commit history (can be problematic if commits are already pushed) / İşlem geçmişini yeniden yazar (işlemler zaten push edildiyse sorunlu olabilir)

**When to use / Ne zaman kullanılır:**
- When you want a clean, linear commit history / Temiz, doğrusal bir işlem geçmişi istediğinizde
- When your local changes haven't been pushed yet / Yerel değişiklikleriniz henüz push edilmediyse
- When you want to avoid merge commits / Birleştirme işlemlerinden kaçınmak istediğinizde

**Caution / Dikkat:**
- Do NOT rebase commits that have already been pushed to a shared branch / Paylaşılan bir dala zaten push edilmiş işlemleri rebase ETMEYİN
- Rebase changes commit hashes, which can cause issues for collaborators / Rebase işlem hash'lerini değiştirir, bu da işbirliği yapanlar için sorunlara neden olabilir

---

### 2.5 Alternative: Reset to Remote Version (Discarding Local Changes) / Alternatif: Uzak Sürümüne Sıfırlama (Yerel Değişiklikleri Yoksayma)

#### Git Reset Hard / Git Reset Hard

**Command / Komut:**
```bash
git reset --hard origin/main
```

**Explanation / Açıklama:**
- Completely discards all local changes and makes your local branch identical to the remote branch / Tüm yerel değişiklikleri tamamen yoksayar ve yerel dalınızı uzak dalıyla aynı yapar
- Deletes all uncommitted changes / İşlenmemiş tüm değişiklikleri siler
- Moves your branch pointer to match the remote branch / Dal işaretçinizi uzak dalıyla eşleşecek şekilde hareket ettirir

**When to use / Ne zaman kullanılır:**
- When you want to completely discard local work and start fresh / Yerel çalışmayı tamamen yoksayıp sıfırdan başlamak istediğinizde
- When your local changes are corrupted or no longer needed / Yerel değişiklikleriniz bozulduğunda veya artık gerekli olmadığında
- When you want to sync exactly with the remote repository / Uzak depoyla tam olarak senkronize olmak istediğinizde

**⚠️ WARNING / ⚠️ UYARI:**
- This is a DESTRUCTIVE operation / Bu YIKICI bir işlemdir
- All uncommitted changes will be lost permanently / İşlenmemiş tüm değişiklikler kalıcı olarak kaybolacak
- Cannot be undone easily / Kolayca geri alınamaz
- Always create a backup branch first / Her zaman önce bir yedek dalı oluşturun

**Safe approach with backup / Yedekle güvenli yaklaşım:**
```bash
# Create backup branch first / Önce yedek dalı oluştur
git branch backup-before-reset

# Then reset / Sonra sıfırla
git reset --hard origin/main
```

---

### 2.6 Complete Update Workflow / Tam Güncelleme İş Akışı

#### Recommended safe workflow / Önerilen güvenli iş akışı:

```bash
# 1. Check current status / Mevcut durumu kontrol et
git status

# 2. Fetch latest changes from remote / Uzak depodan son değişiklikleri getir
git fetch

# 3. Check what's new / Yeni olanı kontrol et
git log HEAD..origin/main --oneline

# 4. Review the changes / Değişiklikleri gözden geçir
git diff HEAD origin/main

# 5. Merge the changes / Değişiklikleri birleştir
git merge origin/main

# 6. Check the result / Sonucu kontrol et
git status
git log --oneline -5
```

#### Quick update (if you're confident) / Hızlı güncelleme (kendinizden eminseniz):

```bash
git pull origin main
```

**Note / Not:** `git pull` = `git fetch` + `git merge`

---

## Section 3: Merge Conflict Resolution / Bölüm 3: Birleştirme Çakışması Çözümü

### 3.1 Identifying Merge Conflicts / Birleştirme Çakışmalarını Tanımlama

When Git cannot automatically merge changes, it will report conflicts: / Git değişiklikleri otomatik olarak birleştiremediğinde çakışmaları bildirir:

```
CONFLICT (content): Merge conflict in path/to/file.txt
Automatic merge failed; fix conflicts and then commit the result.
```

**Common conflict scenarios / Yaygın çakışma senaryoları:**
- Two people edited the same line in the same file / İki kişi aynı dosyadaki aynı satırı düzenledi
- One person deleted a file while another modified it / Bir kişi bir dosyayı silerken diğeri değiştirdi
- Changes in nearby lines that Git cannot reconcile / Git'in uzlaştıramadığı yakındaki satırlardaki değişiklikler

---

### 3.2 Conflict Markers / Çakışma İşaretleyicileri

Git uses special markers to show conflicting sections: / Git çakışan bölümleri göstermek için özel işaretleyiciler kullanır:

```
<<<<<<< HEAD
Your local changes / Yerel değişiklikleriniz
=======
Changes from remote / Uzak depodan gelen değişiklikler
>>>>>>> origin/main
```

**Marker breakdown / İşaretleyici ayrıntısı:**
- `<<<<<<< HEAD` - Start of your local changes / Yerel değişikliklerinizin başlangıcı
- `=======` - Separator between changes / Değişiklikler arasındaki ayırıcı
- `>>>>>>> origin/main` - End of remote changes / Uzak değişikliklerin sonu

---

### 3.3 Step-by-Step Conflict Resolution Process / Adım Adım Çakışma Çözümü Süreci

#### Step 1: Identify conflicted files / Adım 1: Çakışan dosyaları belirle

**Command / Komut:**
```bash
git status
```

**Output example / Çıktı örneği:**
```
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
  both modified:   lib/main.dart
```

#### Step 2: Open the conflicted file / Adım 2: Çakışan dosyayı aç

Open the file in your editor (VSCode recommended): / Dosyayı düzenleyicinizde açın (VSCode önerilir):

```bash
code lib/main.dart
```

#### Step 3: Resolve conflicts manually / Adım 3: Çakışmaları manuel olarak çöz

Edit the file to resolve conflicts by: / Dosyayı düzenleyerek çakışmaları şunları yaparak çözün:
- Keeping your changes / Değişikliklerinizi koruyarak
- Keeping remote changes / Uzak değişiklikleri koruyarak
- Combining both changes / Her iki değişikliği birleştirerek
- Writing entirely new code / Tamamen yeni kod yazarak

**Example resolution / Örnek çözüm:**

Before / Önce:
```dart
<<<<<<< HEAD
void main() {
  print('Local version');
}
=======
void main() {
  print('Remote version');
}
>>>>>>> origin/main
```

After / Sonra:
```dart
void main() {
  print('Merged version');
}
```

#### Step 4: Mark conflicts as resolved / Adım 4: Çakışmaları çözüldü olarak işaretle

**Command / Komut:**
```bash
git add lib/main.dart
```

**Explanation / Açıklama:**
- Stages the resolved file / Çözülen dosyayı hazırlar
- Tells Git the conflict is resolved / Git'e çakışmanın çözüldüğünü söyler

#### Step 5: Complete the merge / Adım 5: Birleşmeyi tamamla

**Command / Komut:**
```bash
git commit
```

**Note / Not:** Git will automatically create a merge commit message. You can edit it if needed. / Git otomatik olarak bir birleştirme işlemesi mesajı oluşturacaktır. Gerekirse düzenleyebilirsiniz.

---

### 3.4 Tools for Resolving Conflicts / Çakışmaları Çözmek İçin Araçlar

#### VSCode Built-in Merge Tool / VSCode Yerleşik Birleştirme Aracı

VSCode provides an excellent visual merge editor: / VSCode mükemmel görsel bir birleştirme düzenleyicisi sağlar:

1. Open the conflicted file / Çakışan dosyayı açın
2. VSCode shows conflict markers with visual indicators / VSCode çakışma işaretleyicilerini görsel göstergelerle gösterir
3. Use the "Accept Current Change" or "Accept Incoming Change" buttons / "Mevcut Değişikliği Kabul Et" veya "Gelen Değişikliği Kabul Et" düğmelerini kullanın
4. Or manually edit the file / Veya dosyayı manuel olarak düzenleyin

**Keyboard shortcuts / Klavye kısayolları:**
- `Alt+Ctrl+Up` / `Alt+Ctrl+Down` - Navigate between conflicts / Çakışmalar arasında gezin
- `Alt+Ctrl+Left` - Accept current change / Mevcut değişikliği kabul et
- `Alt+Ctrl+Right` - Accept incoming change / Gelen değişikliği kabul et

#### Git CLI Tools / Git CLI Araçları

**Using `git mergetool` / `git mergetool` kullanarak:**

Configure a merge tool in your `.gitconfig`: / `.gitconfig` dosyanızda bir birleştirme aracı yapılandırın:

```ini
[merge]
    tool = vscode
[mergetool "vscode"]
    cmd = code --wait $MERGED
```

Then use: / Sonra kullanın:
```bash
git mergetool
```

---

### 3.5 Aborting a Merge / Birleşmeyi İptal Etme

If you want to cancel the merge and return to the previous state: / Birleşmeyi iptal etmek ve önceki duruma dönmek isterseniz:

**Command / Komut:**
```bash
git merge --abort
```

**Explanation / Açıklama:**
- Cancels the current merge / Mevcut birleşmeyi iptal eder
- Returns your working directory to the state before the merge / Çalışma dizininizi birleşmeden önceki duruma döndürür
- Useful if conflicts are too complex or you made a mistake / Çakışmalar çok karmaşıksa veya bir hata yaptıysanız kullanışlıdır

**When to use / Ne zaman kullanılır:**
- When you realize you shouldn't have started the merge / Birleşmeyi başlatmamanız gerektiğini fark ettiğinizde
- When conflicts are overwhelming / Çakışmalar bunaltıcı olduğunda
- When you want to try a different approach / Farklı bir yaklaşım denemek istediğinizde

---

## Section 4: Strategies for Preferring Remote Version / Bölüm 4: Uzak Sürümünü Tercih Etme Stratejileri

### 4.1 Accept Remote Version for Specific File / Belirli Dosya İçin Uzak Sürümünü Kabul Et

#### Git Checkout --theirs / Git Checkout --theirs

**Command / Komut:**
```bash
git checkout --theirs path/to/file.txt
```

**Explanation / Açıklama:**
- Accepts the remote version of a specific file during a merge / Birleşme sırasında belirli bir dosyanın uzak sürümünü kabul eder
- Discards your local changes for that file / O dosya için yerel değişikliklerinizi yoksayar
- Useful when you know the remote version is correct / Uzak sürümün doğru olduğunu bildiğinizde kullanışlıdır

**When to use / Ne zaman kullanılır:**
- During a merge conflict / Birleşme çakışması sırasında
- When you want to keep the remote version of a specific file / Belirli bir dosyanın uzak sürümünü tutmak istediğinizde
- When your local changes to that file are no longer relevant / O dosyadaki yerel değişiklikleriniz artık ilgili değilse

**Complete workflow / Tam iş akışı:**
```bash
# During a merge conflict / Birleşme çakışması sırasında
git checkout --theirs lib/main.dart
git add lib/main.dart
git commit
```

---

### 4.2 Accept Local Version for Specific File / Belirli Dosya İçin Yerel Sürümünü Kabul Et

#### Git Checkout --ours / Git Checkout --ours

**Command / Komut:**
```bash
git checkout --ours path/to/file.txt
```

**Explanation / Açıklama:**
- Accepts your local version of a specific file during a merge / Birleşme sırasında belirli bir dosyanın yerel sürümünü kabul eder
- Discards remote changes for that file / O dosya için uzak değişiklikleri yoksayar
- Useful when you want to keep your local changes / Yerel değişikliklerinizi tutmak istediğinizde kullanışlıdır

**When to use / Ne zaman kullanılır:**
- During a merge conflict / Birleşme çakışması sırasında
- When you want to keep your local version of a specific file / Belirli bir dosyanın yerel sürümünü tutmak istediğinizde
- When the remote changes to that file are not needed / O dosyadaki uzak değişiklikler gerekli değilse

**Complete workflow / Tam iş akışı:**
```bash
# During a merge conflict / Birleşme çakışması sırasında
git checkout --ours lib/main.dart
git add lib/main.dart
git commit
```

---

### 4.3 Prefer Remote Version During Merge / Birleşme Sırasında Uzak Sürümünü Tercih Et

#### Git Merge -X theirs / Git Merge -X theirs

**Command / Komut:**
```bash
git merge -X theirs origin/main
```

**Explanation / Açıklama:**
- Uses the "theirs" strategy to automatically resolve conflicts / Çakışmaları otomatik olarak çözmek için "theirs" stratejisini kullanır
- Prefers remote changes when there's a conflict / Çakışma olduğunda uzak değişiklikleri tercih eder
- Still requires manual resolution for complex conflicts / Karmaşık çakışmalar için hala manuel çözüm gerekir

**When to use / Ne zaman kullanılır:**
- When you want to mostly accept remote changes / Çoğunlukla uzak değişiklikleri kabul etmek istediğinizde
- When you trust the remote repository more than your local changes / Yerel değişikliklerinizden daha çok uzak depoya güvendiğinizde
- When you want to minimize manual conflict resolution / Manuel çakışma çözümünü en aza indirmek istediğinizde

**Pros / Avantajlar:**
- Faster conflict resolution / Daha hızlı çakışma çözümü
- Good for syncing with upstream / Upstream ile senkronizasyon için iyi
- Reduces manual work / Manuel işi azaltır

**Cons / Dezavantajlar:**
- May discard important local changes / Önemli yerel değişiklikleri yoksayabilir
- Not suitable for all scenarios / Tüm senaryolar için uygun değil
- Can lose work if not careful / Dikkatli olunmazsa iş kaybedilebilir

---

### 4.4 Prefer Local Version During Merge / Birleşme Sırasında Yerel Sürümünü Tercih Et

#### Git Merge -X ours / Git Merge -X ours

**Command / Komut:**
```bash
git merge -X ours origin/main
```

**Explanation / Açıklama:**
- Uses the "ours" strategy to automatically resolve conflicts / Çakışmaları otomatik olarak çözmek için "ours" stratejisini kullanır
- Prefers local changes when there's a conflict / Çakışma olduğunda yerel değişiklikleri tercih eder
- Still requires manual resolution for complex conflicts / Karmaşık çakışmalar için hala manuel çözüm gerekir

**When to use / Ne zaman kullanılır:**
- When you want to mostly keep your local changes / Çoğunlukla yerel değişikliklerinizi tutmak istediğinizde
- When your local work is more important than remote changes / Yerel çalışmanız uzak değişikliklerden daha önemliyse
- When you're working on a feature branch and want to preserve your work / Bir özellik dalında çalışıyorsanız ve çalışmanızı korumak istiyorsanız

**Pros / Avantajlar:**
- Preserves your local work / Yerel çalışmanızı korur
- Good for feature branches / Özellik dalları için iyi
- Reduces manual work / Manuel işi azaltır

**Cons / Dezavantajlar:**
- May miss important remote updates / Önemli uzak güncellemeleri kaçırabilir
- Can cause integration issues / Entegrasyon sorunlarına neden olabilir
- Not suitable for all scenarios / Tüm senaryolar için uygun değil

---

### 4.5 Completely Discard Local Changes / Yerel Değişiklikleri Tamamen Yoksay

#### Git Reset --hard / Git Reset --hard

**Command / Komut:**
```bash
git reset --hard origin/main
```

**Explanation / Açıklama:**
- Completely resets your local branch to match the remote branch / Yerel dalınızı uzak dalıyla eşleşecek şekilde tamamen sıfırlar
- Discards ALL local changes (committed and uncommitted) / TÜM yerel değişiklikleri yoksayar (işlenmiş ve işlenmemiş)
- Moves the branch pointer to the remote commit / Dal işaretçisini uzak işleme hareket ettirir

**When to use / Ne zaman kullanılır:**
- When you want to completely start fresh / Tamamen sıfırdan başlamak istediğinizde
- When local changes are corrupted or no longer needed / Yerel değişiklikler bozulduğunda veya artık gerekli olmadığında
- When you need to match the remote exactly / Uzakla tam olarak eşleşmeniz gerektiğinde

**⚠️ CRITICAL WARNING / ⚠️ KRİTİK UYARI:**
- This is IRREVERSIBLE / Bu GERİ ALINAMAZ
- All local work will be LOST / Tüm yerel çalışma KAYBOLACAK
- Always create a backup first / Her zaman önce yedek oluşturun

**Safe approach with backup / Yedekle güvenli yaklaşım:**
```bash
# Step 1: Create backup branch / Adım 1: Yedek dalı oluştur
git branch backup-before-hard-reset

# Step 2: Reset to remote / Adım 2: Uzaka sıfırla
git reset --hard origin/main

# If you need to restore later / Daha sonra geri yüklemeniz gerekirse:
git checkout backup-before-hard-reset
```

---

### 4.6 Backup Strategy Before Destructive Operations / Yıkıcı İşlemlerden Önce Yedekleme Stratejisi

#### Create Backup Branch / Yedek Dalı Oluştur

**Command / Komut:**
```bash
git branch backup-branch-name
```

**Explanation / Açıklama:**
- Creates a snapshot of your current branch state / Mevcut dal durumunuzun anlık görüntüsünü oluşturur
- Allows you to return to this state later / Daha sonra bu duruma dönmenizi sağlar
- Essential before destructive operations / Yıkıcı işlemlerden önce gereklidir

**When to use / Ne zaman kullanılır:**
- Before `git reset --hard` / `git reset --hard`'den önce
- Before `git rebase` / `git rebase`'den önce
- Before any operation that might lose work / İş kaybedebilecek herhangi bir işlemden önce

**Best practices / En iyi uygulamalar:**
```bash
# Create descriptive backup names / Açıklayıcı yedek adları oluştur
git branch backup-before-reset-$(date +%Y%m%d)

# Or include current commit / Veya mevcut işlemeyi dahil et
git branch backup-$(git rev-parse --short HEAD)

# Or use a timestamp / Veya zaman damgası kullan
git branch backup-$(date +%Y%m%d-%H%M%S)
```

**Restore from backup / Yedekten geri yükleme:**
```bash
# Simply checkout the backup branch / Sadece yedek dalına checkout yap
git checkout backup-branch-name

# Or merge it back / Veya geri birleştir
git merge backup-branch-name
```

---

### 4.7 Strategy Comparison Table / Strateji Karşılaştırma Tablosu

| Strategy / Strateji | Command / Komut | When to Use / Ne Zaman Kullanılır | Pros / Avantajlar | Cons / Dezavantajlar |
|-------------------|----------------|-----------------------------------|------------------|-------------------|
| Accept remote file / Uzak dosyayı kabul et | `git checkout --theirs <file>` | During merge, want remote version for specific file / Birleşme sırasında, belirli dosya için uzak sürüm istenir | Precise control / Hassas kontrol | Must do per file / Dosya başına yapılmalı |
| Accept local file / Yerel dosyayı kabul et | `git checkout --ours <file>` | During merge, want local version for specific file / Birleşme sırasında, belirli dosya için yerel sürüm istenir | Precise control / Hassas kontrol | Must do per file / Dosya başına yapılmalı |
| Prefer remote merge / Uzak birleşmeyi tercih et | `git merge -X theirs` | Want mostly remote changes / Çoğunlukla uzak değişiklikler istenir | Fast, automatic / Hızlı, otomatik | May lose local work / Yerel iş kaybedilebilir |
| Prefer local merge / Yerel birleşmeyi tercih et | `git merge -X ours` | Want mostly local changes / Çoğunlukla yerel değişiklikler istenir | Preserves work / İş korur | May miss remote updates / Uzak güncellemeler kaçırılabilir |
| Hard reset / Sert sıfırlama | `git reset --hard` | Completely discard local / Yereli tamamen yoksay | Clean slate / Temiz sayfa | IRREVERSIBLE / GERİ ALINAMAZ |
| Backup branch / Yedek dalı | `git branch backup` | Before destructive ops / Yıkıcı işlemlerden önce | Safety net / Güvenlik ağı | None / Yok |

---

## Section 5: Best Practices and Safety Tips / Bölüm 5: En İyi Uygulamalar ve Güvenlik İpuçları

### 5.1 Always Create Backup Branches / Her Zaman Yedek Dalları Oluşturun

**Why / Neden:**
- Provides a safety net for recovery / Kurtarma için güvenlik ağı sağlar
- Allows experimentation without fear / Korkusuz deneme yapmanızı sağlar
- Essential for destructive operations / Yıkıcı işlemler için gereklidir

**How / Nasıl:**
```bash
# Before any risky operation / Her riskli işlemden önce
git branch backup-$(date +%Y%m%d-%H%M%S)

# Example / Örnek:
git branch backup-20240127-143022
```

---

### 5.2 Commit or Stash Uncommitted Changes / İşlenmemiş Değişiklikleri İşleyin veya Stash Edin

**Why / Neden:**
- Prevents accidental loss of work / Yanlışlıkla iş kaybını önler
- Makes updates cleaner / Güncellemeleri daha temiz hale getirir
- Allows easy rollback / Kolay geri alma sağlar

**Option 1: Commit changes / Seçenek 1: Değişiklikleri işleyin:**
```bash
git add .
git commit -m "WIP: Work in progress before update"
```

**Option 2: Stash changes / Seçenek 2: Değişiklikleri stash edin:**
```bash
git stash push -m "Stash before update"

# Later, restore / Daha sonra geri yükle:
git stash pop
```

**When to use which / Hangisini ne zaman kullanmalısınız:**
- **Commit / İşleme:** When changes are meaningful and should be preserved / Değişiklikler anlamlıysa ve korunmalıysa
- **Stash / Stash:** When changes are temporary or experimental / Değişiklikler geçici veya deneyselse

---

### 5.3 Use Git Fetch Before Git Pull / Git Pull'dan Önce Git Fetch Kullanın

**Why / Neden:**
- Lets you see what's coming / Ne geleceğini görmenizi sağlar
- Prevents surprises / Sürprizleri önler
- Allows informed decisions / Bilgili kararlar vermenizi sağlar

**Best practice / En iyi uygulama:**
```bash
# Step 1: Fetch to see what's new / Adım 1: Yeni olanı görmek için getir
git fetch

# Step 2: Review the changes / Adım 2: Değişiklikleri gözden geçir
git log HEAD..origin/main --oneline
git diff HEAD origin/main

# Step 3: Decide how to proceed / Adım 3: Nasıl ilerleyeceğinize karar verin
# - Merge if changes look good / Değişiklikler iyi görünüyorsa birleştirin
# - Rebase if you want linear history / Doğrusal geçmiş istiyorsanız rebase edin
# - Create backup if uncertain / Emin değilseniz yedek oluşturun

# Step 4: Execute your chosen strategy / Adım 4: Seçtiğiniz stratejiyi uygulayın
git merge origin/main  # or / veya git rebase origin/main
```

---

### 5.4 Review Changes with Git Diff Before Merging / Birleştirmeden Önce Git Diff ile Değişiklikleri Gözden Geçirin

**Why / Neden:**
- Understand what will change / Neyin değişeceğini anlayın
- Identify potential conflicts early / Potansiyel çakışmaları erken belirleyin
- Make informed decisions / Bilgili kararlar verin

**Commands / Komutlar:**
```bash
# See commit history difference / İşleme geçmiş farkını gör
git log HEAD..origin/main --oneline

# See detailed code changes / Detaylı kod değişikliklerini gör
git diff HEAD origin/main

# See changes to specific file / Belirli dosyadaki değişiklikleri gör
git diff HEAD origin/main -- path/to/file.txt

# See statistics / İstatistikleri gör
git diff --stat HEAD origin/main
```

---

### 5.5 Use Git Log --graph to Visualize Branch History / Dal Geçmişini Görselleştirmek İçin Git Log --graph Kullanın

**Why / Neden:**
- Understand branch relationships / Dal ilişkilerini anlayın
- Visualize merge points / Birleşme noktalarını görselleştirin
- Identify divergent history / Ayrık geçmişi belirleyin

**Commands / Komutlar:**
```bash
# Basic graph view / Temel grafik görünümü
git log --graph --oneline --all

# More detailed graph / Daha detaylı grafik
git log --graph --oneline --all --decorate

# With date and author / Tarih ve yazarla birlikte
git log --graph --oneline --all --decorate --date=short

# Last 20 commits only / Sadece son 20 işlem
git log --graph --oneline --all -20
```

**Example output / Örnek çıktı:**
```
* a1b2c3d (HEAD -> main) feat: Add new feature
*   e5f6g7h Merge branch 'feature-branch'
|\
| * h8i9j0k feat: Feature branch work
* | k1l2m3n fix: Bug fix
|/
* n4o5p6q chore: Initial commit
```

---

### 5.6 Regular Communication with Team / Ekip ile Düzenli İletişim

**Why / Neden:**
- Prevents conflicting changes / Çakışan değişiklikleri önler
- Coordinates work effectively / Çalışmayı etkili bir şekilde koordine eder
- Reduces merge conflicts / Birleşme çakışmalarını azaltır

**Best practices / En iyi uygulamalar:**
- Communicate before pushing to shared branches / Paylaşılan dallara push etmeden önce iletişim kurun
- Use pull requests for code review / Kod incelemesi için pull request kullanın
- Document breaking changes / Bozucu değişiklikleri belgeleyin
- Coordinate major refactoring efforts / Büyük yeniden düzenleme çabalarını koordine edin

---

### 5.7 Keep Your Branches Short-Lived / Dallarınızı Kısa Ömürlü Tutun

**Why / Neden:**
- Reduces merge complexity / Birleşme karmaşıklığını azaltır
- Makes conflicts easier to resolve / Çakışmaları çözmeyi kolaylaştırır
- Improves code review efficiency / Kod incelemesi verimliliğini artırır

**Best practices / En iyi uygulamalar:**
- Merge feature branches frequently / Özellik dallarını sık sık birleştirin
- Delete merged branches / Birleştirilmiş dalları silin
- Keep branches focused on single features / Dalları tek özelliklere odaklı tutun
- Avoid long-running feature branches / Uzun süre çalışan özellik dallarından kaçının

---

### 5.8 Use Meaningful Commit Messages / Anlamlı İşleme Mesajları Kullanın

**Why / Neden:**
- Makes history easier to understand / Geçmişi anlamayı kolaylaştırır
- Helps with conflict resolution / Çakışma çözümüne yardımcı olur
- Improves team collaboration / Ekip işbirliğini iyileştirir

**Best practices / En iyi uygulamalar:**
```bash
# Good / İyi:
git commit -m "fix: Resolve deadlock in answerQuestion function"

# Bad / Kötü:
git commit -m "update stuff"
```

**Commit message format / İşleme mesajı formatı:**
```
type(scope): subject

body

footer
```

**Types / Tipler:**
- `feat`: New feature / Yeni özellik
- `fix`: Bug fix / Hata düzeltmesi
- `docs`: Documentation changes / Dokümantasyon değişiklikleri
- `style`: Code style changes / Kod stili değişiklikleri
- `refactor`: Code refactoring / Kod yeniden düzenleme
- `test`: Adding or updating tests / Test ekleme veya güncelleme
- `chore`: Maintenance tasks / Bakım görevleri

---

### 5.9 Test After Merging / Birleştirmeden Sonra Test Edin

**Why / Neden:**
- Catches integration issues / Entegrasyon sorunlarını yakalar
- Ensures code still works / Kodun hala çalıştığını sağlar
- Prevents deploying broken code / Bozuk kod dağıtmayı önler

**Best practices / En iyi uygulamalar:**
```bash
# After merging / Birleştirmeden sonra
git merge origin/main

# Run tests / Testleri çalıştır
flutter test

# Run the app / Uygulamayı çalıştır
flutter run

# Check for issues / Sorunları kontrol et
flutter analyze
```

---

### 5.10 Safety Checklist Before Destructive Operations / Yıkıcı İşlemlerden Önce Güvenlik Kontrol Listesi

Before running any destructive command, verify: / Herhangi bir yıkıcı komut çalıştırmadan önce doğrulayın:

- [ ] Have I created a backup branch? / Yedek dalı oluşturdum mu?
- [ ] Have I committed or stashed my changes? / Değişikliklerimi işledim veya stash ettim mi?
- [ ] Do I understand what this command will do? / Bu komutun ne yapacağını anlıyor muyum?
- [ ] Can I recover if something goes wrong? / Bir şeyler ters giderse kurtarabilir miyim?
- [ ] Have I communicated with my team? / Ekibimle iletişim kurdum mu?

If you answer NO to any question, STOP and reconsider. / Herhangi bir soruya HAYIR cevabı verirseniz, DURUN ve yeniden düşünün.

---

## Section 6: Quick Reference Command Sheet / Bölüm 6: Hızlı Referans Komut Sayfası

### 6.1 Essential Git Commands / Temel Git Komutları

| Command / Komut | Purpose / Amaç | When to Use / Ne Zaman Kullanılır |
|----------------|----------------|-----------------------------------|
| `git status` | Check repository state / Depo durumunu kontrol et | Anytime / Her zaman |
| `git remote -v` | View remote repositories / Uzak depoları görüntüle | Check remotes / Uzakları kontrol et |
| `git branch -a` | List all branches / Tüm dalları listele | Check branches / Dalları kontrol et |
| `git log --oneline -5` | Show recent commits / Son işlemleri göster | Check history / Geçmişi kontrol et |
| `git fetch` | Download remote changes / Uzak değişiklikleri indir | Before updating / Güncellemeden önce |
| `git pull origin main` | Fetch and merge / Getir ve birleştir | Quick update / Hızlı güncelleme |
| `git merge origin/main` | Merge remote changes / Uzak değişiklikleri birleştir | After fetch / Getirdikten sonra |
| `git rebase origin/main` | Rebase on remote / Uzakta rebase et | Want linear history / Doğrusal geçmiş istenir |
| `git reset --hard origin/main` | Reset to remote / Uzaka sıfırla | Discard local / Yereli yoksay |
| `git stash` | Save temporary changes / Geçici değişiklikleri kaydet | Before update / Güncellemeden önce |
| `git stash pop` | Restore stashed changes / Stash edilenleri geri yükle | After update / Güncellemeden sonra |

---

### 6.2 Comparison Commands / Karşılaştırma Komutları

| Command / Komut | Purpose / Amaç | Example / Örnek |
|----------------|----------------|-----------------|
| `git log HEAD..origin/main` | Show remote commits not in local / Yerelde olmayan uzak işlemleri göster | See what's new / Yeni olanı gör |
| `git diff HEAD origin/main` | Show code differences / Kod farklarını göster | Review changes / Değişiklikleri gözden geçir |
| `git diff --stat HEAD origin/main` | Show change statistics / Değişiklik istatistiklerini göster | Quick overview / Hızlı genel bakış |
| `git log --graph --oneline` | Visualize branch history / Dal geçmişini görselleştir | Understand structure / Yapıyı anla |

---

### 6.3 Conflict Resolution Commands / Çakışma Çözümü Komutları

| Command / Komut | Purpose / Amaç | When to Use / Ne Zaman Kullanılır |
|----------------|----------------|-----------------------------------|
| `git status` | Identify conflicted files / Çakışan dosyaları belirle | During merge / Birleşme sırasında |
| `git checkout --theirs <file>` | Accept remote version / Uzak sürümünü kabul et | Prefer remote / Uzayı tercih et |
| `git checkout --ours <file>` | Accept local version / Yerel sürümünü kabul et | Prefer local / Yereli tercih et |
| `git add <file>` | Mark conflict resolved / Çakışmayı çözüldü olarak işaretle | After resolving / Çözdükten sonra |
| `git commit` | Complete merge / Birleşmeyi tamamla | After resolving all conflicts / Tüm çakışmaları çözdükten sonra |
| `git merge --abort` | Cancel merge / Birleşmeyi iptal et | Want to cancel / İptal etmek istenir |

---

### 6.4 Backup and Recovery Commands / Yedekleme ve Kurtarma Komutları

| Command / Komut | Purpose / Amaç | When to Use / Ne Zaman Kullanılır |
|----------------|----------------|-----------------------------------|
| `git branch backup-name` | Create backup branch / Yedek dalı oluştur | Before destructive ops / Yıkıcı işlemlerden önce |
| `git checkout backup-name` | Restore from backup / Yedekten geri yükle | Need to restore / Geri yüklemeye ihtiyaç |
| `git reflog` | View command history / Komut geçmişini görüntüle | Lost commits / Kayıp işlemler |
| `git reset --hard HEAD@{n}` | Reset to previous state / Önceki duruma sıfırla | Recovery / Kurtarma |

---

### 6.5 Merge Strategy Commands / Birleştirme Strateji Komutları

| Command / Komut | Purpose / Amaç | Pros / Avantajlar | Cons / Dezavantajlar |
|----------------|----------------|------------------|-------------------|
| `git merge origin/main` | Standard merge / Standart birleşme | Preserves history / Geçmişi korur | Creates merge commits / Birleşme işlemleri oluşturur |
| `git merge -X theirs origin/main` | Prefer remote / Uzayı tercih et | Auto-resolves conflicts / Çakışmaları otomatik çözer | May lose local work / Yerel iş kaybedilebilir |
| `git merge -X ours origin/main` | Prefer local / Yereli tercih et | Preserves work / İş korur | May miss remote updates / Uzak güncellemeler kaçırılabilir |
| `git rebase origin/main` | Rebase on remote / Uzakta rebase et | Linear history / Doğrusal geçmiş | Rewrites history / Geçmişi yeniden yazar |

---

### 6.6 Workflow Quick Reference / İş Akışı Hızlı Referansı

#### Standard Update Workflow / Standart Güncelleme İş Akışı

```bash
# 1. Check status / Durumu kontrol et
git status

# 2. Fetch changes / Değişiklikleri getir
git fetch

# 3. Review changes / Değişiklikleri gözden geçir
git log HEAD..origin/main --oneline
git diff HEAD origin/main

# 4. Merge / Birleştir
git merge origin/main

# 5. Verify / Doğrula
git status
```

#### Safe Update with Backup / Yedekle Güvenli Güncelleme

```bash
# 1. Create backup / Yedek oluştur
git branch backup-before-update

# 2. Fetch and review / Getir ve gözden geçir
git fetch
git log HEAD..origin/main --oneline

# 3. Merge / Birleştir
git merge origin/main

# 4. Test / Test et
# (run your tests / testlerinizi çalıştırın)

# 5. If needed, restore / Gerekirse geri yükle
git checkout backup-before-update
```

#### Conflict Resolution Workflow / Çakışma Çözümü İş Akışı

```bash
# 1. Start merge / Birleşmeyi başlat
git merge origin/main

# 2. Identify conflicts / Çakışmaları belirle
git status

# 3. Resolve conflicts / Çakışmaları çöz
# (edit files / dosyaları düzenle)

# 4. Mark resolved / Çözüldü olarak işaretle
git add conflicted-file.txt

# 5. Complete merge / Birleşmeyi tamamla
git commit

# 6. If needed, abort / Gerekirse iptal et
git merge --abort
```

#### Reset to Remote Workflow / Uzaka Sıfırlama İş Akışı

```bash
# 1. ⚠️ Create backup / ⚠️ Yedek oluştur
git branch backup-before-reset

# 2. ⚠️ Stash or commit changes / ⚠️ Değişiklikleri stash et veya işle
git stash push -m "Before reset"

# 3. ⚠️ Reset to remote / ⚠️ Uzaka sıfırla
git reset --hard origin/main

# 4. If needed, restore / Gerekirse geri yükle
git checkout backup-before-reset
```

---

### 6.7 Common Scenarios and Solutions / Yaygın Senaryolar ve Çözümler

| Scenario / Senaryo | Solution / Çözüm | Commands / Komutlar |
|-------------------|------------------|-------------------|
| Just want latest changes / Sadece son değişiklikleri istiyorum | Simple pull / Basit pull | `git pull origin main` |
| Want to review before merging / Birleştirmeden önce gözden geçirmek istiyorum | Fetch then merge / Getir sonra birleştir | `git fetch` → `git log HEAD..origin/main` → `git merge origin/main` |
| Have uncommitted changes / İşlenmemiş değişikliklerim var | Stash then update / Stash et sonra güncelle | `git stash` → `git pull` → `git stash pop` |
| Want clean linear history / Temiz doğrusal geçmiş istiyorum | Rebase / Rebase et | `git fetch` → `git rebase origin/main` |
| Merge conflicts / Birleşme çakışmaları | Resolve manually / Manuel çöz | Edit files → `git add` → `git commit` |
| Want to discard all local work / Tüm yerel işimi yoksaymak istiyorum | Hard reset / Sert sıfırlama | `git branch backup` → `git reset --hard origin/main` |
| Accidentally reset wrong / Yanlışlıkla yanlış sıfırladım | Restore from backup / Yedekten geri yükle | `git checkout backup` |
| Want to see what changed / Neyin değiştiğini görmek istiyorum | Diff / Fark | `git diff HEAD origin/main` |
| Branch is behind remote / Dal uzaktan geride | Fetch and merge / Getir ve birleştir | `git fetch` → `git merge origin/main` |
| Want to prefer remote version / Uzak sürümünü tercih etmek istiyorum | Merge with theirs / Onlarla birleştir | `git merge -X theirs origin/main` |

---

### 6.8 Emergency Recovery Commands / Acil Durum Kurtarma Komutları

| Command / Komut | Purpose / Amaç | Warning / Uyarı |
|----------------|----------------|----------------|
| `git reflog` | View command history / Komut geçmişini görüntüle | Essential for recovery / Kurtarma için gerekli |
| `git reset --hard HEAD@{1}` | Undo last command / Son komutu geri al | Use reflog to find hash / Hash bulmak için reflog kullan |
| `git fsck --lost-found` | Find lost commits / Kayıp işlemleri bul | Advanced / İleri düzey |
| `git cherry-pick <commit>` | Apply specific commit / Belirli işlemeyi uygula | Can cause conflicts / Çakışmalara neden olabilir |

---

## Appendix / Ek

### A. Git Configuration / Git Yapılandırması

**Set default branch name / Varsayılan dal adını ayarla:**
```bash
git config --global init.defaultBranch main
```

**Set your name and email / Adınızı ve e-postanızı ayarlayın:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Set merge tool / Birleştirme aracını ayarlayın:**
```bash
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait $MERGED"
```

---

### B. Useful Aliases / Yararlı Kısayollar

Add these to your `.gitconfig` file: / Bunları `.gitconfig` dosyanıza ekleyin:

```ini
[alias]
    # Status shortcuts / Durum kısayolları
    st = status
    co = checkout
    br = branch
    
    # Log shortcuts / Günlük kısayolları
    lg = log --graph --oneline --all --decorate
    ll = log --oneline -10
    
    # Diff shortcuts / Fark kısayolları
    df = diff
    dfl = diff HEAD..origin/main
    
    # Update shortcuts / Güncelleme kısayolları
    up = pull origin main
    fe = fetch
    
    # Conflict shortcuts / Çakışma kısayolları
    ours = checkout --ours
    theirs = checkout --theirs
    
    # Backup shortcuts / Yedekleme kısayolları
    save = !git branch backup-$(date +%Y%m%d-%H%M%S)
```

---

### C. Additional Resources / Ek Kaynaklar

**Official Git Documentation / Resmi Git Dokümantasyonu:**
- https://git-scm.com/doc

**Git Interactive Tutorial / Git Etkileşimli Öğretici:**
- https://learngitbranching.js.org/

**Visual Git Reference / Görsel Git Referansı:**
- https://marklodato.github.io/visual-git-guide/

**Git Cheatsheet / Git Kopya Kağıdı:**
- https://education.github.com/git-cheat-sheet-education.pdf

---

## Conclusion / Sonuç

This guide provides comprehensive instructions for updating your local Git repository from the remote repository. Always remember to: / Bu rehber, yerel Git deponuzu uzak depodan güncellemek için kapsamlı talimatlar sağlar. Her zaman şunları hatırlayın:

1. **Create backups before destructive operations** / **Yıkıcı işlemlerden önce yedek oluşturun**
2. **Review changes before merging** / **Birleştirmeden önce değişiklikleri gözden geçirin**
3. **Use `git fetch` before `git pull`** / **`git pull`'dan önce `git fetch` kullanın**
4. **Test after merging** / **Birleştirmeden sonra test edin**
5. **Communicate with your team** / **Ekibinizle iletişim kurun**

Happy coding! / İyi kodlamalar!

---

**Document Version / Doküman Sürümü:** 1.0  
**Last Updated / Son Güncelleme:** 2024-01-27  
**Repository / Depo:** literature_board_game  
**Remote URL / Uzak URL:** https://github.com/sametunsal/literature_board_game.git
