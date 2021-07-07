import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String id;
  final String gonderiResmiUrl;
  final String aciklama;
  final String yayinlayanId;
  final int begeniSayisi;
  final String konum;

  Gonderi(
      {this.id,
      this.gonderiResmiUrl,
      this.aciklama,
      this.yayinlayanId,
      this.begeniSayisi,
      this.konum});

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    return Gonderi(
      id: doc.documentID,
      gonderiResmiUrl: doc['gonderiresmiurl'],
      aciklama: doc['aciklama'],
      yayinlayanId: doc['yayinlayanid'],
      begeniSayisi: doc['begenisayisi'],
      konum: doc['konum'],
    );
  }
}
