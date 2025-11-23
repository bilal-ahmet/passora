# Google Passwords CSV İçe Aktarma Rehberi

## Google Passwords'den CSV Dışa Aktarma

1. Chrome tarayıcınızda `chrome://password-manager/settings` adresine gidin
2. "Download file" veya "Dışa Aktar" seçeneğine tıklayın
3. CSV dosyası bilgisayarınıza indirilecektir

## Desteklenen CSV Formatı

Passora artık Google Passwords'ün CSV formatını tam olarak desteklemektedir:

```csv
name,url,username,password,note
Amazon,https://www.amazon.com,user@email.com,mypassword,Bu bir not
Facebook,https://www.facebook.com,myusername,pass123,
```

### Sütun Açıklamaları:
- **name**: Hesap veya site adı (Passora'da "title" olarak kullanılır)
- **url**: Web sitesi adresi
- **username**: Kullanıcı adı veya e-posta
- **password**: Şifre (zorunlu)
- **note**: Notlar (opsiyonel)

## İçe Aktarma Adımları

1. Passora uygulamasını açın
2. Ayarlar (Settings) sayfasına gidin
3. "İçe Aktar" (Import) butonuna tıklayın
4. Google Passwords'den dışa aktardığınız CSV dosyasını seçin
5. Önizleme ekranında şifrelerinizi kontrol edin
6. "İçe Aktar" (Import) butonuna tıklayarak işlemi tamamlayın

## Özellikler

- ✅ Google Passwords formatını tam destek
- ✅ Boş alanları otomatik handle eder
- ✅ Çoklu URL'leri destekler
- ✅ URL'den otomatik başlık çıkarma
- ✅ Detaylı hata mesajları
- ✅ İçe aktarma önizlemesi

## Sorun Giderme

### "Şifre bulunamadı" hatası
- CSV dosyasının ilk satırında header'lar olmalıdır: `name,url,username,password,note`
- En az bir `password` sütunu bulunmalıdır
- Dosya boş olmamalıdır

### Bazı şifreler içe aktarılmadı
- Şifre alanı boş olan satırlar otomatik olarak atlanır
- Console loglarını kontrol edin: `flutter logs` komutuyla detaylı bilgi alabilirsiniz

### Encoding sorunu (Türkçe karakterler)
- CSV dosyasının UTF-8 encoding ile kaydedildiğinden emin olun
- Google Passwords otomatik olarak UTF-8 kullanır

## Veri Güvenliği

- İçe aktarılan tüm şifreler master password ile şifrelenir
- CSV dosyasını içe aktardıktan sonra güvenli bir şekilde silin
- Passora şifrelerinizi cihazınızda lokal olarak saklar

## Desteklenen Diğer Formatlar

Passora ayrıca şu formatlardaki CSV dosyalarını da destekler:
- Chrome/Edge Password Manager
- Firefox Password Manager
- Generic CSV (url, username, password sütunları ile)

---

**Not:** CSV dosyaları düz metin formatında olduğu için hassas bilgiler içerir. İçe aktarma işleminden sonra dosyayı güvenli bir şekilde silin.
