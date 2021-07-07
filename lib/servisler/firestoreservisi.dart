import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosyalmedyauygulamasi/modeller/duyuru.dart';
import 'package:sosyalmedyauygulamasi/modeller/gonderi.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/modeller/yorummodeli.dart';
import 'package:sosyalmedyauygulamasi/servisler/Storageservisi.dart';

class Firestoreservisi {
  final _firestore = Firestore.instance;
  final DateTime _dateTime = DateTime.now();
  kullaniciolustur({id, email, kullaniciadi, fotourl = "", hakkinda = ""}) {
    _firestore.collection("kullanicilar").document(id).setData({
      "id": id,
      "email": email,
      "kullaniciAdi": kullaniciadi,
      "olusturulmazamani": _dateTime,
      "fotourl": fotourl,
      "hakkinda": hakkinda,
    });
  }

  // kayıt olmuş bir kullanıcıyı bi daha döküman olarak eklememek için yazdıgım metod
  Future<Kullanici> kullanicigetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();
    if (doc.exists) {
      return Kullanici.dokumandanUret(doc);
    } else
      return null;
  }

  Future<List<Kullanici>> kullanicibul(String kullaniciadi) async {
    QuerySnapshot kullanicilar = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kullaniciadi)
        .getDocuments();
    List<Kullanici> kullanicilistesi = kullanicilar.documents
        .map((doc) => Kullanici.dokumandanUret(doc))
        .toList();
    return kullanicilistesi;
  }

  kullaniciguncelle(
      {String kullanicid,
      String fotourl,
      String hakkinda,
      String kullaniciadi}) {
    _firestore.collection("kullanicilar").document(kullanicid).updateData({
      "fotourl": fotourl,
      "hakkinda": hakkinda,
      "kullaniciAdi": kullaniciadi,
    });
  }

  takipet({String aktifkullaniciid, String profilsahibiid}) {
    _firestore
        .collection("takipciler")
        .document(profilsahibiid)
        .collection("takipedenhesaplar")
        .document(aktifkullaniciid)
        .setData({});
    _firestore
        .collection("takipedilenler")
        .document(aktifkullaniciid)
        .collection("takipettikleri")
        .document(profilsahibiid)
        .setData({});

    duyuruekle(
      aktiviteTipi: "takip",
      aktiviteYapanId: aktifkullaniciid,
      profilSahibiId: profilsahibiid,
    );
  }

  takiptencik({String aktifkullaniciid, String profilsahibiid}) {
    _firestore
        .collection("takipciler")
        .document(profilsahibiid)
        .collection("takipedenhesaplar")
        .document(aktifkullaniciid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    _firestore
        .collection("takipedilenler")
        .document(aktifkullaniciid)
        .collection("takipettikleri")
        .document(profilsahibiid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  Future<bool> takipkontrol(
      {String aktifkullaniciid, String profilsahibiid}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipedilenler")
        .document(aktifkullaniciid)
        .collection("takipettikleri")
        .document(profilsahibiid)
        .get();
    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> takipcisayisigetir(String id) async {
    QuerySnapshot takipcilertorbasi = await _firestore
        .collection("takipciler")
        .document(id)
        .collection("takipedenhesaplar")
        .getDocuments();
    return takipcilertorbasi.documents.length;
  }

  Future<int> takipedilensayisigetir(String id) async {
    QuerySnapshot takipedilenlertorbasi = await _firestore
        .collection("takipedilenler")
        .document(id)
        .collection("takipettikleri")
        .getDocuments();

    return takipedilenlertorbasi.documents.length;
  }

  duyuruekle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      Gonderi gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }
    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullanicininduyurulari")
        .add({
      "aktiviteyapanid": aktiviteYapanId,
      "aktivitetipi": aktiviteTipi,
      "yorum": yorum,
      "gonderiid": gonderi?.id,
      "gonderifoto": gonderi?.gonderiResmiUrl,
      "olusturulmazamani": _dateTime
    });
  }

  Future<List<Duyuru>> duyurularigetir(String profilsahibiid) async {
    QuerySnapshot duyurular = await _firestore
        .collection("duyurular")
        .document(profilsahibiid)
        .collection("kullanicininduyurulari")
        .orderBy("olusturulmazamani")
        .limit(20)
        .getDocuments();
    List<Duyuru> duyurular1 = [];
    duyurular.documents.forEach((doc) {
      duyurular1.add(Duyuru.dokumandanUret(doc));
    });
    return duyurular1;
  }

  Future<void> gonderiolustur(
      {String gonderiresimurl,
      String yayinlayanid,
      String konum,
      String aciklama}) async {
    await _firestore
        .collection("gonderiler")
        .document(yayinlayanid)
        .collection("kullaniciningonderileri")
        .add({
      "gonderiresmiurl": gonderiresimurl,
      "yayinlayanid": yayinlayanid,
      "konum": konum,
      "aciklama": aciklama,
      "olusturulmazamani": _dateTime,
      "begenisayisi": 0
    });
  }

  Future<List<Gonderi>> gonderilerigetir(String kullaniciid) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .document(kullaniciid)
        .collection("kullaniciningonderileri")
        .orderBy("olusturulmazamani", descending: true)
        .getDocuments();
    return snapshot.documents
        .map((doc) => Gonderi.dokumandanUret(doc))
        .toList();
  }

  Future<Gonderi> tekligonderigetir(
      String kullanciiid, String gonderiid) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(kullanciiid)
        .collection("kullaniciningonderileri")
        .document(gonderiid)
        .get();
    Gonderi gonderiobjesi = Gonderi.dokumandanUret(doc);
    return gonderiobjesi;
  }

  gonderisil({String aktifkullaniciid, Gonderi gonderi}) async {
    //cekilen gonderiyi sil
    _firestore
        .collection("gonderiler")
        .document(aktifkullaniciid)
        .collection("kullaniciningonderileri")
        .document(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //gonderinin yorumlarını sildim
    QuerySnapshot gonderiyorumlari = await _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderininyorumlari")
        .getDocuments();
    gonderiyorumlari.documents.forEach((element) {
      if (element.exists) {
        element.reference.delete();
      }
    });
    // gonderini duyurularını sildim
    QuerySnapshot duyurular = await _firestore
        .collection("duyurular")
        .document(aktifkullaniciid)
        .collection("kullanicininduyurulari")
        .where("gonderiid", isEqualTo: gonderi.id)
        .getDocuments();
    duyurular.documents.forEach((element) {
      if (element.exists) {
        element.reference.delete();
      }
    });
    Storageservisi().resimsil(gonderi.gonderiResmiUrl);
  }

  Future<void> gonderibegen(Gonderi gonderi, String begenenkisiid) async {
    DocumentSnapshot ulasilmasigerekengonderi = await _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciningonderileri")
        .document(gonderi.id)
        .get();
    if (ulasilmasigerekengonderi.exists) {
      int mevcutbegenisayisi = ulasilmasigerekengonderi.data["begenisayisi"];
      int begenmeislemi = mevcutbegenisayisi + 1;
      _firestore
          .collection("gonderiler")
          .document(gonderi.yayinlayanId)
          .collection("kullaniciningonderileri")
          .document(gonderi.id)
          .updateData({
        "begenisayisi": begenmeislemi,
      });
      //kulanıcının begenip begenmedigini kontrol etmek icin olusturdum
      _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderibegenileri")
            ..document(begenenkisiid).setData({});

      duyuruekle(
        aktiviteTipi: "begeni",
        gonderi: gonderi,
        aktiviteYapanId: begenenkisiid,
        profilSahibiId: gonderi.yayinlayanId,
      );
    }
  }

  Future<void> gonderibegenikaldir(Gonderi gonderi, String begenekisiid) async {
    DocumentSnapshot ulasilmasigerekengonderi = await _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciningonderileri")
        .document(gonderi.id)
        .get();
    if (ulasilmasigerekengonderi.exists) {
      int mevcutbegenisayisi = ulasilmasigerekengonderi.data["begenisayisi"];
      int begenmeislemi = mevcutbegenisayisi - 1;
      _firestore
          .collection("gonderiler")
          .document(gonderi.yayinlayanId)
          .collection("kullaniciningonderileri")
          .document(gonderi.id)
          .updateData({
        "begenisayisi": begenmeislemi,
      });
      DocumentSnapshot silincekkisi = await _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderibegenileri")
          .document(begenekisiid)
          .get();
      if (silincekkisi.exists) {
        silincekkisi.reference.delete();
      }
    }
  }

  Future<bool> gonderibegenivarmi(Gonderi gonderi, String begenekisiid) async {
    //eger kullanici bir gonderiyii begendiyse kırmızı kalp ikonunun gelmesi icin olsuturduugm bir fonksiyon
    DocumentSnapshot begenekisi = await _firestore
        .collection("begeniler")
        .document(gonderi.id)
        .collection("gonderibegenileri")
        .document(begenekisiid)
        .get();
    if (begenekisi.exists) {
      return true;
    }
    return false;
  }

  void yorumekle(
      Gonderi gonderiid, String yorumicerik, String yayinlayanid) async {
    await _firestore
        .collection("yorumlar")
        .document(gonderiid.id)
        .collection("gonderininyorumlari")
        .add({
      "icerik": yorumicerik,
      "yayinlayanid": yayinlayanid,
      "olusturulmazamani": _dateTime
    });
    duyuruekle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: yayinlayanid,
        yorum: yorumicerik,
        profilSahibiId: gonderiid.yayinlayanId,
        gonderi: gonderiid);
  }

  Stream<QuerySnapshot> yorumgetir(String gonderiid) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiid)
        .collection("gonderininyorumlari")
        .orderBy("olusturulmazamani", descending: true)
        .snapshots();
  }
}
