enum Emotion {
  rizik,
  sabir,
  sukur,
  tevbe,
  korku,
  umut,
  huzur,
  sevgi,
  merhamet,
  iman,
  dua,
  zikir,
  ibadet,
  ahlak,
  aile,
  evlilik,
  egitim,
  saglik,
  olum,
  fitne,
  cihad,
  kader,
  ihlas,
}

extension EmotionExtension on Emotion {
  String get value {
    switch (this) {
      case Emotion.rizik:
        return 'rızık';
      case Emotion.sabir:
        return 'sabır';
      case Emotion.sukur:
        return 'şükür';
      case Emotion.tevbe:
        return 'tevbe';
      case Emotion.korku:
        return 'korku';
      case Emotion.umut:
        return 'umut';
      case Emotion.huzur:
        return 'huzur';
      case Emotion.sevgi:
        return 'sevgi';
      case Emotion.merhamet:
        return 'merhamet';
      case Emotion.iman:
        return 'iman';
      case Emotion.dua:
        return 'dua';
      case Emotion.zikir:
        return 'zikir';
      case Emotion.ibadet:
        return 'ibadet';
      case Emotion.ahlak:
        return 'ahlak';
      case Emotion.aile:
        return 'aile';
      case Emotion.evlilik:
        return 'evlilik';
      case Emotion.egitim:
        return 'eğitim';
      case Emotion.saglik:
        return 'sağlık';
      case Emotion.olum:
        return 'ölüm';
      case Emotion.fitne:
        return 'fitne';
      case Emotion.cihad:
        return 'cihad';
      case Emotion.kader:
        return 'kader';
      case Emotion.ihlas:
        return 'ihlas';
    }
  }

  static Emotion? fromString(String value) {
    for (final emotion in Emotion.values) {
      if (emotion.value == value || emotion.name == value) {
        return emotion;
      }
    }
    return null;
  }
}
