# Huzur İslamda — Test Planı

Tarih: 2026-08-31 · Sürüm: 1.2.2+9 · Flutter 3.38.5 / Dart 3.10.4

## 1. Amaç ve kapsam

Projede bu çalışmadan önce hiç otomatik test yoktu (`test/` dizini mevcut değildi). Bu plan, mevcut Compass MVVM mimarisinin (View → ViewModel → Repository/UseCase → Service) **platform kanalına ihtiyaç duymadan** test edilebilen tüm katmanlarını kapsamayı; platform SDK'sına bağlı olan (Firebase, AdMob, RevenueCat, bildirim, izin) kısımları ise açıkça "kapsam dışı / refactor gerektirir" olarak işaretlemeyi hedefler.

Testler yalnızca `flutter_test` ile yazılır. Proje kuralı gereği (yeni paket eklemeden önce sor) **mockito/mocktail gibi hiçbir paket eklenmemiştir**; tüm sahte nesneler (fake) elle yazılmıştır.

## 2. Test seviyeleri

| Seviye | Ne test edilir | Araç | Bağlayıcı (binding) |
|---|---|---|---|
| Birim (saf Dart) | Modeller, value object'ler, enum'lar, use case'ler, ViewModel'ler, repository orkestrasyonu, `Result`/`Command` | `flutter_test` + elle yazılmış fake'ler | Gerekmez |
| Birim (servis, gerçek altyapı) | `HiveService` (geçici dizinde gerçek Hive), `SharedPreferencesService` (`setMockInitialValues`), asset yükleyen servisler (gerçek `assets/data/*.json`) | `flutter_test` | `TestWidgetsFlutterBinding` |
| Widget | Ortak widget'lar (`AppButton`, `AppTextField`, `BaseScaffold` …), `BuildContext` extension'ları (hata mesajı eşleme, snackbar, responsive) | `testWidgets` | Otomatik |
| Entegrasyon / E2E | Firebase, AdMob, RevenueCat, gerçek cihaz akışları | — | **Kapsam dışı** (bkz. §7) |

## 3. Fake stratejisi

- **Soyut repository'ler** (`AuthRepository`, `UserRepository`, `DhikrRepository`, `PrayerRepository`, `NotificationRepository`, `AppRepository`, `AssistantRepository`, `PurchaseRepository`, `PostRepository`, `PlacesRepository`, `ReportRepository`) → `test/helpers/fakes/fake_repositories.dart` içinde `implements` ile tam arayüz fake'i. Her fake; `ValueNotifier`'larını dışa açar, çağrı günlüğü (`calls`) tutar ve metod sonuçları test tarafından ayarlanabilir.
- **Somut servisler** (`HiveService<T>`, `PrayerService`, `FirestoreDhikrService`, `FirestoreUserService`, `NotificationService`, `PlaceSelectorService`, `SharedPreferencesService`, `ReportService`, `AssistantService`) → `test/helpers/fakes/fake_services.dart` içinde `implements` ile. Dart somut sınıfa `implements` uygulanmasına izin verdiğinden SDK başlatılmaz.
- **Somut use case'ler** (`ConnectivityUseCase` gibi bağımlılığı içeride kuranlar) → testte `extends` + `override`.
- **Sabit veriler** → `test/helpers/fixtures.dart` (`Fixtures.user/dhikr/prayer/post/…`).

## 4. Kapsam matrisi (ne, nerede, öncelik)

Öncelik: **P0** = iş kuralı taşıyan / regresyon riski yüksek, **P1** = model & dönüşüm, **P2** = ince sarmalayıcı / düşük mantık.

### 4.1 `lib/app` — altyapı

| Birim | Öncelik | Test dosyası | Odak |
|---|---|---|---|
| `Result<T>` | P0 | `test/app/utils/result_test.dart` | Ok/Error, `asOk`/`asError`, exhaustive switch |
| `Command0/Command1` | P0 | `test/app/utils/command_test.dart` | running/error/completed geçişleri, yeniden giriş koruması, dispose sonrası davranış, exception'da `running` sıfırlanması |
| `ResponsiveBreakpoint.fromWidth`, `ResponsiveHelper` v1/v2, `ResponsiveData` | P1 | `test/app/core/responsive/*` | Sınır değerleri (360/600/900/1200), padding/font çarpanları, v1–v2 tutarsızlığı |
| `exceptionToUserFriendlyMessage`, `voFailureToUserFriendlyMessage` | P0 | `test/app/errors/exception_localization_test.dart` | Her exception/failure sınıfı için tam Türkçe metin eşlemesi |
| `showSuccessSnackBar/showErrorSnackBar` | P2 | `test/app/utils/snackbar_test.dart` | Metin ve renk |
| `AppRoutes` | P2 | `test/app/router/app_routes_test.dart` | Benzersizlik, `/` öneki, iç içe yollar |
| Widget'lar (`AppButton`, `AppGradientButton`, `AppTextField`, `CustomDialog`, `TextFieldTitle`, `TitleText`, `SubtitleText`, `BaseColumn`, `BaseScaffold`, `PaginatedBuilder`, `AppResendCodeButton`, `CustomLottieAnimation`) | P1 | `test/app/widgets/*` | Yükleme durumu, callback'ler, obscure toggle, `textScaler` uyumu, build-time callback çağrısı hatası |
| `AppTheme` | P2 | `test/app/core/theme/app_theme_test.dart` | Temel tema garantileri |

### 4.2 `lib/domain` — modeller, value object'ler, use case'ler

| Özellik | Öncelik | Odak |
|---|---|---|
| auth: `Auth`, `Email`, `Password`, `ConfirmPassword`, exception'lar | P0 | formz doğrulayıcıları ve sınır uzunlukları (5/6/64/65), regex; `Auth.isSignedIn()` hatası |
| user: `User`, 4 value object, `UserAgeCalculater`, `CreateUserProfileUseCase`, `DeleteAccountUseCase`, `WipeDataUseCase` | P0 | Tarih formatı/gelecek/1950 öncesi/8 yaş; yaş hesabı doğum günü bugün/yarın; silme akışında `signOut` yalnızca başarıda; wipe sırası ve kısa devre |
| dhikr: `Dhikr`, `GroupDhikrData`, `Mood`, `MoodSuggestion`, `DhikrUseCase` | P0 | `isExpired`; grup ilerleme hesabı; senkronizasyon dalları (bağlantı yok / sayım karşılaştırma / unsynced push); silme akışı |
| prayer: `Prayer`, `PrayerTimes`, `PrayerTimeUseCase` | P0 | API JSON parse (Türkçe anahtarlar), tarih anahtarlama, sonraki vakit / mevcut vakit; önbellek-önce stratejisi |
| post: `Post`, `Emotion` | P1 | `contentType` parse, `arabicContent` asimetrisi, diakritik eşlemeleri |
| notification: 3 zamanlama use case'i | P0 | 7 gün × 5 vakit (Güneş hariç), yalnızca gelecekteki saatler; 22:00 tamamlama hatırlatması; +1/+2/+3 gün oluşturma hatırlatması |
| permission: enum/model, `custom` fabrikaları, `ToPermissionState`, `SyncPermissionUseCase` | P1 | 6 durum eşlemesi; tercih senkronu (verilmemişse tercihi kapat) |
| purchase: `SupportPackage`, 3 use case | P1 | `fromString`; pass-through + Türkçe hata sarmalama |
| app: `AppPreferences`, `AppLoadFailed` | P1 | Varsayılanlar, `yyyy-MM-dd`; `isEmpty()` hatası |
| assistant: `AssistantUseCase` | P0 | Premium limit atlaması; limit 0 → `AssistantDailyLimitExceeded`; azaltma sırası |
| places, connectivity, advert | P2 | `fromJson` (`_id`), enum'lar, premium kullanıcıda reklam gösterilmemesi |

### 4.3 `lib/data` — servisler ve repository'ler

| Birim | Öncelik | Odak |
|---|---|---|
| `HiveService<T>` (gerçek Hive, temp dir) | P0 | CRUD, `getWithFilter` boşta `Ok(null)` semantiği, iç içe `PrayerTimes` adapter round-trip |
| `SharedPreferencesService` | P1 | Yok → `Ok(null)`, kaydet/oku, bozuk JSON |
| `PlaceSelectorService`, `DhikrMoodService` (gerçek asset'ler) | P1 | Asset bütünlüğü: ülke/il/ilçe zinciri, mood → öneri yapısı |
| `AdMobService.get*AdUnitId` | P2 | Boş olmayan id |
| `PrayerRepositoryRemote` | P0 | Yıl+ilçe+il+ülke eşleşince önbellek; eski ilçe temizliği |
| `DhikrRepositoryRemote` | P0 | Notifier geçişleri, senkron dalları, `isSynced` bayrağı, sıralama |
| `UserRepositoryRemote` | P0 | Zorunlu alan koruması; `initUser` null → `Ok(false)` + kayıtsız kullanıcı |
| `NotificationRepositoryRemote` | P0 | Bildirim ID üretimi (taban + hash), 22:00/19:00 hesaplama, iptal filtreleri (1000–9999, 12000–12999) |
| `AppRepositoryRemote` | P1 | Yalnızca başarılı kayıttan sonra notifier güncellenir |
| `PlacesRepositoryRemote`, `PostRepositoryRemote` (saf kısımlar), `ReportRepositoryRemote`, `AssistantRepositoryRemote`, `PurchaseRepositoryRemote` (oturum kapısı) | P1/P2 | Memoization; kısa devreler; hata sarmalama |

### 4.4 `lib/ui` — ViewModel'ler

| ViewModel | Öncelik | Odak |
|---|---|---|
| `SignIn`, `SignUp`, `ResetPassword`, `ChangePassword`, `Onboarding`, `Auth`, `FetchUser`, `User` | P1 | Komut → repository çağrısı, Ok/Error yayılımı |
| `EmailVerificationViewModel` | P0 | Periyodik kontrol döngüsü (`checkInterval` enjekte edilebilir), `onEmailVerified` tetiklemesi |
| `EditProfileViewModel` | P0 | Değişiklik yoksa repository'ye gitmeme; konum güncellemesi → bildirim planlama |
| `DhikrDetailViewModel` | P0 | `progress`/`remainingCount`; artır/azalt/sıfırla; tamamlanınca paywall bir kez; grup modunda sıradaki zikre geçiş |
| `FetchDhikrsViewModel` | P0 | Gruplama, sıralama, gün gezinme (bugünü geçememe) |
| `CreateDhikr`, `MoodSelect` | P1 | Grup kimliği, 3 namaz tesbihatı, mood → zikir dönüşümü, `loadMoods` |
| `FetchPosts`, `SavedPosts`, `PostSave`, `PostReport` | P1 | "Tüm öğeler getirildi" kuralı; bağlantı yok → `ConnectivityNoConnection` |
| `PrayerTimes`, `Prayer` | P1 | Sonuç → state; bildirim kapalıysa kısa devre |
| `BaseSelector`, `Country/State/District`, `PlaceSelector` | P0 | Filtreleme (startsWith), kademeli seçim, `goBack`, `firstWhere` çökme riski |
| `NavigationBarViewModel` | P0 | Her 3. sekme değişiminde reklam |
| `SettingsViewModel` | P1 | `toggleVibration`; bildirim yolu Android dalı |
| `PurchaseViewModel` | P1 | Satın alma sonrası senkron; seçili paket |
| `Assistant`, `AssistantForPost` | P0 | Bağlantı kontrolü, son 2 mesaj geçmişi, yaş/isim türetme, post içeriği |
| `AppViewModel` | P0 | `isSignedIn` dinleyicisi (init/wipe), günlük limit sıfırlama, premium'da AdMob başlatmama, bildirim dalı |

## 5. Çalıştırma

```bash
flutter test                          # tüm suite
flutter test test/domain              # tek katman
flutter test test/domain/prayer/prayer_test.dart   # tek dosya
flutter test --name "fromApiJson"     # isme göre filtre
flutter test -r expanded              # ayrıntılı çıktı
flutter analyze                       # her değişiklikten sonra
```

## 6. Bilinen hatalar için kural

Test sırasında kaynak kodda gerçek bir hata bulunduğunda, test **doğru davranışı** iddia edecek şekilde yazılır ve `skip: 'KNOWN BUG: …'` ile işaretlenir. Böylece suite yeşil kalır, hata test çıktısında görünür kalır ve düzeltme yapıldığında `skip` kaldırılarak test doğrudan regresyon testine dönüşür. Hataların listesi test raporunda (`docs/TEST_RAPORU.md`) verilir.

## 7. Kapsam dışı ve refactor gerektirenler

| Birim | Neden | Önerilen çözüm |
|---|---|---|
| `PrayerService`, `AssistantService` | `http.get/post` doğrudan çağrılıyor, `http.Client` enjekte edilemiyor | Ctor'a `http.Client? client` ekle → `MockClient` (http paketinde mevcut) |
| `AssistantService` prompt/yanıt ayrıştırma | `sendMessage` içinde inline | Saf fonksiyonlara çıkar |
| `PostRepositoryRemote.fetchPosts` | Servis `QuerySnapshot` sızdırıyor | Sayfalama mantığını `List<({id, data})>` üzerinde saf fonksiyona çıkar |
| `PurchaseRepositoryRemote` entitlement eşlemesi | `CustomerInfo` SDK tipi; `_resolveSupportPackageFromInfo` private | `@visibleForTesting` yap |
| `_redirect` (go_router) | Private top-level, 3 Provider + `BuildContext` gerekiyor | `resolveRedirect({location, auth, user, prefs})` saf fonksiyonuna çıkar |
| `ConnectivityUseCase.connectionType()`, `*.withPermissionHandler()`, `VibrationUseCase`, `NotificationService`, `AdMobService` (yükleme/gösterme), `RevenueCatService`, `FirebaseAuthService`, `Firestore*Service`, `HiveInitializerService` | Platform kanalı / SDK | Entegrasyon testi (cihaz/emülatör) veya `integration_test` paketi (ayrı karar) |
| `SettingsViewModel` iOS dalı | `Platform.isIOS` mock'lanamıyor | Platform bilgisini enjekte et |
| Ekranlar (`*Screen`) | Provider + GoRouter + Firebase ağacı | Refactor sonrası widget testi |
