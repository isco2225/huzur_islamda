# Huzur İslamda — Test Raporu

Tarih: 2026-08-31 · Sürüm: 1.2.2+9 · Flutter 3.38.5 / Dart 3.10.4 · Plan: `docs/TEST_PLANI.md`

## 1. Özet

| | |
|---|---|
| Toplam test | **1064** (ilk teslimde 1089; ölü v1 responsive testleri ve eski davranışı belgeleyen testler kaldırıldı) |
| Geçen | **1064** (ilk teslimde 1064) |
| Atlanan (`KNOWN BUG`) | **0** (ilk teslimde 25 — bkz. §8 ve §9) |
| Başarısız | **0** |
| Test dosyası | 100 (+5 yardımcı dosya) |
| Test kodu | ≈18.200 satır (uygulama kodu ≈27.900 satır) |
| Çalıştırma | 2 tam çalıştırma, ikisinde de aynı sonuç (flaky test yok) |
| `flutter analyze` | Testlerden kaynaklı 0 sorun; `lib/` içinde önceden var olan 6 `info` |
| Yeni paket | Yok (yalnızca `flutter_test`, elle yazılmış fake'ler) |
| `lib/` değişikliği | İlk teslimde yok; ikinci turda 7, üçüncü turda 11 dosyada hata düzeltmesi (bkz. §8, §9) |

Proje bu çalışmadan önce hiç test içermiyordu. Suite; `lib/app`, `lib/domain`, `lib/data` ve `lib/ui` (ViewModel) katmanlarının platform SDK'sına bağlı olmayan tamamını kapsıyor. Testler sırasında kaynak kodda **22 gerçek hata** tespit edildi (bkz. §3); her biri için doğru davranışı iddia eden ve `skip: 'KNOWN BUG: …'` ile işaretlenmiş bir test yazıldı — hata düzeltildiğinde `skip` kaldırılarak test doğrudan regresyon testine dönüşür.

## 2. Katman bazında sonuçlar

| Katman | Dosya | Geçen | Atlanan | Öne çıkan kapsam |
|---|---|---|---|---|
| `test/app` (altyapı + widget) | 22 | 266 | 9 | `Result`, `Command`, responsive yardımcıları (v1/v2), 54 hata-mesajı eşlemesi, 13 widget, snackbar, rotalar, tema |
| `test/domain` | 24 | 289 | 6 | 8 value object, 10 model, 15 use case (senkronizasyon, bildirim planlama, asistan limiti, izin senkronu) |
| `test/data` | 16 | 230 | 6 | Gerçek Hive (temp dizin), gerçek asset'ler, 11 repository orkestrasyonu, bildirim ID/zaman hesabı |
| `test/ui` + `test/app/view_models` | 38 | 279 | 4 | 36 ViewModel + `AppViewModel` başlatma orkestrasyonu |
| **Toplam** | **100** | **1064** | **25** | |

Yardımcılar (`test/helpers/`): `fixtures.dart` (model kurucuları), `fakes/fake_repositories.dart` (11 soyut repository fake'i + `FakeConnectivityUseCase`), `fakes/fake_services.dart` (13 somut servis fake'i), `fakes/fake_use_cases.dart` (kayıt tutan `AdMobService`/`NotificationService`/`DhikrMoodService` alt sınıfları).

## 3. Bulunan hatalar

Önem: **Yüksek** = kullanıcıya görünür yanlış davranış veya çökme; **Orta** = veri tutarsızlığı / kaynak sızıntısı; **Düşük** = tutarsızlık, ölü kod.

### Yüksek

| # | Konum | Sorun |
|---|---|---|
| 1 | `lib/ui/prayer/place_selector/view_models/place_selector_view_model.dart:129-185` | `getSelectedPlaceName` / `getFullPlaceHierarchy`, `firstWhere` için `orElse` vermiyor; seçili id listede yoksa `StateError` ile çöküyor. |
| 2 | `lib/app/widgets/base/base_scaffold.dart:81` | `onDoubleTap: onScaffoldDoubleTap?.call()` — callback build sırasında bir kez çağrılıyor, dönüş değeri handler olarak geçiliyor; gerçek çift dokunuş hiç çalışmıyor, değer döndüren callback `TypeError` fırlatıyor. Aynı kalıp `onDrawerChanged`/`onEndDrawerChanged` için de (satır 103-104) mevcut. |
| 3 | `lib/domain/notification/use_cases/schedule_prayer_notifications_use_case.dart:27-29` | `districtId!`, `city!`, `country!` `try` bloğunun dışında; konumu `null` olan kullanıcıda `TypeError` fırlıyor, `Ok(false)` dönmesi gerekirdi. |
| 4 | `lib/domain/auth/models/auth.dart:35` | `isSignedIn()` `this != Auth.empty()` ile karşılaştırıyor; `==` override yok → JSON'dan üretilen boş `Auth` bile "oturum açık" sayılıyor. Router `_redirect` bu metodu kullanıyor. |
| 5 | `lib/ui/auth/email_verification/view_models/email_verification_view_model.dart:155` | `dispose()` yalnızca mevcut timer'ı iptal ediyor; dispose anında uçuşta olan kontrol yeni bir `Timer` kuruyor ve repository'yi sorgulamaya devam ediyor (ölçüm: dispose sonrası 5 çağrı). |
| 6 | `lib/app/widgets/buttons/app_resend_code_button.dart:64` | Geri sayım gösterilirken buton tıklanabilir kalıyor (`onPressed` koşulsuz geçiliyor). |
| 7 | `lib/data/repositories/dhikr/dhikr_repository_remote.dart:221-230` | `syncDhikrsToFirestore` başarılı yüklemeden sonra `isSynced`'i yerelde `true` yapmıyor; aynı zikirler her senkronda yeniden yükleniyor. |

### Orta

| # | Konum | Sorun |
|---|---|---|
| 8 | `lib/data/repositories/dhikr/dhikr_repository_remote.dart:154-155` | `updateDhikrLocally`, notifier'ın yayınlanmış listesini yerinde (`removeWhere`) değiştiriyor ve öğeyi listenin sonuna taşıyor. |
| 9 | `lib/data/repositories/dhikr/dhikr_repository_remote.dart:251-253` | `syncDhikrsToLocally` her öğeyi başa ekleyen `saveDhikrLocally` ile kaydediyor; uzak sıralama (yeni→eski) yerelde tersine dönüyor. |
| 10 | `lib/data/repositories/post/post_repository_remote.dart:198` | `fetchPostsByIds` yalnızca `savedPostIds.length == savedPosts.length` kontrolü yapıyor; içerik farklıysa bayat önbellek dönüyor. |
| 11 | `lib/data/services/shared_preferences_sevice.dart:26` | `fetchJson`, `jsonDecode(...) as Map` — depolanan değer dizi ise `TypeError` (dart:core `Error`) fırlıyor ve `on Exception` bloğundan kaçıyor. |
| 12 | `lib/data/services/shared_preferences_sevice.dart:40` | `saveJson`, kodlanamayan bir map için `JsonUnsupportedObjectError` fırlatıyor; yine `on Exception`'dan kaçıyor. |
| 13 | `lib/domain/assistant/use_cases/assistant_use_case.dart:52-54` | Günlük limit mesaj gönderilmeden **önce** azaltılıyor; gönderim başarısız olsa da hak tükeniyor. |
| 14 | `lib/ui/user/user_profile/edit_profile/view_models/edit_profile_view_model.dart:44-51` | `currentUserName/Surname/DateOfBirth/Gender` her erişimde yeni bir `ValueNotifier` döndürüyor; dinleyiciler hiçbir zaman güncellenmiyor. |
| 15 | `lib/domain/user/value_objects/date_of_birth_value_object.dart:16-18` | Boş değer geçerli sayılıyor; `DateOfBirthEmpty` hiç üretilmiyor (ölü failure sınıfı). |

### Düşük

| # | Konum | Sorun |
|---|---|---|
| 16 | `lib/domain/user/models/user.dart:147` | `isEmpty()` kimlik karşılaştırması; yalnızca const `User.empty()` singleton'ı "boş". |
| 17 | `lib/domain/app/models/app_preferences.dart:69` | `isEmpty()` her seferinde yeni (non-const, `DateTime.now()` tabanlı) örnekle karşılaştırıyor → her zaman `false`. |
| 18 | `lib/app/widgets/buttons/app_resend_code_button.dart:55-58` | `resendCooldown` parametresi yok sayılıyor; `60` sabit. |
| 19 | `lib/app/widgets/pagination/paginated_builder.dart:65-69` | `PaginatedBuilder.gridView` sabit 320×320 mavi `Container` çizen bir stub; `itemBuilder`/`itemCount` yok sayılıyor. |
| 20 | `lib/app/core/responsive/responsive_helper.dart:64` ↔ `responsive_helper_v2.dart:66-68` | Büyük ekran font çarpanı v1'de 1.1, v2'de 1.2 (extraLarge 1.4). |
| 21 | `lib/app/core/responsive/responsive_helper.dart:127-129` ↔ `responsive_data.dart:42` | v1 `isLargeScreen` = ≥900, v2 = [600, 900); 700px genişlikte iki extension farklı padding/maxWidth veriyor. İkisi de kullanımda. |
| 22 | `lib/data/repositories/notification/notification_repository_remote.dart:32` | `_generateNotificationId` `hashCode % 1000` kullanıyor (`.abs()` yok). Dart VM'de `String.hashCode` 30-bit pozitif olduğundan pratikte tetiklenmiyor (≈2M string ile doğrulandı); zikir ID üreticileriyle tutarsız. Test atlanmadı, davranış belgelendi. |

### Belgelenen ama hata sayılmayan davranışlar

- `UserRepositoryRemote.initUser` (uid korunur, `isRegistered=false`) ile `fetchAuthenticatedUser` (`User.empty()`) null kullanıcıda farklı davranıyor — kaynak yorumuna göre kasıtlı (router uid'ye ihtiyaç duyuyor).
- `DhikrRepositoryRemote.createGroupDhikrs` ilk hatada duruyor, geri alma yok (kısmi yazım kalıyor).
- `HiveService.getWithFilter` eşleşme yoksa `Ok([])` değil `Ok(null)` döner; `getAll` anahtar sırasına göre döner.
- `PrayerTimeUseCase` bugünün kaydı olmayan uzak veriyi de önbelleğe yazıyor, sonra "Bugünün namaz vakitleri bulunamadı" hatası dönüyor.
- `Post.toJson` `arabicContent: null` → `''` (asimetrik round-trip).
- `FetchUserViewModel`'deki `is Error<User>` dalı ölü (sonuç `Result<bool>`); hata yine de yayılıyor, yalnızca log kayboluyor.
- `PurchaseViewModel` satın alma sonrası senkron hatasını yutup `Ok` dönüyor.
- `AssistantViewModel` limit kontrolü başarısız olsa da kullanıcı mesajını listeye ekliyor.
- `DhikrUseCase`, `dhikr_exceptions.dart`'taki tipli exception'ları hiç kullanmıyor (genel `Exception('User ID is empty')`).
- `NotificationRepositoryRemote.cancelTodayDhikrNotifications` bekleyen bildirim listesini okuyup kullanmıyor.

## 4. Kapsam dışı kalanlar

| Birim | Neden | Öneri |
|---|---|---|
| `PrayerService`, `AssistantService` HTTP çağrıları | `http.get/post` doğrudan; `Client` enjekte edilemiyor | Ctor'a `http.Client? client` → `MockClient` (http paketinde hazır) |
| `AssistantService` prompt kurma / yanıt ayrıştırma | `sendMessage` içinde inline | Saf fonksiyonlara çıkar |
| `PostRepositoryRemote.fetchPosts` sayfalama | `QuerySnapshot` SDK tipi | Filtre/limit mantığını `List<({id, data})>` üzerinde saf fonksiyona çıkar |
| `PurchaseRepositoryRemote` entitlement → paket eşlemesi | `CustomerInfo`; `_resolveSupportPackageFromInfo` private | `@visibleForTesting` |
| `AuthRepositoryRemote` oturum geri yükleme ve `reauthenticate` sağlayıcı tespiti | `firebase_auth.User` kurulamıyor | Kullanıcı bilgisini domain `Auth`'a çeviren adaptör |
| Router `_redirect` | Private top-level, `BuildContext` + 3 Provider | `resolveRedirect({location, auth, user, prefs})` saf fonksiyonu |
| `SettingsViewModel` / `SyncPermissionUseCase` iOS dalları | `Platform.isIOS` mock'lanamıyor (host macOS) | Platform bilgisini enjekte et |
| Firebase, RevenueCat, AdMob (yükleme/gösterme), `flutter_local_notifications`, `permission_handler`, `connectivity_plus`, `HapticFeedback`, `HiveInitializerService` | Platform kanalı | Cihaz/emülatör entegrasyon testi (`integration_test` — ayrı karar) |
| Ekranlar (`*Screen`) | Provider + GoRouter + Firebase ağacı | Yukarıdaki refactor'lar sonrası widget testi |
| `HiveRepositoryRemote`, `VibrationUseCase`, `Permission.toUserFriendly*` | Sırasıyla iki satırlık pass-through / `HapticFeedback` / `BuildContext` | Düşük öncelik |

## 5. Zamana duyarlı testler ve alınan önlemler

- `DateTime.now()` kullanan tüm mantık (zikir süresi dolması, namaz vakti sıradaki/mevcut vakit, doğum tarihi/yaş, 22:00 ve 19:00 hatırlatmaları, günlük limit sıfırlama) "şimdi"ye göreli girdilerle test edildi; beklenen değer çalışma anında hesaplanıyor.
- 22:00 sonrası çalıştırmalarda `ScheduleDhikrReminderUseCase` "bugün" senaryosu doğru dalı seçiyor; `CreateDhikrViewModel`'deki iki iddia `DateTime.now().hour < 22`'ye göre dallanıyor.
- `LogOutViewModel` sabit 3 sn gecikme içeriyor; 3 test gerçekten bekliyor (`Timeout(10s)`). Suite süresine ~9 sn ekliyor; gecikmeyi enjekte edilebilir yapmak önerilir.
- Yalnızca gece yarısını milisaniye düzeyinde kesen bir çalıştırma birkaç varsayılan-zaman iddiasını etkileyebilir.

## 6. Nasıl çalıştırılır

```bash
flutter test                                   # tüm suite (~35-70 sn)
flutter test test/domain                       # katman
flutter test test/ui/dhikr                     # özellik
flutter test test/data/services/hive_service_test.dart
flutter test --name "KNOWN BUG"                # (atlanır) — hata düzeltildikten sonra skip'i kaldır
flutter analyze
```

## 7. Önerilen sonraki adımlar (öncelik sırasıyla)

1. ~~§3 Yüksek öncelikli 7 hatayı düzelt; ilgili testlerden `skip` parametresini kaldır.~~ Yapıldı (§8).
2. `User`, `AppPreferences` için `isEmpty()`'yi alan bazlı yaz (`Auth.isSignedIn` düzeltildi).
3. `PrayerService` ve `AssistantService`'e `http.Client` enjeksiyonu ekle; Gemini prompt/yanıt mantığını saf fonksiyona çıkar (CLAUDE.md'deki Cloud Function taşıma planıyla birleştirilebilir).
4. Router `_redirect` mantığını saf fonksiyona çıkar ve 12+ dalını test et.
5. `ResponsiveHelper` v1/v2 ikiliğini tek sınıfa indir.
6. CI'da `flutter analyze && flutter test` çalıştır.

## 8. Düzeltme durumu (31 Ağustos 2026, ikinci tur)

Yüksek öncelikli 7 hata ile aynı dosyalardaki 2 komşu hata düzeltildi; ilgili 13 testin `skip` parametresi kaldırıldı, hatalı davranışı belgeleyen 2 test silindi, 4 yeni regresyon testi eklendi. `lib/` dışında API imzası değişmedi.

| # | Konum | Düzeltme |
|---|---|---|
| 1 | `place_selector_view_model.dart` | `firstWhere` yerine null dönen `_selected{District,State,Country}Name()` yardımcıları; eksik id'de `null` dönüyor, çökmüyor. |
| 2 | `base_scaffold.dart` | `onDoubleTap` artık lambda ile sarılıyor (build'de çağrılmıyor); `onDrawerChanged`/`onEndDrawerChanged` gerçekten iletiliyor. |
| 3 | `schedule_prayer_notifications_use_case.dart` | Konum alanları yerel değişkenlere alınıp `null`/boş kontrolü yapılıyor; `!` operatörleri kaldırıldı. |
| 4 | `auth.dart` | `isSignedIn()` → `uid.isNotEmpty` (kimlik karşılaştırması yerine alan bazlı; `ValueNotifier` semantiğini değiştirmemek için `==` override eklenmedi). |
| 5 | `email_verification_view_model.dart` | `_isDisposed` bayrağı; uçuştaki kontrol bittikten sonra dispose edilmişse yeni timer kurulmuyor. |
| 6 | `app_resend_code_button.dart` | Geri sayım sırasında `onPressed: null` (buton devre dışı). |
| 7 | `dhikr_repository_remote.dart` | `syncDhikrsToFirestore` başarılı yüklemeden sonra her zikri `isSynced: true` ile yerelde güncelliyor; yerel işaretleme hatası yalnızca loglanıyor. |
| 8 (komşu) | `dhikr_repository_remote.dart` | `updateDhikrLocally` yayınlanmış listeyi yerinde değiştirmiyor, öğeyi yerinde bırakıyor; listede yoksa sona ekliyor. |
| 18 (komşu) | `app_resend_code_button.dart` | Geri sayım `resendCooldown` parametresinden hesaplanıyor (sabit 60 kaldırıldı). |

Kalan 12 atlanan test: #9–#17 ve #19–#21 (bkz. §3 Orta/Düşük).

## 9. Düzeltme durumu (31 Ağustos 2026, üçüncü tur)

Kalan 12 atlanan testin karşılığı olan orta/düşük öncelikli hatalar düzeltildi; artık `KNOWN BUG` ile atlanan test yok. Ayrıca `DhikrUseCase`'te repository'nin üstlendiği `isSynced` işaretleme döngüsü kaldırıldı.

| # | Konum | Düzeltme |
|---|---|---|
| 9 | `dhikr_repository_remote.dart` | `syncDhikrsToLocally` uzak listeyi tersten dolaşıyor; başa ekleyen `saveDhikrLocally` ile notifier uzak (yeni→eski) sırayı koruyor. |
| 10 | `post_repository_remote.dart` | `fetchPostsByIds` önbelleği yalnızca uzunluk değil, id kümesi eşleşiyorsa kullanıyor. |
| 11 | `shared_preferences_sevice.dart` | `fetchJson` çözülen değer `Map` değilse `FormatException` ile `Error` dönüyor (`as` cast kaldırıldı). |
| 12 | `shared_preferences_sevice.dart` | `saveJson`, `JsonUnsupportedObjectError`'ı yakalayıp `Error(Exception)` dönüyor. |
| 13 | `assistant_use_case.dart` | Limit gönderimden önce düşülmeye devam ediyor (yazma hatasında gönderimi engelleyen "fail-closed" davranış korundu) ama gönderim başarısız olursa **iade** ediliyor; iade hatası yalnızca loglanıyor. |
| 14 | `edit_profile_view_model.dart` | `currentUserName/Surname/DateOfBirth/Gender` artık constructor'da oluşturulan, `currentUser` dinleyicisiyle güncellenen ve `dispose`'da temizlenen gerçek notifier'lar. |
| 15 | `date_of_birth_value_object.dart` | Boş değer `DateOfBirthEmpty` üretiyor. Ürün dokümanına göre profil oluşturmada doğum tarihi zorunlu; kayıt ekranındaki alan hatayı yalnızca doğrulama tetiklendiğinde gösteriyor. **Not:** profil düzenleme ekranı DOB hatasını görsel olarak göstermiyor; doğum tarihi boş olan eski kullanıcılar kaydet'e bastığında sessizce engellenir — `DateOfBirthTextField`'a `displayError` bağlanması önerilir. |
| 16 | `user.dart` | `isEmpty()` tüm alanları `User.empty()` değerleriyle karşılaştırıyor. |
| 17 | `app_preferences.dart` | `isEmpty()` dört tercih alanını varsayılanlarla karşılaştırıyor; `lastLimitResetDate` (her zaman "bugün") hariç. |
| 19 | `paginated_builder.dart` | `gridView` gerçek bir `GridView.builder` (varsayılan 2 sütun, `gridDelegate` parametresiyle özelleştirilebilir). |
| 20, 21 | `responsive_helper.dart`, `responsive_extensions.dart` | **Silindi.** `responsive.dart` barrel'ı v1'i zaten `hide` ediyordu; uygulama kodundaki tüm `context.*` çağrıları v2'ye gidiyordu, dolayısıyla v1 ölü koddu ve tutarsızlık kaynağı ortadan kalktı. v1'e ait 22 test ve v1–v2 karşılaştırma testleri kaldırıldı; barrel'ın v2'ye çözümlendiğini doğrulayan bir test eklendi. |
| — | `dhikr_use_case.dart` | `syncDhikrsToFirestore` sonrası `updateDhikrLocally` döngüsü kaldırıldı (repository #7 düzeltmesiyle bunu kendisi yapıyor). |

Doğrulama: `flutter analyze` (yalnızca `lib/`'deki 6 eski `info`), `flutter test` iki ardışık çalıştırmada 1064 geçen / 0 atlanan / 0 başarısız.
