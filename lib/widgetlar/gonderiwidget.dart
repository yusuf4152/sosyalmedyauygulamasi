import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosyalmedyauygulamasi/modeller/gonderi.dart';
import 'package:sosyalmedyauygulamasi/modeller/kullanici.dart';
import 'package:sosyalmedyauygulamasi/sayfalar/yorum.dart';
import 'package:sosyalmedyauygulamasi/servisler/firestoreservisi.dart';
import 'package:sosyalmedyauygulamasi/servisler/yetkilendirmeservisi(authetication).dart';

class GOnderiwidget extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinayalankisi;

  const GOnderiwidget({Key key, this.gonderi, this.yayinayalankisi})
      : super(key: key);

  @override
  _GOnderiwidgetState createState() => _GOnderiwidgetState();
}

class _GOnderiwidgetState extends State<GOnderiwidget> {
  int gonderibegenisayisi = 0;

  bool begendimi = false;
  String _aktifkullaniciid;
  @override
  void initState() {
    super.initState();
    gonderibegenisayisi = widget.gonderi.begeniSayisi;
    _aktifkullaniciid =
        Provider.of<Yetkilendirmeservisi>(context, listen: false)
            .aktifolankullaniciid;
    begenmismi();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          gonderibasligi(),
          gonderiresmi(),
          gonderialtpanel(),
        ],
      ),
    );
  }

  begenmismi() async {
    bool varmi = await Firestoreservisi()
        .gonderibegenivarmi(widget.gonderi, _aktifkullaniciid);
    if (varmi) {
      if (mounted) {
        //eger widget agacta (ekranda)var ise set state işlemini gerceklesitr;
        setState(() {
          begendimi = true;
        });
      }
    }
  }

  gonderisecenekleri() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("gonderi silme"),
          children: [
            SimpleDialogOption(
              child: Text(
                "Gonderiyi sil",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Firestoreservisi().gonderisil(
                    aktifkullaniciid: _aktifkullaniciid,
                    gonderi: widget.gonderi);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text("iptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget gonderibasligi() {
    return ListTile(
        contentPadding: EdgeInsets.all(0.0),
        leading: CircleAvatar(
          backgroundColor: Colors.pink,
          radius: 50.0,
          backgroundImage: widget.yayinayalankisi.fotoUrl.isNotEmpty
              ? NetworkImage(widget.yayinayalankisi.fotoUrl)
              : AssetImage("assets/images/kedi.jpg"),
        ),
        title: Text(
          widget.yayinayalankisi.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: _aktifkullaniciid == widget.gonderi.yayinlayanId
            ? IconButton(
                icon: Icon(Icons.more_vert_outlined),
                onPressed: () => gonderisecenekleri(),
              )
            : null);
  }

  Widget gonderiresmi() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: GestureDetector(
        onDoubleTap: () => _begenmeisleri(),
        child: Image.network(
          widget.gonderi.gonderiResmiUrl,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
          scale: 1,
        ),
      ),
    );
  }

  gonderialtpanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: !begendimi
                  ? Icon(
                      Icons.favorite_border_outlined,
                      size: 30.0,
                    )
                  : Icon(
                      Icons.favorite_outlined,
                      color: Colors.red,
                    ),
              onPressed: _begenmeisleri,
            ),
            SizedBox(
              width: 3.0,
            ),
            IconButton(
              icon: Icon(
                Icons.comment_outlined,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Yorum(
                        gonderi: widget.gonderi,
                      ),
                    ));
              },
            ),
          ],
        ),
        SizedBox(
          height: 3.0,
        ),
        Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              "$gonderibegenisayisi beğeni",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        widget.gonderi.aciklama != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: RichText(
                    text: TextSpan(
                        text: widget.yayinayalankisi.kullaniciAdi + " ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                      TextSpan(
                        text: widget.gonderi.aciklama,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.black),
                      ),
                    ])),
              )
            : SizedBox(
                height: 0.0,
              ),
      ],
    );
  }

  void _begenmeisleri() async {
    if (!begendimi) {
      setState(() {
        begendimi = true;
        gonderibegenisayisi++;
      });
      await Firestoreservisi().gonderibegen(widget.gonderi, _aktifkullaniciid);
    } else {
      setState(() {
        begendimi = false;
        gonderibegenisayisi--;
      });
      Firestoreservisi().gonderibegenikaldir(widget.gonderi, _aktifkullaniciid);
    }
  }
}
