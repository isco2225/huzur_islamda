# huzur_islamda

İslami yaşam uygulaması (Flutter): namaz vakitleri, zikir, AI asistan (Gemini), Firebase auth, RevenueCat abonelik, AdMob reklamlar.

## Komutlar

- Analiz: `flutter analyze` — her kod değişikliğinden sonra çalıştır.
- Codegen (Hive adapter'ları): `dart run build_runner build --delete-conflicting-outputs`

## Mimari (Compass MVVM)

- Katmanlar: `lib/ui` (feature başına `views/` + `view_models/`) → `lib/domain` (models + use_cases) → `lib/data` (repositories → services). `lib/app` ortak widget/util/router.
- State: `ValueNotifier` + `ValueListenableBuilder` / `ListenableBuilder`. ChangeNotifier/Consumer KULLANMA.
- Async işlemler: Command pattern (`Command0`/`Command1`, `lib/app/utils/command.dart`) + `sealed class Result<T>` (Ok/Error, `lib/app/utils/result.dart`).
- View'lar servise doğrudan erişmez: ViewModel → Repository → Service zinciri.
- DI: Provider ile manuel wiring, `main.dart` içinde.
- Barrel export'lar var: `app/app.dart`, `data/data.dart`, `domain/domain.dart`, `ui/ui.dart` — import'larda bunları kullan.

## Kurallar

- Kullanıcıyla Türkçe konuş; kod, yorum ve commit mesajları İngilizce.
- Commit formatı: `Feat:` / `Refactor:` / `Fix:` prefix + açıklayıcı cümle.
- Yeni paket eklemeden önce kullanıcıya sor.
- Text widget'larında `textScaler` desteğini unutma (erişilebilirlik).
- Uygulama sadece portrait mode.

## Bilinen tuzaklar

- `.env` pubspec assets'te → app bundle'a gömülüyor ve kod her zaman `GEMINI_API_KEY_DEV` okuyor. Plan: key rotasyonu + Gemini çağrısını Cloud Function'a taşıma (`functions/src/index.ts` içindeki `deleteUserAccount` pattern'i örnek).
- Firestore `whereIn` 30 değer limiti — post servislerinde henüz chunk'lanmadı (`firestore_post_service.dart`).
- `PostRepositoryRemote` içinde `UnimplementedError` stub'ları var.
- RevenueCat: customer info listener yok; abonelik düşüşü (downgrade) senkronize edilmiyor.
