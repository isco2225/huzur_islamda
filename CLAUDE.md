# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# huzur_islamda

İslami yaşam uygulaması (Flutter): namaz vakitleri, akıllı zikirmatik, içerik akışı (dua/hadis/ayet), AI asistan (Gemini), Firebase auth + Firestore, RevenueCat abonelik, AdMob reklamlar. Detaylı özellik dökümü: `UYGULAMA_OZELLIKLERI.md`.

## Komutlar

- Analiz: `flutter analyze` — her kod değişikliğinden sonra çalıştır. `lib/` içinde önceden var olan 6 `info` vardır; yeni uyarı eklememek yeterli.
- Test: `flutter test` (tüm suite, ~35-70 sn) · `flutter test test/domain` (katman) · `flutter test test/ui/dhikr` (özellik) · `flutter test test/data/services/hive_service_test.dart` (tek dosya) · `flutter test --name "metin"` (isimle filtre).
- Codegen (Hive adapter'ları): `dart run build_runner build --delete-conflicting-outputs`
- Çalıştırma: `flutter run` — flavor YOK, tek entrypoint `lib/main.dart`.
- Cloud Functions (`functions/`, TypeScript, Node 22): `npm run build` / `npm run lint` / `npm run serve` (emülatör) / `npm run deploy` (functions dizini içinde).

## Mimari (Compass MVVM)

- Katmanlar: `lib/ui` (feature başına `views/` + `view_models/` + `widgets/`) → `lib/domain` (feature başına models + use_cases) → `lib/data` (repositories → services). `lib/app` ortak widget/util/router/theme.
- Erişim zinciri: View → ViewModel → Repository/UseCase → Service. View'lar servise veya repository'ye doğrudan erişmez.
- Screen/View ayrımı: `{Feature}Screen` = StatefulWidget (lifecycle, ViewModel oluşturma, `command.handleError/handleCompleted` bağlama); `{Feature}View` = StatelessWidget (saf UI, ViewModel parametre olarak gelir).
- State: `ValueNotifier` + `ValueListenableBuilder` / `ListenableBuilder`. ChangeNotifier/Consumer KULLANMA.
- Async işlemler: Command pattern (`Command0`/`Command1`, `lib/app/utils/command.dart`) + `sealed class Result<T>` (Ok/Error, `lib/app/utils/result.dart`). Tüm repository/use case metodları `Result<T>` döner; pattern matching ile işlenir.
- DI: Tüm service/repository/use case nesneleri `main.dart` içinde elle kurulur → `AppScreen`'e constructor ile geçirilir → `AppScreen` (`lib/app/views/app_screen.dart`) `MultiProvider` ile sağlar → Screen'ler `context.read<T>()` ile alır.
- Router: `go_router`, path sabitleri `lib/app/router/app_routes.dart`, tanımlar `app_router.dart` (düz `GoRoute`, typed route DEĞİL). Auth durumuna göre `redirect` + `refreshListenable` var.
- Local cache: Hive (`Dhikr` ve `Prayer` box'ları, adapter'lar codegen ile üretiliyor); basit ayarlar SharedPreferences.
- Backend: Firebase (Auth, Firestore, Cloud Functions). Hassas işlemler `functions/src/index.ts` içindeki callable function pattern'i ile yapılır (örnek: `deleteUserAccount`).
- Barrel export'lar: `app/app.dart`, `data/data.dart`, `domain/domain.dart`, `ui/ui.dart` — import'larda bunları kullan; yeni dosyayı ilgili barrel'a ekle.

## Test

- Plan ve kapsam: `docs/TEST_PLANI.md`; sonuçlar, bulunan hatalar ve tur tur düzeltme geçmişi: `docs/TEST_RAPORU.md`. `test/` ağacı `lib/` ağacını birebir yansıtır (`test/ui/prayer/view_models/prayer_view_model_test.dart` gibi).
- Yalnızca `flutter_test`; mockito/mocktail YOK. Tüm sahte nesneler elle yazılmıştır ve `test/helpers/helpers.dart` barrel'ından gelir:
  - `fakes/fake_repositories.dart`: her soyut repository için `implements` fake'i. `ValueNotifier`'ları dışa açar, çağrıları `calls` listesine `'method(arg=value)'` biçiminde kaydeder, varsayılan `Ok` döner; `xxxResult` alanı veya `onXxx` handler'ı ile sonuç değiştirilir.
  - `fakes/fake_services.dart`: somut servislerin `implements` fake'leri (SDK başlatılmaz).
  - `fakes/fake_use_cases.dart`: bağımlılığı içeride kuran use case/servisler için `extends` + `override` (örn. `FakeConnectivityUseCase`).
  - `fixtures.dart`: `Fixtures.user()/dhikr()/prayer(days: 7)/post()/appPreferences(...)` model kurucuları.
- Yeni repository/servis eklerken karşılık gelen fake'i de ekle; yeni ViewModel için `build()` yardımcı fonksiyonu + `setUp`/`tearDown(viewModel.dispose)` kalıbını izle.
- Gerçek altyapı testleri: `HiveService` geçici dizinde gerçek Hive ile (`Hive.init(tempDir)`, `deleteBoxFromDisk`), `SharedPreferencesService` `setMockInitialValues` ile, asset okuyan servisler gerçek `assets/data/*.json` ile (`TestWidgetsFlutterBinding.ensureInitialized()` gerekir).
- Kapsam dışı: Firebase, AdMob, RevenueCat, bildirim ve izin platform çağrıları (refactor gerektirir). İzin testleri `skipOnIos` ile yalnızca permission_handler dalını (macOS/Linux host) çalıştırır.
- Testte bulunan ama henüz düzeltilmeyen hata için doğru davranışı iddia eden testi `skip: 'KNOWN BUG: …'` ile yaz; düzeltince `skip`'i kaldır (şu an atlanan KNOWN BUG testi yok).

## Kurallar

- Kullanıcıyla Türkçe konuş; kod, yorum ve commit mesajları İngilizce. Kullanıcıya görünen uygulama metinleri Türkçe (`AppStrings` veya ilgili constants).
- Commit formatı: `Feat:` / `Refactor:` / `Fix:` / `Docs:` prefix + açıklayıcı cümle.
- Yeni paket eklemeden önce kullanıcıya sor.
- Text widget'larında `textScaler` desteğini unutma (erişilebilirlik).
- Uygulama sadece portrait mode.
- ViewModel'lerde `dispose()` ile Command/ValueNotifier temizliği zorunlu; async sonrası `context` kullanmadan önce `mounted` kontrolü yap.
- Renk/string/tema sabitleri `lib/app/core/` altında (`AppColors`, `AppStrings`, `AppTheme`); hardcode etme.
- Hata mesajları: `exceptionToUserFriendlyMessage` yalnızca tipli exception'ları (`AuthException`, `DhikrException`… ve `UserMessageException`) çevirir; düz `Exception('...')` kullanıcıya her zaman "Bilinmeyen bir hata oluştu" olarak gider. Kullanıcıya gösterilecek Türkçe bir mesaj için `UserMessageException('mesaj', cause: e)` kullan (teknik ayrıntı `cause`'da loglanır, UI'a sızmaz); İngilizce geliştirici mesajları düz `Exception` kalabilir.
- Her Screen, çalıştırdığı her Command için `initState`'te `handleError(context)` kaydeder; kaydedilmeyen komutun hatası kullanıcıya hiç ulaşmaz. `handleError` sonucu temizlediği için view içi `command.error` tabanlı hata widget'ları çalışmaz — kalıcı hata durumu gerekiyorsa `running` + veri null'luğuna bak (örn. `PrayerView`).
- Ölü kod bırakma: kullanılmayan widget/ViewModel/yardımcı ve boş barrel dosyaları 31 Ağustos 2026'da toplu temizlendi (`docs/TEST_RAPORU.md` §11); yeni dosya eklerken barrel'a bağla, kaldırırken testini de kaldır.

## Bilinen tuzaklar

- `.env` pubspec assets'te → app bundle'a gömülüyor ve kod her zaman `GEMINI_API_KEY_DEV` okuyor (`assistant_service.dart`). Plan: key rotasyonu + Gemini çağrısını Cloud Function'a taşıma (`functions/src/index.ts` içindeki `deleteUserAccount` pattern'i örnek).
- Firestore `whereIn` 30 değer limiti — post servislerinde henüz chunk'lanmadı (`firestore_post_service.dart`).
- `PostRepositoryRemote` içinde `UnimplementedError` stub'ları (create/update/fetch/delete/fetchByUser), `NotificationRepositoryRemote.cancelDhikrReminderNotification` de `UnimplementedError`; `UserProfileViewModel` boş iskelet.
- RevenueCat: customer info listener yok; abonelik düşüşü (downgrade) senkronize edilmiyor.
- iOS Google girişi: `Info.plist`'teki `GIDClientID` ve URL scheme, `GoogleService-Info.plist`'teki `CLIENT_ID`/`REVERSED_CLIENT_ID` ile birebir aynı olmalı (bundle id `com.omran.huzurislamda`). `lib/firebase_options.dart` hâlâ eski `com.example.huzurIslamda` bundle id'sini taşıyor → `flutterfire configure` yeniden çalıştırılmalı.
- Disk dolunca `flutter test` hata vermek yerine takılır (`No space left on device` yalnızca log'da görünür); önce `df -h /` kontrol et.
- `.cursorrules` dosyası mimariyi anlatır ama kısmen eski: router için `@TypedGoRoute` der, gerçekte düz `GoRoute` kullanılıyor; DI kurulumu `AppScreen`'de değil `main.dart`'ta yapılır. Çelişkide bu dosya (CLAUDE.md) geçerlidir.
