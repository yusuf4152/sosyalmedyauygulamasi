import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/gonderi.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/modeller/yorummodeli.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorum extends StatefulWidget {
  final Gonderi gonderi;

  const Yorum({Key key, this.gonderi}) : super(key: key);

  @override
  _YorumState createState() => _YorumState();
}

class _YorumState extends State<Yorum> {
  TextEditingController yorumcontrol = TextEditingController();
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("yorum"),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          yorumlaryeri(),
          yorumeklemeyeri(),
        ],
      ),
    );
  }

  Widget yorumlaryeri() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestoreservisi().yorumgetir(widget.gonderi.id),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  Yorummodeli yorummodeli = Yorummodeli.dokumandanUret(
                      snapshot.data.documents[index]);
                  return yorumsatiri(yorummodeli);
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget yorumsatiri(Yorummodeli yorummodeli) {
    return FutureBuilder<Kullanici>(
      future: Firestoreservisi().kullanicigetir(yorummodeli.yayinlayanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 0.0,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 0.0,
          );
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: snapshot.data.fotoUrl != null
                ? NetworkImage(snapshot.data.fotoUrl)
                : AssetImage("assets/images/kedi.jpg"),
            backgroundColor: Colors.grey,
          ),
          title: RichText(
              text: TextSpan(
                  text: snapshot.data.kullaniciAdi + " ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                TextSpan(
                  text: yorummodeli.icerik,
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
              ])),
          subtitle: Text(timeago.format(yorummodeli.olusturulmaZamani.toDate(),
              locale: 'tr')),
        );
      },
    );
  }

  Widget yorumeklemeyeri() {
    return ListTile(
      title: TextFormField(
        controller: yorumcontrol,
        decoration: InputDecoration(
          hintText: "yorumunu buraya gir",
          suffixIcon: IconButton(
              icon: Icon(Icons.send_outlined),
              onPressed: () {
                String _aktifid =
                    Provider.of<Yetkilendirmeservisi>(context, listen: false)
                        .aktifolankullaniciid;
                Firestoreservisi()
                    .yorumekle(widget.gonderi, yorumcontrol.text, _aktifid);
                yorumcontrol.clear();
              }),
        ),
      ),
    );
  }
}
