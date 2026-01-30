# Huzur Islamda — Uygulama Açıklaması (Gizlilik Politikası ve Kullanım Koşulları Hazırlığı)

Bu belge, **Huzur Islamda** mobil uygulamasının ve özelliklerinin, bir yapay zeka veya hukuki danışman tarafından Gizlilik Politikası (Privacy Policy) ve Kullanım Koşulları (Terms of Use) metinlerinin hazırlanması için kullanılması amacıyla yazılmıştır.

---

## 1. Uygulama Hakkında Genel Bilgi

- **Uygulama adı:** Huzur Islamda  
- **Görünen ad (store):** Huzur Islamda  
- **Tür:** Mobil uygulama (Android ve iOS)  
- **Geliştirme:** Flutter ile geliştirilmiş, tek kod tabanı ile her iki platformda çalışır.  
- **Amaç:** Kullanıcılara İslami içerik, ibadet takibi (zikir, namaz vakitleri), dua ve içerik akışı sunmak; namaz vakitleri bildirimi vermek; İslami konularda metin tabanlı bir yapay zeka asistanı ile yardımcı olmak.

---

## 2. Uygulamanın Temel Özellikleri (Özet)

- Hesap oluşturma ve giriş (e-posta/şifre, Google, Apple)  
- Kullanıcı profili (ad, soyad, doğum tarihi, cinsiyet, ülke/şehir/ilçe seçimi)  
- Zikir (dhikr) oluşturma, takip etme ve tamamlama (yerel + bulut senkronizasyonu)  
- Namaz vakitleri (ilçe bazlı, harici API ile) ve yerel bildirimler  
- İçerik akışı (Flow): dua ve İslami yazılar; paylaşım ve şikayet seçenekleri; favorilere ekleme  
- İslami konularda yardımcı yapay zeka asistanı (Google Gemini API)  
- Reklamlar (Google AdMob: banner ve geçiş reklamları)  
- Uygulama tercihleri: titreşim, bildirimler, onboarding tamamlandı bilgisi (yerel)  
- Çıkış veya hesap silme süreçlerinde kullanıcıya ait verilerin temizlenmesi (wipe data)

---

## 3. Kimlik Doğrulama ve Hesap Yönetimi

### 3.1 Giriş ve Kayıt Yöntemleri

- **E-posta ve şifre:** Kayıt (sign up) ve giriş (sign in) yapılabilir.  
- **Google ile giriş:** Google Sign-In kullanılır; e-posta ve temel profil bilgisi alınır.  
- **Apple ile giriş:** Arayüzde “Apple ile Giriş Yap” seçeneği vardır.  
- **E-posta doğrulama:** Kullanıcıya doğrulama e-postası gönderilir; doğrulama durumu saklanır.

### 3.2 Kullanılan Altyapı

- **Firebase Authentication** kullanılır (hesap oluşturma, giriş, çıkış, hesap silme akışları için).

### 3.3 Hesap Silme

- Kodda hesap silme use case’i (Firestore’dan kullanıcı silme + Firebase Auth’dan hesap silme) tanımlıdır; kullanıcıya hesap silme seçeneği sunulabilir veya sunulmuş olabilir.

---

## 4. Kullanıcı Profili ve Kişisel Veriler

### 4.1 Profilde Tutulan Veriler

Aşağıdaki alanlar kullanıcı profili kapsamında toplanır ve **Firebase Firestore** içindeki `users` koleksiyonunda saklanır:

- **uid** (Firebase Auth kullanıcı kimliği)  
- **email**  
- **name** (ad)  
- **surname** (soyad)  
- **dateOfBirth** (doğum tarihi)  
- **gender** (cinsiyet)  
- **emailVerified** (e-posta doğrulandı mı)  
- **createdAt**, **updatedAt** (kayıt/güncelleme zamanları)  
- **isRegistered** (kayıt tamamlandı mı)  
- **country**, **city**, **districtId** (namaz vakitleri için kullanıcının seçtiği ülke, şehir ve ilçe)

Konum, cihazın GPS’i ile alınmaz; kullanıcı uygulama içinden ülke/şehir/ilçe seçer. Seçimler statik JSON veri setinden (ülke/il/ilçe listesi) yapılır.

### 4.2 Favoriler

- Kullanıcının favorilere eklediği gönderi (post) kimlikleri Firestore’da `users/{uid}/favorites` alt koleksiyonunda tutulur (postId listesi).

---

## 5. Zikir (Dhikr) Özelliği

### 5.1 Ne Yapılır?

- Kullanıcı zikir hedefi oluşturur (isim, hedef sayı, gün).  
- Günlük ilerleme (mevcut sayı, tamamlandı mı) takip edilir.  
- Zikirler gruplanabilir (groupId alanı).

### 5.2 Veri Saklama

- **Yerel:** Hive veritabanında cihazda saklanır (offline kullanım).  
- **Bulut:** İnternet varken Firestore’a senkronize edilir; `users/{userId}/dhikrs` altında tutulur.  
- Kayıtlar: id, userId, name, targetCount, currentCount, day, isCompleted, createdAt, lastUpdatedAt, isSynced, isDeleted, groupId.

---

## 6. Namaz Vakitleri ve Bildirimler

### 6.1 Namaz Vakitleri

- Vakitler **ilçe (district) kimliğine** göre alınır.  
- Harici bir API kullanılır: `https://ezanvakti.imsakiyem.com/api` (ör. `/prayer-times/{districtId}/yearly`).  
- Alınan vakit verisi cihazda **yerel olarak (Hive)** önbelleğe alınır; kullanıcının seçtiği ilçe (country, city, districtId) kullanılır. Cihaz konumu (GPS) kullanılmaz.

### 6.2 Namaz Vakti Bildirimleri

- **flutter_local_notifications** ile **yerel (lokalde)** bildirim planlanır.  
- Bildirimler namaz vakitlerine göre zamanlanır.  
- Kullanıcı ayarlardan bildirimleri açıp kapatabilir.

### 6.3 İzinler (Android)

- POST_NOTIFICATIONS  
- SCHEDULE_EXACT_ALARM  
- USE_EXACT_ALARM (minSdkVersion 33)  
- RECEIVE_BOOT_COMPLETED  
- REQUEST_IGNORE_BATTERY_OPTIMIZATIONS  

(Bildirim ve tam zamanında alarm için; konum izni yok.)

---

## 7. İçerik Akışı (Flow) ve Gönderiler (Posts)

### 7.1 İçerik Kaynağı

- Gönderiler **Firestore** `posts` koleksiyonundan okunur.  
- İçerik türü: başlık, metin, Arapça metin (opsiyonel), kaynak, oluşturulma tarihi, içerik türü (ör. dua) vb.

### 7.2 Kullanıcı Etkileşimleri

- **Paylaş:** Gönderi paylaşımı (uygulama içi paylaşım).  
- **Şikayet et:** Şikayet seçeneği arayüzde vardır (şikayet akışı/backend detayı dokümanda belirtilmemiş olabilir).  
- **Favorilere ekleme:** Favori post kimlikleri kullanıcı hesabına bağlı olarak Firestore’da saklanır.

---

## 8. Yapay Zeka Asistanı

### 8.1 Amaç

- İslami içerik ve ibadetler konusunda kısa, anlaşılır, Türkçe yanıtlar vermek; mümkün olduğunda kaynak belirtmek.

### 8.2 Teknoloji

- **Google Gemini API** kullanılır (`generativelanguage.googleapis.com`, model: `gemini-2.5-flash`).  
- API anahtarı ortam değişkeni (ör. `.env`) ile yönetilir; uygulama sunucuya istek atarken bu anahtarı kullanır.

### 8.3 Asistana Gönderilen Veriler

- Kullanıcının yazdığı **mesaj metni**.  
- **Profil bilgileri:** ad (veya “Kullanıcı”), yaş (doğum tarihinden hesaplanan), cinsiyet.  
- **Konuşma geçmişi:** Son birkaç mesaj (ör. son 2 alışveriş) bağlam için gönderilir.  
- Bu veriler Google’ın Gemini altyapısına iletilir; Gizlilik Politikası’nda açıkça belirtilmelidir.

---

## 9. Reklamlar

- **Google AdMob** kullanılır.  
- **Banner reklamlar** ve **geçiş (interstitial) reklamlar** gösterilir.  
- Reklam birim kimlikleri (ad unit ID) uygulama yapılandırmasından (Android/iOS için ayrı) alınır.  
- AdMob’un kendi veri toplama ve çerez politikaları Gizlilik Politikası’nda referans verilerek belirtilmelidir.

---

## 10. Yerel Veri ve Tercihler (Cihazda)

### 10.1 SharedPreferences (Tercihler)

- **isVibrationEnabled:** Titreşim açık/kapalı.  
- **isNotificationsEnabled:** Namaz bildirimleri açık/kapalı.  
- **isOnboardingCompleted:** Onboarding tamamlandı mı (ilk açılış deneyimi).

### 10.2 Hive (Yerel veritabanı)

- Zikir kayıtları (dhikr).  
- Namaz vakitleri önbelleği (ilçe bazlı).

### 10.3 Konum

- Cihaz konumu (GPS) toplanmaz. Sadece kullanıcının seçtiği ülke/şehir/ilçe (metin/ID) kullanılır; yer seçimi uygulama içi listelerden yapılır.

---

## 11. Üçüncü Taraf Hizmetler ve Veri Akışı

Aşağıdaki üçüncü taraflara veri gidebilir veya onların hizmetleri kullanılır:

| Hizmet / Sağlayıcı | Kullanım Amacı | Gönderilen / İşlenen Veri (Özet) |
|--------------------|----------------|-----------------------------------|
| **Firebase (Google)** | Kimlik doğrulama, veritabanı, (opsiyonel analitik) | Auth bilgileri, e-posta; Firestore’a yazılan tüm kullanıcı ve zikir verisi |
| **Google Sign-In** | Google ile giriş | E-posta, temel profil (Google politikalarına tabi) |
| **Apple** | Apple ile giriş (UI mevcut) | Apple’ın paylaştığı kimlik/profil bilgileri |
| **Google Gemini API** | Yapay zeka asistanı | Mesaj metni, ad, yaş, cinsiyet, sınırlı sohbet geçmişi |
| **Google AdMob** | Reklam | Cihaz/reklam tanımlayıcıları, AdMob politikalarına göre veri |
| **ezanvakti.imsakiyem.com** | Namaz vakitleri API | Sadece ilçe kimliği (districtId) – kişisel kimlik gönderilmez |
| **Hive / SharedPreferences** | Yerel depolama | Sadece cihazda; sunucuya gönderilmez (senkronize edilen zikir verisi Firestore’a ayrıca gider) |

---

## 12. Veri Silme ve Hesap Sonlandırma

- **Wipe Data (veri temizleme):** Çıkış veya hesap silme süreçlerinde:  
  - Yerel zikir verileri (Hive) silinir.  
  - Yerel namaz vakitleri önbelleği temizlenir.  
  - Tüm namaz bildirimleri iptal edilir.  
  - Bellekte tutulan kullanıcı bilgisi temizlenir.  
- Hesap silme akışında Firebase Auth’dan hesap silinir ve Firestore’daki kullanıcı dokümanı (ve ilişkili alt koleksiyonlar) silinebilir.  
- Gemini’ye gönderilen mesajlar Google’ın veri saklama politikasına tabidir; uygulama tarafında sohbet geçmişi kalıcı olarak sunucuda saklanmıyor (sadece istek anında gönderiliyor).

---

## 13. İzinler Özeti

- **Android:** İnternet, bildirimler, tam zamanında alarm, önyükleme sonrası alıcı, pil optimizasyonu istisnası. Konum izni yok.  
- **iOS:** Bildirim izinleri (uyarı, rozet, ses); AdMob ile ilgili tanımlayıcı (Info.plist’te).  
- **Konum:** Sadece kullanıcının manuel seçtiği ülke/şehir/ilçe kullanılır; konum servisi açılmaz.

---

## 14. Gizlilik ve Kullanım Koşulları İçin Önemli Noktalar

- **Veri sorumlusu:** Uygulama sahibi / şirket bilgisi eklenecek.  
- **Veri işleme amaçları:** Hesap yönetimi, namaz vakitleri, zikir takibi, içerik ve favoriler, asistan hizmeti, reklam, uygulama tercihleri.  
- **Yasal dayanak:** Sözleşme, meşru menfaat, açık rıza (ör. bildirim, asistan, reklam için gerekli yerlerde).  
- **Üçüncü taraflar:** Firebase/Google, Google Sign-In, Apple, Gemini, AdMob, namaz vakitleri API’si – her biri için kullanım ve (varsa) veri paylaşımı açıklanmalı.  
- **Saklama süreleri:** Hesap aktifken Firestore/yerel saklama; hesap silindiğinde wipe + Firebase silme.  
- **Kullanıcı hakları:** Erişim, düzeltme, silme, taşınabilirlik, itiraz (KVKK/GDPR’a göre metinde yer verilebilir).  
- **Çocuklar:** Doğum tarihi toplanıyor; yaş sınırı (ör. 13+) ve ebeveyn onayı politikada belirtilmeli.  
- **Uluslararası veri aktarımı:** Firebase ve Google hizmetleri nedeniyle ABD’ye aktarım olabileceği ve uygun güvenceler (sözleşme, vb.) belirtilmeli.  
- **Kullanım koşulları:** Kabul edilebilir kullanım, yasak davranışlar, içerik sorumluluğu, fikri mülkiyet, sınırlı sorumluluk, fesih ve uygulama güncellemeleri.

---

## 15. Dokümanın Kullanımı

Bu metin, Huzur Islamda uygulamasının teknik ve işlevsel özelliklerini özetler. Gizlilik Politikası ve Kullanım Koşulları’nın nihai metni, bu açıklamalar referans alınarak yapay zeka veya hukuki danışman tarafından hazırlanmalı; yargı bölgesi (Türkiye KVKK, AB GDPR vb.) ve uygulama sahibinin ticari tercihleri dikkate alınmalıdır.

**Son güncelleme (referans):** Proje koduna göre hazırlanmıştır; uygulama güncellendikçe bu doküman da güncellenmelidir.
