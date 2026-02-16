# Huzur İslamda — Uygulama Özellikleri

**Huzur İslamda**, Kur’an ve sünnet ışığında daha huzurlu, bilinçli ve dengeli bir yaşam sürmene yardımcı olmak için tasarlanmış bir mobil uygulamadır. Modern hayatın yoğunluğu içinde ibadetlerini ve günlük rutinini düzenli ve sürdürülebilir tutmayı hedefler.

---

## 1. Hoş Geldin ve Tanıtım (Onboarding)

- **Amaç:** Uygulamanın değerini kısa ve net biçimde anlatır.
- **Sayfalar:**
  - **Hoş Geldiniz:** İslamın ışığında huzurlu, dengeli bir yaşam ve ibadet rutini desteği.
  - **Namaz Vakitleri:** Günlük namaz vakitleri, konuma göre hesaplama ve hatırlatmalar.
  - **Akıllı Zikirmatik:** Günlük zikir oluşturma, sayma, takip ve ruh haline göre zikir seti.
  - **Başlamaya Hazır mısın?:** Kullanıcıyı kayıt veya girişe davet eden son sayfa.
- Tek animasyon ilk sayfada, sade ve okunaklı bir sunum.

---

## 2. Kimlik Doğrulama (Auth)

### Giriş ve Kayıt
- **E-posta ve şifre** ile giriş ve kayıt.
- **Google ile Giriş Yap** (tek dokunuşla giriş).
- **Apple ile Giriş Yap** (iOS uyumluluk ve gizlilik).
- **E-posta doğrulama:** Giriş sonrası e-posta doğrulanana kadar yönlendirme.
- **Şifremi Unuttum:** E-posta üzerinden şifre sıfırlama (Reset Password) ekranı.

### Güvenlik ve Akış
- Onboarding tamamlandıktan sonra giriş/kayıt ekranlarına yönlendirme.
- Giriş yapılmadan korumalı sayfalara erişim engellenir; gerekirse otomatik yönlendirme.
- Profil oluşturulmamışsa “Profil Oluştur” ekranına yönlendirme.

---

## 3. Ana Ekranlar (Alt Sekmeler)

Uygulama **beş ana sekme** ile kullanılır: Akış (Flow), Asistan, Namaz, Zikir, Profil.

---

## 4. Akış (Flow) — İçerik Akışı

- **Amaç:** Dua, hadis ve Kur’an içeriklerini tek bir akışta sunar.
- **İçerik türleri (etiketler ve renklerle ayrılmış):**
  - **Dua**
  - **Hadis**
  - **Kuran** (Kur’an ayetleri)
- **Özellikler:**
  - **Sonsuz kaydırma:** Aşağı kaydırdıkça yeni gönderiler yüklenir.
  - **Gönderi kartları:** Başlık, Arapça metin (varsa, sağdan sola), Türkçe açıklama.
  - **Gönderi detayı:** Karta tıklanınca tam içerik sayfası açılır.
  - **Kaydet:** Gönderiyi “kaydedilenler”e ekleme (Saved Posts).
  - **Raporlama:** Uygunsuz içerik bildirimi (Post Report).
  - **Asistanla devam:** Gönderi detayından ilgili gönderi bağlamında asistan sohbetine geçiş (Assistant for Post).
- **Reklam:** Belirli aralıklarla yerel (native) reklam kartları; premium kullanıcılarda reklam gösterilmez.

---

## 5. Asistan (Assistant)

- **Amaç:** İslami konularda soru-cevap ve sohbet deneyimi.
- **Genel asistan:**
  - “Merhaba, ben senin asistanınım.” ile karşılama.
  - Sorular, dualar, Kur’an ve hadisler, İslam ile ilgili merak edilenler sorulabilir.
  - Öneri etiketlerine tıklayarak hızlı soru başlatma.
  - Sohbet geçmişi (son iki mesaj) bağlam olarak kullanılır; kişi adı, yaş ve cinsiyet (profil varsa) cevap kişiselleştirmesinde kullanılabilir.
- **Gönderi bağlamında asistan (Assistant for Post):**
  - Bir Flow gönderisinin detayından açılır.
  - “Bu gönderi konusu hakkında ne sormak istersin?” tarzı bir giriş.
  - Gönderi metni asistan bağlamına eklenir; sorular o gönderiyle sınırlı veya onunla ilişkili yanıtlar üretebilir.
- **Teknik:** İnternet kontrolü; bağlantı yoksa uygun hata mesajı.

---

## 6. Namaz Vakitleri (Prayer)

- **Vakitler:** İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı — liste halinde, saat:dakika formatında.
- **Konum:** Kullanıcının **ilçe (district)** seçimiyle vakitler hesaplanır; ülke ve şehir de profil/konum akışında kullanılır.
- **Yer seçici:** “Yer seç” ile ilçe değiştirilebilir; vakitler seçilen yere göre güncellenir.
- **Görsel:** Şu anki vakit satırı vurgulanır (highlight).
- **Kalan süre:** Bir sonraki namaz vaktine kalan süre metin olarak gösterilir (örn. “X saat Y dakika”); her dakika güncellenir.
- **Bildirimler:** Namaz vakitleri için hatırlatma bildirimleri planlanır (ör. bir haftalık periyot); ayarlardan bildirimler açılıp kapatılabilir.

---

## 7. Zikir (Dhikr) — Akıllı Zikirmatik

### Zikir listesi ve takip
- Günlük zikirler liste halinde; her zikir için hedef sayı ve mevcut sayı gösterilir.
- Zikir kartına tıklanınca **Zikir Detay** ekranı açılır; burada sayacı artırarak zikir sayılır.
- Tamamlanan zikirler işaretlenir; gruptaki zikirlerde birini bitirince sıradakine geçilebilir.

### Zikir oluşturma (üç yol)
1. **Manuel:** “Zikir oluştur” ile isim ve hedef sayı (varsayılan 33) girilerek tek zikir oluşturulur.
2. **Namaz için zikirler:** Namaz sonrası okunacak zikir seti tek seferde oluşturulur (hızlı erişim).
3. **Ruh haline göre zikirler:** “Ruh haline göre zikir” ekranında mood’lar listelenir; bir ruh hali seçilince o mood’a özel zikir seti oluşturulur (örn. huzur, sabır, şükür).

### Hatırlatma
- Zikir hatırlatması aynı gün saat 22:00’de planlanır (“Bugünkü zikirlerini tamamlamayı unutma”).
- Günün zikirleri tamamlandığında o güne ait zikir hatırlatması iptal edilir.

### Senkronizasyon
- Zikirler cihazda (Hive) ve isteğe bağlı olarak bulutta (Firestore) tutulabilir; senkronizasyon ile veri bütünlüğü sağlanır.

---

## 8. Profil ve Hesap

### Profil oluşturma / düzenleme
- **Profil oluştur:** İlk kez giriş sonrası ad, soyad, doğum tarihi, cinsiyet ve konum (ülke, şehir, ilçe) ile profil tamamlanır.
- **Profili düzenle:** Ayarlar veya profil sekmesinden mevcut bilgiler güncellenir.
- **Şifre değiştir:** E-posta/şifre ile giriş yapan kullanıcılar için şifre değiştirme ekranı.

### Destek paketleri (Premium)
- **Haftalık (weekly)** ve **yıllık (yearly)** destek paketleri tanımlıdır.
- Premium kullanıcılar reklamsız deneyimden yararlanır (ör. Flow’da native reklam gösterilmez).

---

## 9. Ayarlar (Settings)

### Etkileşimler
- **Bildirimler:** Aç/kapa; namaz ve zikir hatırlatmaları bu ayara bağlıdır.
- **Titreşim:** Bildirim veya etkileşimlerde titreşim kullanımı.

### Hakkında
- **Uygulama Hakkında:** Uygulamanın amacı, zikir/namaz/akış/asistan vb. özelliklerin kısa açıklaması; içeriğin fetva niteliği taşımadığı ve sorumluluk kullanıcıda olduğu belirtilir.
- **Gizlilik Politikası:** Toplanan veriler, saklama, güvenlik, üçüncü taraflar ve kullanıcı hakları.
- **Kullanım Koşulları:** Kişisel kullanım, içerik sorumluluğu, yasaklı kullanım, hesap sonlandırma ve sorumluluk sınırlaması.

### Hesap
- **Profili düzenle**, **Şifreyi değiştir**, **Çıkış yap**, **Hesabı sil** seçenekleri.
- **Sürüm bilgisi:** Uygulama sürümü ekranın altında gösterilir.

---

## 10. Diğer Özellikler

### Kaydedilen gönderiler (Saved Posts)
- Flow’da kaydedilen gönderiler ayrı bir listede (sonsuz kaydırma ile) görüntülenir.
- Profil veya menüden “Kaydedilenler”e gidilir.

### Raporlama
- Flow gönderilerinde “Raporla” ile uygunsuz içerik bildirimi yapılabilir.

### Reklamlar (AdMob)
- **Banner** ve **native** reklamlar kullanılır.
- Belirli işlemlerde (ör. zikir oluşturma sonrası) **interstitial** reklam gösterilebilir.
- Premium kullanıcılarda reklamlar devre dışıdır.

### Çevrimdışı / bağlantı
- Bağlantı kontrolü (connectivity); asistan gibi özelliklerde “İnternet yok” uyarısı verilir.
- Zikirler yerel veritabanında tutulduğu için çevrimdışı da kullanılabilir.

### Teknik altyapı (kısa)
- **Firebase:** Auth, Firestore, Cloud Functions.
- **Hive:** Yerel zikir ve tercih verisi.
- **go_router:** Sayfa yönlendirme ve korumalı rotalar.
- **Provider:** Bağımlılık enjeksiyonu ve state yönetimi.
- **Türkçe** arayüz ve kullanıcı mesajları.

---

## Özet Tablo

| Alan            | Özellikler |
|-----------------|------------|
| **Onboarding**  | 4 sayfa, uygulama tanıtımı, animasyon |
| **Auth**        | E-posta/şifre, Google, Apple, e-posta doğrulama, şifre sıfırlama |
| **Flow**        | Dua / hadis / Kur’an akışı, kaydet, raporla, detay, asistanla devam, reklam (premium hariç) |
| **Asistan**     | Genel İslami sohbet, gönderi bağlamında sohbet, öneri etiketleri |
| **Namaz**       | 6 vakit, ilçe seçimi, kalan süre, vakit bildirimleri |
| **Zikir**       | Oluştur (manuel / namaz / ruh hali), say, takip, 22:00 hatırlatma, senkron |
| **Profil**      | Oluştur, düzenle, şifre değiştir, premium (haftalık/yıllık) |
| **Ayarlar**     | Bildirim, titreşim, hakkında, gizlilik, kullanım koşulları, çıkış, hesap silme |
| **Ek**          | Kaydedilen gönderiler, raporlama, AdMob, çevrimdışı zikir |

---

*Bu metin, Huzur İslamda uygulamasının mevcut kod ve arayüz yapısına göre hazırlanmış özellik özetidir. Sunulan içerikler genel bilgilendirme amaçlıdır; dini veya hukuki açıdan nihai karar mercii değildir.*
