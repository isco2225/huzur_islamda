import '../../../domain/dhikr/models/dhikr_suggestion.dart';

/// Popular and valuable dhikr suggestions
class DhikrSuggestions {
  DhikrSuggestions._();

  static const List<DhikrSuggestion> suggestions = [
    DhikrSuggestion(
      name: 'Sübhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      benefit:
          'Allah\'ı tüm noksan sıfatlardan tenzih etmek, manevi kirlerden arınmak ve ruhu yüceltmek için.',
    ),
    DhikrSuggestion(
      name: 'Elhamdülillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      benefit:
          'Verilen sayısız nimete şükretmek, kalbi huzurla doldurmak ve nimetin bereketini artırmak için.',
    ),
    DhikrSuggestion(
      name: 'Allahu Ekber',
      arabic: 'اللَّهُ أَكْبَرُ',
      benefit:
          'Allah\'ın yüceliğini kalbe yerleştirmek, dünyevi korkuları yenmek ve sarsılmaz bir cesaret bulmak için.',
    ),
    DhikrSuggestion(
      name: 'La ilahe illallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      benefit:
          'Tevhid inancını tazelemek, imanı güçlendirmek ve kalpteki manevi putları yıkmak için.',
    ),
    DhikrSuggestion(
      name: 'Sübhanallahi velhamdülillahi ve la ilahe illallahu vallahu ekber',
      arabic:
          'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      benefit:
          'Kur\'an\'da "kalıcı salih ameller" olarak müjdelenen; günahları döken ve cennet fidanları sayılan en kıymetli tesbihat.',
    ),
    DhikrSuggestion(
      name: 'Estağfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      benefit:
          'Günahların manevi ağırlığından kurtulmak, ilahi merhamete sığınmak ve rızık kapılarını aralamak için.',
    ),
    DhikrSuggestion(
      name:
          'Estağfirullâhel azîm ellezi lâ ilâhe illâ hüvel hayyel kayyûm ve etûbü ileyh',
      arabic:
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
      benefit:
          'Savaştan kaçmak gibi en büyük günahları işlemiş olsa bile okuyanın affedileceği hadislerle müjdelenen büyük istiğfar.',
    ),
    DhikrSuggestion(
      name: 'Sübhanallahi ve bihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      benefit:
          'Günde 100 defa okunduğunda, deniz köpüğü kadar çok olsa bile günahların silinmesine vesile olan zikir.',
    ),
    DhikrSuggestion(
      name: 'Sübhanallahi ve bihamdihi sübhanallahil azim',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
      benefit:
          'Dile çok hafif, mizanda (terazide) çok ağır ve Rahman olan Allah\'a en sevimli gelen iki kelime.',
    ),
    DhikrSuggestion(
      name: 'La havle ve la kuvvete illa billah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      benefit:
          'Cennet hazinelerinden bir hazine. Güç ve kuvvetin asıl sahibine tam bir teslimiyetle sığınmak için.',
    ),
    DhikrSuggestion(
      name: 'Hasbünallahü ve ni\'mel vekil',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      benefit:
          'Hz. İbrahim\'i ateşte yakmayan teslimiyet sırrı. Sıkıntılar karşısında Allah\'ı en güzel vekil kılmak için.',
    ),
    DhikrSuggestion(
      name:
          'Hasbiyallahu lâ ilâhe illâ hû, aleyhi tevekkeltü ve hüve rabbül arşil azîm',
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      benefit:
          'Sabah ve akşam 7 defa okuyanın, dünya ve ahiret sıkıntılarına Allah\'ın kafi geleceği bildirilen kalkan dua.',
    ),
    DhikrSuggestion(
      name: 'Bismillahirrahmanirrahim',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      benefit:
          'Her hayırlı işin başı; bereket, rahmet ve ilahi koruma kapısını aralamak için.',
    ),
    DhikrSuggestion(
      name: 'Allahümme salli ala Muhammedin ve ala ali Muhammed',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      benefit:
          'Peygamber Efendimiz (s.a.v) ile manevi bağ kurmak, iç sıkıntısını gidermek ve duaların kabulü için.',
    ),
    DhikrSuggestion(
      name: 'Rabbenâ atinâ fid dünyâ haseneten ve fil âhireti haseneten',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
      benefit:
          'Hem dünya hem de ahiret saadetini, iyiliğini ve güzelliğini bir arada isteyen en kapsamlı dua.',
    ),
    DhikrSuggestion(
      name:
          'Rabbenâğfirlî ve li-vâlideyye ve lil-mü\'minîne yevme yekûmül hisâb',
      arabic:
          'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      benefit:
          'Hesap gününde kendisinin, anne-babasının ve tüm inananların affedilmesi için okunan vefalı dua.',
    ),
    DhikrSuggestion(
      name: 'La ilahe illa ente sübhaneke inni küntü minez-zalimin',
      arabic:
          'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      benefit:
          'Karanlıkta ve darda kalındığında okunan, kurtuluş müjdeli Hz. Yunus\'un (a.s) büyük duası.',
    ),
    DhikrSuggestion(
      name: 'Allahümme inneke afüvvün tuhibbül afve fa\'fu annî',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      benefit:
          'Peygamberimizin (s.a.v) öğrettiği; "Allahım sen affedicisin, affetmeyi seversin, beni de affet" manasındaki naif dua.',
    ),
    DhikrSuggestion(
      name: 'Ya Fettâh',
      arabic: 'يَا فَتَّاحُ',
      benefit:
          'Kapalı kapıları aralayan. Maddi ve manevi kilitlenmiş sorunları çözmek, hayır kapılarını açmak için.',
    ),
    DhikrSuggestion(
      name: 'Ya Latîf',
      arabic: 'يَا لَطِيفُ',
      benefit:
          'En ince işleri bilen, lütfeden. Daralan kalpleri ferahlatmak ve zor işleri kolaylaştırmak için.',
    ),
    DhikrSuggestion(
      name: 'Ya Vedûd',
      arabic: 'يَا وَدُودُ',
      benefit:
          'Kalpleri birbirine ısındıran, sevgiyi var eden. Aile içi huzursuzlukları gidermek ve ilahi muhabbete ermek için.',
    ),
    DhikrSuggestion(
      name: 'Ya Rezzâk',
      arabic: 'يَا رَزَّاقُ',
      benefit:
          'Bütün mahlukatın rızkını veren. Maddi sıkıntılardan kurtulmak, borçları ödemek ve haneye bereket çekmek için.',
    ),
    DhikrSuggestion(
      name: 'Ya Hafîz',
      arabic: 'يَا حَفِيظُ',
      benefit:
          'Her şeyi koruyan ve gözeten. Kendini, sevdiklerini, malını ve imanını her türlü kazadan ve beladan muhafaza etmek için.',
    ),
    DhikrSuggestion(
      name: 'Ya Şâfî',
      arabic: 'يَا شَافِي',
      benefit:
          'Maddi ve manevi hastalıklara şifa, dertlere deva bulmak ve Allah\'ın iyileştirici gücüne sığınmak için.',
    ),
    DhikrSuggestion(
      name: 'Yâ Bâkî Entel Bâkî',
      arabic: 'يَا بَاقِي أَنْتَ الْبَاقِي',
      benefit:
          'Kalpteki fani sevgileri temizlemek, dünya dertlerinin geçiciliğini idrak etmek ve mutlak ebedi olan Allah\'a yönelmek için.',
    ),
    DhikrSuggestion(
      name: 'Ya Hayyu ya Kayyum, bi rahmetike esteğis',
      arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
      benefit:
          'Peygamberimizin darda kaldığında okuduğu; "Ey diri ve her şeyi ayakta tutan Rabbim, rahmetine sığınırım" duası.',
    ),
    DhikrSuggestion(
      name: 'Allahümme ente Rabbi la ilahe illa ente',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ',
      benefit:
          'Tövbelerin efendisi; bunu inanarak sabah veya akşam okuyup o gün vefat edenin cennetle müjdelendiği dua.',
    ),
    DhikrSuggestion(
      name: 'Allahümme barik',
      arabic: 'اللَّهُمَّ بَارِكْ',
      benefit:
          'Sahip olunan veya görülen bir nimete karşı, Allah\'tan o nimetin bereketini ve devamını dilemek için.',
    ),
    DhikrSuggestion(
      name: 'Maşaallah',
      arabic: 'مَا شَاءَ اللَّهُ',
      benefit:
          'Allah\'ın dilediği olur anlamında; güzel bir şeye bakarken nazarın ve kötülüğün değmesini engellemek için.',
    ),
  ];
}
