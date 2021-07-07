import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/servisler/Storageservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class Yuklemesayfasi extends StatefulWidget {
  @override
  _YuklemesayfasiState createState() => _YuklemesayfasiState();
}

class _YuklemesayfasiState extends State<Yuklemesayfasi> {
  File dosya;
  //kullanicin sectiği fotoyu tutan değişken
  bool yukleniyor = false;
  TextEditingController aciklamakumandasi = TextEditingController();
  TextEditingController konumkumandasi = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return dosya == null ? yuklebutonu() : gonderiyeri();
  }

  Widget yuklebutonu() {
    return Center(
      child: IconButton(
        icon: Icon(
          Icons.upload_rounded,
          size: 60.0,
        ),
        onPressed: () => fotoyerisecimi(),
      ),
    );
  }

  fotoyerisecimi() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi oluştur"),
          children: [
            SimpleDialogOption(
              child: Text("foto çek"),
              onPressed: () => fotocek(),
            ),
            SimpleDialogOption(
              child: Text("galeriden seç"),
              onPressed: () => galeridensec(),
            ),
            SimpleDialogOption(
              child: Text("iptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget gonderiyeri() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gönderi oluştur"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.send_outlined,
              color: Colors.white,
            ),
            onPressed: _gonderiolustur,
          ),
        ],
      ),
      body: ListView(
        children: [
          yukleniyor ? LinearProgressIndicator() : Center(),
          AspectRatio(aspectRatio: 16 / 9, child: Image.file(dosya)),
          SizedBox(
            height: 10.0,
          ),
          TextFormField(
            controller: aciklamakumandasi,
            decoration: InputDecoration(
              hintText: "Açıklama ekle",
              contentPadding: EdgeInsets.only(left: 8.0),
            ),
          ),
          TextFormField(
            controller: konumkumandasi,
            decoration: InputDecoration(
              hintText: "konum ekle",
              contentPadding: EdgeInsets.only(left: 8.0),
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiolustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimurl = await Storageservisi().gonderiresimyukle(dosya);
      String yayinlayakisi =
          Provider.of<Yetkilendirmeservisi>(context, listen: false)
              .aktifolankullaniciid;
      await Firestoreservisi().gonderiolustur(
          aciklama: aciklamakumandasi.text,
          gonderiresimurl: resimurl,
          yayinlayanid: yayinlayakisi,
          konum: konumkumandasi.text);
      setState(() {
        yukleniyor = false;
        dosya = null;
        aciklamakumandasi.clear();
        konumkumandasi.clear();
      });
    }
  }

  fotocek() async {
    Navigator.pop(context);
    PickedFile cekilenfoto = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      if (cekilenfoto != null) {
        dosya = File(cekilenfoto.path);
      }
    });
  }

  galeridensec() async {
    Navigator.pop(context);
    PickedFile cekilenfoto = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      if (cekilenfoto != null) {
        dosya = File(cekilenfoto.path);
      }
    });
  }
}
