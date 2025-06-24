import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KBY-AI Technology'),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Yüz Tanıma Sistemi uygulaması, gelişmiş yapay zeka ve biyometrik teknolojilerle desteklenen, binalara güvenli ve temassız erişim sağlamak üzere geliştirilmiştir. Bu uygulama, yalnızca yetkili kişilerin giriş yapmasına olanak tanırken, aynı zamanda ziyaretçi yönetimini de kolaylaştırır.\n\n'
          'Bu proje, teknolojiyi günlük hayatın bir parçası haline getirme hayaliyle, yazılım geliştiricisi Oğulcan Topal tarafından tasarlanmış ve hayata geçirilmiştir. Uygulama, veri gizliliği ve güvenliği esas alınarak geliştirilmiş olup, kullanıcı deneyimini en üst seviyede tutmak için sürekli olarak güncellenmektedir.\n\n'
          'Geliştirici Hakkında:\n'
          'Oğulcan Topal, yapay zeka, mobil yazılım ve otomasyon sistemlerine tutkuyla bağlı bir geliştiricidir. Bu uygulama, onun pratik çözümlerle güvenliği modernleştirme vizyonunun bir yansımasıdır.',
        ),
      ),
    );
  }
}
