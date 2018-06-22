# Değerlendirme Algoritması 

1. Twitter'a '#TR24Haziran2018' yüklenmiş fotoğraflar [Twitter servisi](./twitter-service) aracılığıyla otomatik olarak okunacak. 
2. Tweet'in içinde ya da yorumunda yazan sandık sonuçları toplanarak seçim sonucu teyit edilecek. 
3. Art niyetli kişi ya da yazılımlar tarafından yanlış şekilde yazılan seçim sonuçlarını elemek için:
  1. "Beğen" butonu kullanılacak.
  2. Kara listeler yapılacak (kara listedeki kullanıcıların beğenileri dikkate alınmayacak)
  3. Beyaz listeler yapılacak (beyaz listedeki kullanıcıların beğenileri doğrudan geçerli sayılacak, bu beğenilerin dışındaki beğenileri yapan kullanıcılar kara listeye alınacak)

# Avantajlar

Twitter burada dağınık ve halka açık bir veritabanı olarak çalışacak. Böylece servislerimizin doğru sonuç iletip iletmediğinden şüphe edenler olursa ister yazılımı kopyalayıp 
kendi makinalarında çalıştırabilirler, ister kendileri yeniden bir yazılım hazırlayarak resmi sonuçlarla kendileri teyit edebilirler.

