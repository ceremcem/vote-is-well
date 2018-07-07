# Tanım 

Seçim sonuçlarının resmi açıklamalarla tutarlılığını teyit etmek amacıyla hazırlanan servistir. 

## Değerlendirme Algoritması 

1. Twitter'a yüklenmiş sandık sonuç tutanaklarının fotoğrafları [Twitter servisi](./servers/twitter-service) aracılığıyla otomatik olarak okunacak. 
2. Tweet'in içinde ya da yorumunda yazan sandık sonuçları toplanarak seçim sonucu teyit edilecek. 
3. Art niyetli kişi ya da yazılımlar tarafından yanlış şekilde yazılan seçim sonuçlarını elemek için:
    1. "Beğen" butonu kullanılacak. Daha çok beğeni alan seçim sonucu ifadesi _o an için_ doğru kabul edilecek.
    2. Kara listeler yapılacak (kara listedeki kullanıcıların beğenileri dikkate alınmayacak)
    3. Beyaz listeler yapılacak (beyaz listedeki kullanıcıların beğenileri doğrudan geçerli sayılacak)
    4. Otomatik kara liste mekanizması çalışacak (beyaz listedekilerin onayladığının dışındakileri onaylayanlar otomatik olarak kara listeye alınacak)
    
# Gereksinimler 

1. Islak imzalı tutanakların fotoğraflarının [`#TR24Haziran2018`](https://twitter.com/hashtag/TR24Haziran2018?src=hash) hashtag'i ile Twitter'a yüklenmesi gerekiyor. (bkz. [twitter çağrısı](https://twitter.com/ceremcem/status/1010115545465868289)

2. Tutanağın içindeki sayısal değerler, tweetin içine ya da yorum olarak şu formatta yazılmalı: 

        #TR24Haziran2018 sandık: 1234, aaa partisi: 45, bbb partisi 75, geçersiz: 3, toplam: 123
    

    
# Avantajlar

1. Twitter burada dağınık ve halka açık bir veritabanı olarak çalışacak. Böylece servislerimizin doğru sonuç iletip iletmediğinden şüphe edenler olursa ister yazılımı kopyalayıp 
kendi makinalarında çalıştırabilirler, ister kendileri yeniden bir yazılım hazırlayarak resmi sonuçlarla kendileri teyit edebilirler.

# Dezavantajlar

Şimdilik bir dezavantaj görünmüyor. 

# Yol Haritası 

* Beyaz liste/kara liste yerine sandık tutanakları görüntü işleme ile taranarak sonuçlar sisteme otomatik olarak girilecek. 
