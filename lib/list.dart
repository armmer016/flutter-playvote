import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:first/main.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  String name;
  String url;
  String logoLink;
  String vote;
  int id;

  Server(String name, String url, String logoLink, String vote, int id) {
    this.name = name;
    this.url = url;
    this.logoLink = logoLink;
    this.vote = vote;
    this.id = id;
  }

  getName() => name;
  getUrl() => url;
  getLogo() => logoLink;
  getVote() => vote;
  getID() => id;
  @override
  String toString() {
    // TODO: implement toString
    return 'ID: $id \nชื่อ: $name \nลิ้ง: $url \nโลโก้: $logoLink \nโหวต: $vote';
  }
}

class ServerPage extends StatefulWidget {
  @override
  ListServer createState() => ListServer();
}

class ListServer extends State<ServerPage> {
  final nameSearch = TextEditingController();
  bool firstlogin;
  FocusNode _focusNode = FocusNode();
  List<Server> serverObject = [];
  Server chooseServer = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void scrape() async {
    String _url =
        ('https://playserver.in.th/index.php/Game/all/1/' + nameSearch.text);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(_url));

    request.headers.set('Host', 'playserver.in.th');
    request.headers.set('Connection', 'close');
    request.headers.set('User-Agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Safari/537.36');

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    //debugPrint(reply);
    // reply = reply.replaceAll('<', 'x');
    // reply = reply.replaceAll('>', 'x');
    // reply = reply.replaceAll('/', 'x');
    reply = reply.replaceAll(' ', '');
    //reply = reply.toLowerCase();
    LineSplitter ls = new LineSplitter();
    List<String> rep = ls.convert(reply);
    //logo server
    var _rep = []; // vote
    var serverUrl = [];
    var logoLinkList = [];

    var _logoLink = rep.forEach((e) {
      if (e.contains('src=') && e.contains('content-serverlogo')) {
        //debugPrint(e);
        e = e.replaceAll('"', '');
        logoLinkList.add(e);
      }
    });
    //server link

    var serverLink = rep.forEach((e) {
      if (e.contains('') &&
          e.contains('ahref=') &&
          e.contains('serverlist-item-content-servername')) {
        //debugPrint(e);
        e = e.replaceAll('"', '');
        serverUrl.add(e);
      }
    });
    for (final a in rep) {
      if (a.contains('serverlist-item-content-stat-totalvote')) {
        //debugPrint(a);
        _rep.add(a);
        //print(_rep.last);

      }
    }
    //print(logoLinkList[0] + "\n" + serverUrl[0]);
    serverObject.clear();
    for (int i = 0; i < serverUrl.length; i++) {
      //extract total vote
      RegExp reg = RegExp('>(.+?)<');
      final match = reg.firstMatch(_rep[i]);
      final rawvote = match.group(1);
      //debugPrint(rawvote);

      //extract link
      RegExp _reg = RegExp('ref=(.+?)>(.+?)<');
      final _match = _reg.firstMatch(serverUrl[i]);
      String servUrl = _match.group(1);
      String nameUrl = _match.group(2);
      //debugPrint(servUrl);

      //extract id
      var editServUrl = servUrl;
      editServUrl += 'END';
      RegExp regID = RegExp('-([0-9]+?)END');
      final idmatch = regID.firstMatch(editServUrl);
      final _idMatch = idmatch.group(1);
      //debugPrint(_idMatch);

      //extract name server
      //servUrl = servUrl.replaceAll(('-' + _idMatch.toString()), '');
      RegExp reg2 = RegExp('Server/(.+)');
      final nameMatch = reg2.firstMatch(servUrl);
      final nameServer = nameMatch.group(1);
      //debugPrint(nameServer);

      //extract logolink
      RegExp __reg = RegExp('src=(.+?)alt');
      final __match = __reg.firstMatch(logoLinkList[i]);
      final logoServLink = __match.group(1);
      //debugPrint(logoServLink);

      //debugPrint(serverObject.toList().toString());
      setState(() {
        serverObject.add(new Server(
            nameUrl, nameServer, logoServLink, rawvote, int.parse(_idMatch)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.deepOrange[500],
          title: Text('ค้นหาเซิร์ฟเวอร์'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 500,
            height: 70,
            child: Container(
              padding: EdgeInsets.only(top: 4),
              margin: EdgeInsets.only(left: 4, right: 4),
              child: TextFormField(
                controller: nameSearch,
                focusNode: _focusNode,
                autofocus: true,
                onFieldSubmitted: (term) {
                  scrape();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white54,
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 5),
                    child: Icon(Icons.question_answer, size: 20),
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 30,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  hintText: "ใส่ชื่อเซิร์ฟเวอร์ที่ต้องการค้นหา",
                ),
              ),
            ),
          ),
          Expanded(
            child: new ListView.builder(
                itemCount: serverObject.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildServer(context, index)),
          )
        ],
      ),
    );
  }

  Widget buildServer(BuildContext context, int index) {
    return new Container(
      child: Card(
        shadowColor: Colors.deepOrange,
        margin: EdgeInsets.all(5),
        child: InkWell(
          onTap: () async {
            chooseServer = serverObject[index];
            // ignore: unnecessary_statements
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('firstlogin', false);
            prefs.setString('server', chooseServer.getName());
            prefs.setString('logo', chooseServer.getLogo());
            prefs.setString('link', chooseServer.getUrl());
            prefs.setInt('id', chooseServer.getID());
            print('that');
            if (chooseServer != null)
              Navigator.pop(context, chooseServer);
            else
              Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 4, right: 4),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    onError: (exception, stackTrace) {
                      Text('โปรดรับภาพใหม่');
                    },
                    image: Image.network(serverObject[index].getLogo()).image,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(top: 10),
                width: 100,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      serverObject[index].getName(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('\n\nโหวต: ' + serverObject[index].getVote()),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
