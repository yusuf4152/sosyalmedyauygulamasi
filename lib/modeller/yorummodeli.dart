import 'package:cloud_firestore/cloud_firestore.dart';

class Yorummodeli {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorummodeli(
      {this.id, this.icerik, this.yayinlayanId, this.olusturulmaZamani});

  factory Yorummodeli.dokumandanUret(DocumentSnapshot doc) {
    return Yorummodeli(
      id: doc.documentID,
      icerik: doc.data["icerik"],
      yayinlayanId: doc.data["yayinlayanid"],
      olusturulmaZamani: doc.data["olusturulmazamani"],
    );
  }
}
