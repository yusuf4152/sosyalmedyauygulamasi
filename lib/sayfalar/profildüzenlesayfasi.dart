import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/servisler/Storageservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Profilduzen extends StatefulWidget {
  final Kullanici kullanici;

  const Profilduzen({Key key, this.kullanici}) : super(key: key);

  @override
  _ProfilduzenState createState() => _ProfilduzenState();
}

class _ProfilduzenState extends State<Profilduzen> {
  String yeniusername, yenihakkinda;
  final formamahtari = GlobalKey<FormState>();
  File secielnfoto;
  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("profil düzenle"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_rounded,
              color: Colors.white,
            ),
            onPressed: () => kaydet(),
          )
        ],
      ),
      body: ListView(
        children: [
          yuklemeanimasyonu(),
          _profilsayfasi(),
          _kullanicibiligleri(),
        ],
      ),
    );
  }

  Widget _profilsayfasi() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 12.0),
      child: Center(
        child: InkWell(
          onTap: () => _galeridensec(),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: secielnfoto == null
                ? NetworkImage(widget.kullanici.fotoUrl)
                : FileImage(secielnfoto),
            radius: 50.0,
          ),
        ),
      ),
    );
  }

  _galeridensec() async {
    PickedFile cekilenfoto = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      secielnfoto = File(cekilenfoto.path);
    });
  }

  Widget _kullanicibiligleri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: formamahtari,
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            TextFormField(
              initialValue: widget.kullanici.kullaniciAdi,
              decoration: InputDecoration(
                labelText: "kullaniciadi",
              ),
              validator: (yenigirilenkullaniciadi) {
                if (yenigirilenkullaniciadi.length <= 4 ||
                    yenigirilenkullaniciadi.length > 10) {
                  return "kullanici adi 4 karakterden az veya 10 karakterden fazla olamaz";
                }
                return null;
              },
              onSaved: (girilenkullanciadi) {
                yeniusername = girilenkullanciadi;
              },
            ),
            SizedBox(
              height: 5.0,
            ),
            TextFormField(
              initialValue: widget.kullanici.hakkinda,
              decoration: InputDecoration(
                labelText: "hakkinda",
              ),
              validator: (yenigirilenhakkinda) {
                if (yenigirilenhakkinda.length > 50) {
                  return "hakkinda kısmı 50 karakterden fazla olamaz";
                }
                return null;
              },
              onSaved: (girilenhakkinda) {
                yenihakkinda = girilenhakkinda;
              },
            ),
          ],
        ),
      ),
    );
  }

  yuklemeanimasyonu() {
    return yukleniyor == true
        ? LinearProgressIndicator()
        : SizedBox(
            height: 0.0,
          );
  }

  kaydet() async {
    if (formamahtari.currentState.validate()) {
      formamahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      String fotourl;
      String _aktifkullanicid =
          Provider.of<Yetkilendirmeservisi>(context, listen: false)
              .aktifolankullaniciid;
      if (secielnfoto == null) {
        fotourl = widget.kullanici.fotoUrl;
      } else {
        fotourl = await Storageservisi().profilresimyukle(secielnfoto);
      }
      Firestoreservisi().kullaniciguncelle(
          fotourl: fotourl,
          kullanicid: _aktifkullanicid,
          hakkinda: yenihakkinda,
          kullaniciadi: yeniusername);
      setState(() {
        yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }
}
