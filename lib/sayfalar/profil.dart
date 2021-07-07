import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/gonderi.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/profild%C3%BCzenlesayfasi.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

import 'package:sosyalmedyauygulamasi/widgetlar/gonderiwidget.dart';

class Profilsayfasi extends StatefulWidget {
  final String profilsahibicid;
  const Profilsayfasi({Key key, this.profilsahibicid}) : super(key: key);

  @override
  _ProfilsayfasiState createState() => _ProfilsayfasiState();
}

class _ProfilsayfasiState extends State<Profilsayfasi> {
  int takipci = 0, takipedilenler = 0, gonderisayisi = 0;
  List<Gonderi> _gonderiler = [];
  String aktifkullaniciid;
  String liste = "liste";
  Kullanici _kullanici;
  bool takipetmismi = false;
  takipcisayisigetir() async {
    int takipcisayisi =
        await Firestoreservisi().takipcisayisigetir(widget.profilsahibicid);
    if (mounted) {
      setState(() {
        takipci = takipcisayisi;
      });
    }
  }

  takipedilensayisigetir() async {
    int takipedilenlersayisi =
        await Firestoreservisi().takipedilensayisigetir(widget.profilsahibicid);
    if (mounted) {
      setState(() {
        takipedilenler = takipedilenlersayisi;
      });
    }
  }

  gonderigetir() async {
    List<Gonderi> gonderilerlistesi =
        await Firestoreservisi().gonderilerigetir(widget.profilsahibicid);
    if (mounted) {
      setState(() {
        _gonderiler = gonderilerlistesi;
        gonderisayisi = _gonderiler.length;
      });
    }
  }

  takipetmismikontrol() async {
    bool takipvarmi = await Firestoreservisi().takipkontrol(
        aktifkullaniciid: aktifkullaniciid,
        profilsahibiid: widget.profilsahibicid);
    setState(() {
      takipetmismi = takipvarmi;
    });
  }

  @override
  void initState() {
    super.initState();
    takipedilensayisigetir();
    takipcisayisigetir();
    gonderigetir();
    aktifkullaniciid = Provider.of<Yetkilendirmeservisi>(context, listen: false)
        .aktifolankullaniciid;
    takipetmismikontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("profil"),
        actions: [
          widget.profilsahibicid == aktifkullaniciid
              ? IconButton(
                  icon: Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.black,
                  ),
                  onPressed: _cikisyap,
                )
              : SizedBox(
                  height: 0.0,
                ),
        ],
      ),
      body: FutureBuilder<Kullanici>(
          future: Firestoreservisi().kullanicigetir(widget.profilsahibicid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            _kullanici = snapshot.data;

            print(snapshot.data.id);
            return ListView(
              children: [
                profildetaylari(snapshot.data),
                gonderilerigoster(snapshot.data),
              ],
            );
          }),
    );
  }

  Widget gonderilerigoster(Kullanici yayinlayan) {
    if (liste == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          return GOnderiwidget(
            gonderi: _gonderiler[index],
            yayinayalankisi: yayinlayan,
          );
        },
      );
    } else {
      List<Widget> _fayanslar = [];
      _gonderiler.forEach((gon) {
        _fayanslar.add(fayansolustur(gon));
      });
      return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        //bütün alanı doldurmaması için kullandım
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
        children: _fayanslar,
      );
    }
  }

  fayansolustur(Gonderi gonderiresmi) {
    return GridTile(
        child: Image.network(gonderiresmi.gonderiResmiUrl, fit: BoxFit.cover));
  }

  Widget profildetaylari(Kullanici kullanici) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 50.0,
                backgroundImage: kullanici.fotoUrl.isNotEmpty
                    ? NetworkImage(kullanici.fotoUrl)
                    : AssetImage("assets/images/kedi.jpg"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    sosyalsayaclar(gonderisayisi, "gönderiler"),
                    sosyalsayaclar(takipci, "takipçi"),
                    sosyalsayaclar(takipedilenler, "takip"),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            kullanici.kullaniciAdi,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(kullanici.hakkinda),
          SizedBox(
            height: 15.0,
          ),
          widget.profilsahibicid == aktifkullaniciid
              ? profiliduzenlebuton()
              : !takipetmismi
                  ? takipetbutonu()
                  : takiptencikbutonu(),
        ],
      ),
    );
  }

  Widget takipetbutonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.blue,
        child: Text(
          "takip et",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Firestoreservisi().takipet(
              aktifkullaniciid: aktifkullaniciid,
              profilsahibiid: widget.profilsahibicid);
          setState(() {
            takipetmismi = true;
            takipci = takipci + 1;
          });
        },
      ),
    );
  }

  Widget takiptencikbutonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.grey[200],
        child: Text("takiptencik"),
        onPressed: () {
          Firestoreservisi().takiptencik(
              aktifkullaniciid: aktifkullaniciid,
              profilsahibiid: widget.profilsahibicid);
          setState(() {
            takipetmismi = false;
            takipci = takipci - 1;
          });
        },
      ),
    );
  }

  Widget profiliduzenlebuton() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        child: Text("profili düzenle"),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profilduzen(
                        kullanici: _kullanici,
                      )));
        },
      ),
    );
  }

  Widget sosyalsayaclar(int sayi, String yazi) {
    return Column(
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          yazi,
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void _cikisyap() {
    Yetkilendirmeservisi yetkilendirmeservisi =
        Provider.of<Yetkilendirmeservisi>(context, listen: false);
    yetkilendirmeservisi.cikisyap();
  }
}
