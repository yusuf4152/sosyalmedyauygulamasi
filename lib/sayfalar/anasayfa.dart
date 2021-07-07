import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/akis.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/arama.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/duyurular.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/profil.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/yukle.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int suankisayi = 0;
  PageController sayfagecisi;

  @override
  void initState() {
    super.initState();
    sayfagecisi = PageController();
  }

  @override
  void dispose() {
    sayfagecisi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifkullaniciid =
        Provider.of<Yetkilendirmeservisi>(context, listen: false)
            .aktifolankullaniciid;
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: sayfagecisi,
        onPageChanged: (sayfadegeri) {
          setState(() {
            suankisayi = sayfadegeri;
          });
        },
        children: [
          Akissayfasi(),
          Aramasayfasi(),
          Yuklemesayfasi(),
          Duyurusayfasi(),
          Profilsayfasi(
            profilsahibicid: aktifkullaniciid,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).accentColor,
        unselectedItemColor: Colors.grey[400],
        currentIndex: suankisayi,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("akış")),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text(
                "keşfet",
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_sharp),
              title: Text(
                "yükle",
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), title: Text("duyurular")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_outlined), title: Text("profil")),
        ],
        onTap: (tiklanasayi) {
          setState(() {
            sayfagecisi.jumpToPage(tiklanasayi);
          });
        },
      ),
    );
  }
}
