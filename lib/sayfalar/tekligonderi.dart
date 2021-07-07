import 'package:flutter/material.dart';
import 'package:sosyalmedyauygulamasi/modeller/gonderi.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/widgetlar/gonderiwidget.dart';

class Tekligonderi extends StatefulWidget {
  final String gonderiid;
  final String gonderisahibi;

  const Tekligonderi({Key key, this.gonderiid, this.gonderisahibi})
      : super(key: key);

  @override
  _TekligonderiState createState() => _TekligonderiState();
}

class _TekligonderiState extends State<Tekligonderi> {
  Gonderi _gonderi;
  Kullanici _kullanici;
  bool yukleniyor = true;

  duyurugetir() async {
    Gonderi gonderi = await Firestoreservisi()
        .tekligonderigetir(widget.gonderisahibi, widget.gonderiid);
    if (gonderi != null) {
      Kullanici gelenkullanici =
          await Firestoreservisi().kullanicigetir(gonderi.yayinlayanId);
      setState(() {
        _gonderi = gonderi;
        _kullanici = gelenkullanici;
        yukleniyor = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    duyurugetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("duyurular"),
      ),
      body: yukleniyor
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                GOnderiwidget(
                  gonderi: _gonderi,
                  yayinayalankisi: _kullanici,
                ),
              ],
            ),
    );
  }
}
