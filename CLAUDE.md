# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# huzur_islamda

İslami yaşam uygulaması (Flutter): namaz vakitleri, akıllı zikirmatik, içerik akışı (dua/hadis/ayet), AI asistan (Gemini), Firebase auth + Firestore, RevenueCat abonelik, AdMob reklamlar. Detaylı özellik dökümü: `UYGULAMA_OZELLIKLERI.md`.

## Komutlar

- Analiz: `flutter analyze` — her kod değişikliğinden sonra çalıştır.
- Codegen (Hive adapter'ları): `dart run build_runner build --delete-conflicting-outputs`
- Çalıştırma: `flutter run` — flavor YOK, tek entrypoint `lib/main.dart`.
- Test: `test/` dizini yok; test altyapısı henüz kurulmadı.
- Cloud Functions (`functions/`, TypeScript): `npm run build` / `npm run lint` / `npm run deploy` (functions dizini içinde).
- DİKKAT: Kökteki `Makefile` başka bir projeden (`qr_menu_system_flutter`) kalma — bu projede KULLANMA.

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

## Bilinen tuzaklar

- `.env` pubspec assets'te → app bundle'a gömülüyor ve kod her zaman `GEMINI_API_KEY_DEV` okuyor. Plan: key rotasyonu + Gemini çağrısını Cloud Function'a taşıma (`functions/src/index.ts` içindeki `deleteUserAccount` pattern'i örnek).
- Firestore `whereIn` 30 değer limiti — post servislerinde henüz chunk'lanmadı (`firestore_post_service.dart`).
- `PostRepositoryRemote` içinde `UnimplementedError` stub'ları, `NotificationRepositoryRemote` içinde TODO'lar var (örn. `cancelDhikrReminderNotification`).
- RevenueCat: customer info listener yok; abonelik düşüşü (downgrade) senkronize edilmiyor.
- iOS Google girişi: `Info.plist`'teki `GIDClientID` ve URL scheme, `GoogleService-Info.plist`'teki `CLIENT_ID`/`REVERSED_CLIENT_ID` ile birebir aynı olmalı (bundle id `com.omran.huzurislamda`). `lib/firebase_options.dart` hâlâ eski `com.example.huzurIslamda` bundle id'sini taşıyor → `flutterfire configure` yeniden çalıştırılmalı.
- Disk dolunca `flutter test` hata vermek yerine takılır (`No space left on device` yalnızca log'da görünür); önce `df -h /` kontrol et.
- `.cursorrules` dosyası mimariyi anlatır ama kısmen eski: router için `@TypedGoRoute` der, gerçekte düz `GoRoute` kullanılıyor; DI kurulumu `AppScreen`'de değil `main.dart`'ta yapılır. Çelişkide bu dosya (CLAUDE.md) geçerlidir.
