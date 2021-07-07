import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/anasayfa.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/girissayfasi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Yetkilendirmeservisi yetkilendirmeservisi =
        Provider.of<Yetkilendirmeservisi>(context, listen: false);
    return StreamBuilder<Kullanici>(
      stream: yetkilendirmeservisi.durumtakibi,
      builder: (context, snapshot) {
        //baglantı durumunu takip eden if
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // veri varmı yok mu takip edene if
        if (snapshot.hasData) {
          Kullanici aktifkullanici = snapshot.data;
          yetkilendirmeservisi.aktifolankullaniciid = aktifkullanici.id;
          // stream daki yayında veri varsa kullanici giris yapmıstır o zaman anasayfaya yonlendir
          return Anasayfa();
        } else {
          // yayın dan gelen veri boş ise kullanici giris yapmamıstır giris sayfasina yonlendir
          return Girissayfasi();
        }
      },
    );
  }
}
