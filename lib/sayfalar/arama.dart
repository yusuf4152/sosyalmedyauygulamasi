import 'package:flutter/material.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/profil.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';

class Aramasayfasi extends StatefulWidget {
  @override
  _AramasayfasiState createState() => _AramasayfasiState();
}

class _AramasayfasiState extends State<Aramasayfasi> {
  TextEditingController _aramakontrol = TextEditingController();
  Future<List<Kullanici>> aramasonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarolustur(),
      body: aramasonucu == null ? aramayap() : kullanicilarigoster(),
    );
  }

  Widget aramayap() {
    return Center(
      child: Text("arama yapabilirsiniz"),
    );
  }

  AppBar appbarolustur() {
    return AppBar(
      title: TextFormField(
        onFieldSubmitted: (girilendeger) {
          setState(() {
            aramasonucu = Firestoreservisi().kullanicibul(girilendeger);
          });
        },
        controller: _aramakontrol,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon:
                IconButton(icon: Icon(Icons.clear_sharp), onPressed: null),
            fillColor: Colors.white,
            filled: true,
            hintText: "aramak istediğniz kullanıcı adını girin"),
      ),
    );
  }

  Widget kullanicilarigoster() {
    return FutureBuilder<List<Kullanici>>(
      future: aramasonucu,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.length == 0) {
          return Center(
            child: Text("aradığınız kullanıcı bulunamamıştır"),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return siraolustur(snapshot.data[index]);
          },
        );
      },
    );
  }

  Widget siraolustur(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profilsayfasi(
                profilsahibicid: kullanici.id,
              ),
            ));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: kullanici.fotoUrl == ""
              ? AssetImage("assets/images/kedi.jpg")
              : NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
