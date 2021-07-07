import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/duyuru.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/profil.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/tekligonderi.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurusayfasi extends StatefulWidget {
  @override
  _DuyurusayfasiState createState() => _DuyurusayfasiState();
}

class _DuyurusayfasiState extends State<Duyurusayfasi> {
  List<Duyuru> _duyurular = [];
  String aktifkullaniciid;
  bool yukleniyor = true;

  duyurularigetir() async {
    List<Duyuru> duyurular =
        await Firestoreservisi().duyurularigetir(aktifkullaniciid);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        yukleniyor = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    aktifkullaniciid = Provider.of<Yetkilendirmeservisi>(context, listen: false)
        .aktifolankullaniciid;
    duyurularigetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("duyurular"),
      ),
      body: duyurularigoster(),
    );
  }

  Widget duyurularigoster() {
    if (yukleniyor) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_duyurular.isEmpty) {
      Center(
        child: Text("henüz bir duyurunuz yok"),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: RefreshIndicator(
        onRefresh: () => duyurularigetir(),
        child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyurusatiri(duyuru);
          },
        ),
      ),
    );
  }

  duyurusatiri(Duyuru duyuru) {
    String mesaj = mesajgoster(duyuru.aktiviteTipi);
    return FutureBuilder<Kullanici>(
      future: Firestoreservisi().kullanicigetir(duyuru.aktiviteYapanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              height: 0.0,
            ),
          );
        }
        Kullanici kullanici = snapshot.data;
        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profilsayfasi(
                      profilsahibicid: duyuru.aktiviteYapanId,
                    ),
                  ));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(kullanici.fotoUrl),
              backgroundColor: Colors.grey,
            ),
          ),
          title: RichText(
            text: TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  //burda 2 tane nokta kullanmamın amacı . noktayla ulastıgım zaman gesturerecognizer a degil ontap metoduna ulasmıs olurum .. koyarak objeyi kullanmıs olurum
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profilsayfasi(
                          profilsahibicid: duyuru.aktiviteYapanId,
                        ),
                      ));
                },
              text: "${kullanici.kullaniciAdi} ",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: duyuru.yorum == null
                        ? "$mesaj"
                        : "$mesaj  ${duyuru.yorum}",
                    style: TextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ),
          subtitle: Text(
              timeago.format(duyuru.olusturulmaZamani.toDate(), locale: 'tr')),
          trailing: gonderigorselgosterme(
              duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
        );
      },
    );
  }

  gonderigorselgosterme(
      String aktivitetipi, String gonderifoto, String gonderiid) {
    if (aktivitetipi == "takip") {
      return null;
    } else if (aktivitetipi == "begeni" || aktivitetipi == "yorum") {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Tekligonderi(
                  gonderisahibi: aktifkullaniciid,
                  gonderiid: gonderiid,
                ),
              ));
        },
        child: Image.network(
          gonderifoto,
          fit: BoxFit.cover,
          width: 50.0,
          height: 50.0,
        ),
      );
    }
  }

  String mesajgoster(String aktivitetipi) {
    if (aktivitetipi == "begeni") {
      return "gönderini beğendi";
    } else if (aktivitetipi == "yorum") {
      return "gönderine yorum yaptı";
    } else if (aktivitetipi == "takip") {
      return "seni takip etti";
    } else {
      return null;
    }
  }
}
