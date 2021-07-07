import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Storageservisi {
  StorageReference _firebasestorage = FirebaseStorage.instance.ref();
  //storage servisimizn deposu
  String _resimid;

  Future<String> gonderiresimyukle(File resimdosyasi) async {
    _resimid = Uuid().v4();
    // her gonderi icin farklı bir id yapmak için
    StorageUploadTask yuklemeyoneticisi = _firebasestorage
        .child("Resimler/Gonderiler/gonderi$_resimid.jpg")
        .putFile(resimdosyasi);
    StorageTaskSnapshot snapshot = await yuklemeyoneticisi.onComplete;
    String yuklenenresimurl = await snapshot.ref.getDownloadURL();
    return yuklenenresimurl;
  }

  Future<String> profilresimyukle(File resimdosyasi) async {
    _resimid = Uuid().v4();
    // her gonderi icin farklı bir id yapmak için
    StorageUploadTask yuklemeyoneticisi = _firebasestorage
        .child("Resimler/profilresimleri/profil$_resimid.jpg")
        .putFile(resimdosyasi);
    StorageTaskSnapshot snapshot = await yuklemeyoneticisi.onComplete;
    String yuklenenresimurl = await snapshot.ref.getDownloadURL();
    return yuklenenresimurl;
  }

  void resimsil(String resimurl) {
    RegExp aramakriteri = RegExp(r"gonderi.+\.jpg");
    var aramasonucu = aramakriteri.firstMatch(resimurl);
    var dosyaadi = aramasonucu[0];
    if (dosyaadi != null) {
      _firebasestorage.child("Resimler/Gonderiler/$dosyaadi").delete();
    }
  }
}
