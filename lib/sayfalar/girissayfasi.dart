import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/hesapolusturma.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Girissayfasi extends StatefulWidget {
  @override
  _GirissayfasiState createState() => _GirissayfasiState();
}

class _GirissayfasiState extends State<Girissayfasi> {
  final formananahtari = GlobalKey<FormState>();
  final scaffoldanahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email, sifre;
  // girisyapa bastıgımda yukleniyor animasyonu gelmesi için olsturdum false icken bos center döner true iken circularprogres döner
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldanahtari,
      body: Stack(
        children: [
          _sayfaelemanlari(),
          yuklemeanimasyonu(),
        ],
      ),
    );
  }

  Widget _sayfaelemanlari() {
    return Form(
      key: formananahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
        children: [
          FlutterLogo(
            size: 90.0,
          ),
          SizedBox(
            height: 90.0,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "email adresinizi girin",
              prefixIcon: Icon(Icons.mail_outline_outlined),
            ),
            validator: (girdigiemail) {
              if (girdigiemail.isEmpty) {
                return "email alanı boş olamaz";
              } else if (!girdigiemail.contains("@")) {
                return "girilen değer email formatında olmalıdır";
              }
              return null;
            },
            onSaved: (girilenemail) {
              email = girilenemail;
            },
          ),
          SizedBox(
            height: 30.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "şifrenizi girin",
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (girilensifre) {
              if (girilensifre.isEmpty) {
                return "şifre alanı boş bırakılamaz";
              } else if (girilensifre.trim().length <= 3) {
                return "sifre  4 haneden az olamaz";
              }
              return null;
            },
            onSaved: (girdigisifre) {
              sifre = girdigisifre;
            },
          ),
          SizedBox(height: 30.0),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Hesapolusturma(),
                      ));
                    },
                    child: Text(
                      "hesap oluştur",
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0),
                    )),
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: girisyap,
                    child: Text(
                      "giriş yap",
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0),
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: Text(
            "veya",
            style: TextStyle(fontSize: 16.0),
          )),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: InkWell(
            onTap: () => googleilegiris(),
            child: Text(
              "google ile giriş yap",
              style: TextStyle(fontSize: 22.0),
            ),
          )),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: Text(
            "şifremi unuttum",
            style: TextStyle(fontSize: 18.0),
          )),
        ],
      ),
    );
  }

  Widget yuklemeanimasyonu() {
    return yukleniyor
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center();
  }

  void girisyap() async {
    Yetkilendirmeservisi yetkilendirmeservisi =
        Provider.of(context, listen: false);
    if (formananahtari.currentState.validate()) {
      formananahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await yetkilendirmeservisi.maililegiris(email, sifre);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        hatagoster(hata.code);
      }
    }
  }

  void googleilegiris() async {
    Yetkilendirmeservisi yetkilendirmeservisi =
        Provider.of<Yetkilendirmeservisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await yetkilendirmeservisi.googleilegirisyap();
      if (kullanici != null) {
        Kullanici firesotrdavarolankulllanicikontorl =
            await Firestoreservisi().kullanicigetir(kullanici.id);

        if (firesotrdavarolankulllanicikontorl == null) {
          Firestoreservisi().kullaniciolustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciadi: kullanici.kullaniciAdi,
              fotourl: kullanici.fotoUrl);
          print("kulalnici olusturuldu");
        }
      }
    } catch (hata) {
      setState(() {
        print(hata.code);
        yukleniyor = false;
        hatagoster(hata.code);
      });
    }
  }

  void hatagoster(String hatakodu) {
    String hatamesaji;
    if (hatakodu == "ERROR_USER_NOT_FOUND") {
      hatamesaji = "böyle bir kullanıcı yoktur";
    } else if (hatakodu == "ERROR_INVALID_EMAIL") {
      hatamesaji = "girdiğiniz email geçersizdir";
    } else if (hatakodu == "ERROR_USER_DISABLED") {
      hatamesaji = "bu kullanici engellenmiştir";
    } else if (hatakodu == "ERROR_WRONG_PASSWORD") {
      hatamesaji = "girilen şifre yanlış";
    } else {
      hatamesaji = "bir hata oluştu ${hatakodu}";
    }
    scaffoldanahtari.currentState
        .showSnackBar(SnackBar(content: Text(hatamesaji)));
  }
}
