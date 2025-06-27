import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('tr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Face Recognition',
      'subtitle':
          'OGULCAN-AI offers SDKs for face recognition, liveness detection, and id document recognition.',
      'enroll': 'Enroll',
      'identify': 'Identify',
      'settings': 'Settings',
      'about': 'About',
      'capture': 'Capture',
      'logs': 'Logs',
      'noLogs': 'No logs yet',
      'invalidLicense': 'Invalid license!',
      'licenseExpired': 'License expired!',
      'noActivated': 'No activated!',
      'initError': 'Init error!',
      'allPersonDeleted': 'All person deleted!',
      'personRemoved': 'Person removed!',
      'noFaceDetected': 'No face detected!',
      'personEnrolled': 'Person enrolled!',
      'personRenamed': 'Person renamed!',
      'cameraLens': 'Camera Lens',
      'thresholds': 'Thresholds',
      'livenessLevel': 'Liveness Level',
      'livenessThreshold': 'Liveness Threshold',
      'identifyThreshold': 'Identify Threshold',
      'cancel': 'Cancel',
      'ok': 'OK',
      'restoreDefaults': 'Restore default settings',
      'clearAllPerson': 'Clear all person',
      'reset': 'Reset',
      'back': 'Back',
      'front': 'Front',
      'best': 'Best Accuracy',
      'light': 'Light Weight',
      'language': 'Language',
      'english': 'English',
      'turkish': 'Türkçe',
      'multipleFace': 'Multiple face detected!',
      'fitCircle': 'Fit in circle!',
      'moveCloser': 'Move closer!',
      'notFronted': 'Not fronted face!',
      'faceOccluded': 'Face occluded!',
      'eyeClosed': 'Eye closed!',
      'mouthOpened': 'Mouth opened!',
      'spoofFace': 'Spoof face',
      'livenessReal': 'Liveness: Real, score = ',
      'livenessSpoof': 'Liveness: Spoof, score = ',
      'qualityLow': 'Quality: Low, score = ',
      'qualityMedium': 'Quality: Medium, score = ',
      'qualityHigh': 'Quality: High, score = ',
      'luminance': 'Luminance: ',
      'enrolled': 'Enrolled',
      'identified': 'Identified',
      'identifiedName': 'Identified: ',
      'similarity': 'Similarity: ',
      'livenessScore': 'Liveness score: ',
      'yaw': 'Yaw: ',
      'roll': 'Roll: ',
      'pitch': 'Pitch: ',
      'age': 'Age: ',
      'gender': 'Gender: ',
      'male': 'Male',
      'female': 'Female',
      'enterName': 'Enter name',
      'tryAgain': 'Try again',
      'logDetails': 'Log Details',
      'name': 'Name: ',
      'time': 'Time: ',
      'aboutTitle': 'OGULCAN-AI Technology',
      'aboutContent':
          'The Face Recognition System application provides secure and contactless access to buildings using advanced AI and biometric technologies. While it allows only authorized persons to enter, it also simplifies visitor management.\n\nThis project was created by software developer Ogulcan Topal with the dream of making technology a part of daily life. Developed with data privacy and security in mind, it is constantly updated to provide the best user experience.\n\nAbout the developer:\nOgulcan Topal is a developer passionate about artificial intelligence, mobile software, and automation systems. This application reflects his vision of modernizing security with practical solutions.'
    },
    'tr': {
      'appTitle': 'Yüz Tanıma',
      'subtitle':
          'OGULCAN-AI yüz tanıma, canlılık tespiti ve kimlik belgesi tanıma için SDK\'lar sunar.',
      'enroll': 'Kaydet',
      'identify': 'Tanı',
      'settings': 'Ayarlar',
      'about': 'Hakkında',
      'capture': 'Yakala',
      'logs': 'Kayıtlar',
      'noLogs': 'Kayıt yok',
      'invalidLicense': 'Geçersiz lisans!',
      'licenseExpired': 'Lisansın süresi doldu!',
      'noActivated': 'Aktive edilmemiş!',
      'initError': 'Başlatma hatası!',
      'allPersonDeleted': 'Tüm kişiler silindi!',
      'personRemoved': 'Kişi silindi!',
      'noFaceDetected': 'Yüz algılanamadı!',
      'personEnrolled': 'Kişi eklendi!',
      'personRenamed': 'Kişi adı değiştirildi!',
      'cameraLens': 'Kamera Lensi',
      'thresholds': 'Eşikler',
      'livenessLevel': 'Canlılık Seviyesi',
      'livenessThreshold': 'Canlılık Eşiği',
      'identifyThreshold': 'Tanıma Eşiği',
      'cancel': 'İptal',
      'ok': 'Tamam',
      'restoreDefaults': 'Varsayılan ayarları geri yükle',
      'clearAllPerson': 'Tüm kişileri temizle',
      'reset': 'Sıfırla',
      'back': 'Arka',
      'front': 'Ön',
      'best': 'En İyi Doğruluk',
      'light': 'Hafif',
      'language': 'Dil',
      'english': 'İngilizce',
      'turkish': 'Türkçe',
      'multipleFace': 'Birden fazla yüz algılandı!',
      'fitCircle': 'Daireye sığdırın!',
      'moveCloser': 'Daha yakın durun!',
      'notFronted': 'Yüz öne dönük değil!',
      'faceOccluded': 'Yüz engellendi!',
      'eyeClosed': 'Göz kapalı!',
      'mouthOpened': 'Ağız açık!',
      'spoofFace': 'Sahte yüz',
      'livenessReal': 'Canlılık: Gerçek, skor = ',
      'livenessSpoof': 'Canlılık: Sahte, skor = ',
      'qualityLow': 'Kalite: Düşük, skor = ',
      'qualityMedium': 'Kalite: Orta, skor = ',
      'qualityHigh': 'Kalite: Yüksek, skor = ',
      'luminance': 'Parlaklık: ',
      'enrolled': 'Kayıtlı',
      'identified': 'Tanımlandı',
      'identifiedName': 'Tanımlandı: ',
      'similarity': 'Benzerlik: ',
      'livenessScore': 'Canlılık skoru: ',
      'yaw': 'Yalpalama: ',
      'roll': 'Dönme: ',
      'pitch': 'Eğim: ',
      'age': 'Yaş: ',
      'gender': 'Cinsiyet: ',
      'male': 'Erkek',
      'female': 'Kadın',
      'enterName': 'İsim girin',
      'tryAgain': 'Tekrar dene',
      'logDetails': 'Kayıt Detayları',
      'name': 'İsim: ',
      'time': 'Zaman: ',
      'aboutTitle': 'OGULCAN-AI Teknoloji',
      'aboutContent':
          'Yüz Tanıma Sistemi uygulaması, gelişmiş yapay zeka ve biyometrik teknolojilerle desteklenen, binalara güvenli ve temassız erişim sağlamak üzere geliştirilmiştir. Bu uygulama, yalnızca yetkili kişilerin giriş yapmasına olanak tanırken, aynı zamanda ziyaretçi yönetimini de kolaylaştırır.\n\nBu proje, teknolojiyi günlük hayatın bir parçası haline getirme hayaliyle, yazılım geliştiricisi Oğulcan Topal tarafından tasarlanmış ve hayata geçirilmiştir. Uygulama, veri gizliliği ve güvenliği esas alınarak geliştirilmiş olup, kullanıcı deneyimini en üst seviyede tutmak için sürekli olarak güncellenmektedir.\n\nGeliştirici Hakkında:\nOğulcan Topal, yapay zeka, mobil yazılım ve otomasyon sistemlerine tutkuyla bağlı bir geliştiricidir. Bu uygulama, onun pratik çözümlerle güvenliği modernleştirme vizyonunun bir yansımasıdır.'
    }
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? '';
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
