import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';

class Yetkilendirmeservisi {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String aktifolankullaniciid;

  Kullanici _kullaniciolustur(FirebaseUser kullanici) {
    return kullanici == null ? null : Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici> get durumtakibi {
    return _firebaseAuth.onAuthStateChanged
        .map((kullanici) => _kullaniciolustur(kullanici));
  }

  Future<Kullanici> maililekayit(String email, String sifre) async {
    AuthResult giriskarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: sifre);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<Kullanici> maililegiris(String email, String sifre) async {
    AuthResult giriskarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<Kullanici> googleilegirisyap() async {
    GoogleSignInAccount googlehesabi = await GoogleSignIn().signIn();
    // google hesabına giris yapıldı
    GoogleSignInAuthentication yetkikarti = await googlehesabi.authentication;
    // giris yapan kullanıcın yetkikarti verildi
    AuthCredential sifresizgirisbelgesi = GoogleAuthProvider.getCredential(
        idToken: yetkikarti.idToken, accessToken: yetkikarti.accessToken);
    // verilen yetki kartini doğrulattı ve atuhetication servisine kimlik istemeden giriş yapabilecği bir kimliksiz giriş belgesi verildi
    AuthResult giriskarti =
        await _firebaseAuth.signInWithCredential(sifresizgirisbelgesi);
    // verilen kimliksiz giriş belgesini kullanarak kimliksiz giriş yapılan credential fonksiyonu çalıştırıldı ve o da authtentication a giris yapabileceği giris kartının döndürdü
    print(giriskarti.user.email);
    print(giriskarti.user.displayName);
    print(giriskarti.user.photoUrl);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<void> cikisyap() {
    _firebaseAuth.signOut();
  }
}
