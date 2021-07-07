import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Hesapolusturma extends StatefulWidget {
  @override
  _HesapolusturmaState createState() => _HesapolusturmaState();
}

class _HesapolusturmaState extends State<Hesapolusturma> {
  bool yukleniyor = false;
  String email, sifre, kullaniciadi;
  final formanahtari = GlobalKey<FormState>();
  final scaffoldanahtari = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldanahtari,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text("hesap olusturma"),
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
            child: Form(
                key: formanahtari,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "kullanici adiniz girin",
                        labelText: "Kullanici adı",
                        prefixIcon: Icon(Icons.person_outline_outlined),
                      ),
                      validator: (girdigiusername) {
                        if (girdigiusername.isEmpty) {
                          return "kullanıcı adı alanı boş olamaz";
                        } else if (girdigiusername.length < 4 ||
                            girdigiusername.length > 10) {
                          return "kullanici adi 4 karakterden az veya 10 dan fazla olamaz";
                        }
                        return null;
                      },
                      onSaved: (girilenkullaniciadi) {
                        kullaniciadi = girilenkullaniciadi;
                      },
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "email adresinizi girin",
                        labelText: "email",
                        prefixIcon: Icon(Icons.mail_outline_outlined),
                      ),
                      validator: (girdigiemail) {
                        if (girdigiemail.isEmpty) {
                          return "emial alanı boş olamaz";
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
                        labelText: "şifre",
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
                  ],
                )),
          ),
          SizedBox(
            height: 40.0,
          ),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: FlatButton(
                  color: Colors.blue,
                  onPressed: kullaniciolustur,
                  child: Text(
                    "hesap oluştur",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
            ),
          )
        ],
      ),
    );
  }

  void kullaniciolustur() async {
    final Yetkilendirmeservisi yetkilendirmeservisi =
        Provider.of<Yetkilendirmeservisi>(context, listen: false);
    if (formanahtari.currentState.validate()) {
      formanahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await yetkilendirmeservisi.maililekayit(email, sifre);
        if (kullanici != null) {
          Firestoreservisi().kullaniciolustur(
              id: kullanici.id, email: email, kullaniciadi: kullaniciadi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        hatagoster(hata.code);
      }
    }
  }

  void hatagoster(String hatakodu) {
    String hatamesaji;
    if (hatakodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hatamesaji = "girdiğiniz mail kullanılmıştır";
    } else if (hatakodu == "ERROR_INVALID_EMAIL") {
      hatamesaji = "girdiğiniz email geçersizdir";
    } else if (hatakodu == "ERROR_WEAK_PASSWORD") {
      hatamesaji = "girdiğiniz şifre güçsüzdür";
    }
    scaffoldanahtari.currentState
        .showSnackBar(SnackBar(content: Text(hatamesaji)));
  }
}
