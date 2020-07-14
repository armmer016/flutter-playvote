import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:first/list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = 'mobile_id';
const String appIdIOS = 'ca-app-pub-1403436244598664~3448156465';
const String appIdAndroid = 'ca-app-pub-1403436244598664~6220184680';
const String bannerAndroid = 'ca-app-pub-1403436244598664/2975730781';
const String bannerIOS = 'ca-app-pub-1403436244598664/7521480457';
const String unitRewardedAndroid = 'ca-app-pub-1403436244598664/4332387941';
const String unitRewaredIOS = 'ca-app-pub-1403436244598664/9821993121';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>['testDevice'] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Reward', 'storage'],
  );

  String idImage = null;
  String idImageOld;
  Uint8List imageData;
  int waiting = 61; //คูลดาวน์โหวต
  int waitingTotal = 0; //ภาพที่รอโหวต
  int success = 0; //ภาพถูก
  int storage = 2; //คลังภ่าพ
  int loading = 40; //คูลดาวน์โหลดภาพ
  var correctBox = Colors.green;
  var incorrectBox = Colors.red;
  var normalBox = Colors.white.withOpacity(0);
  var _normalBox = Colors.white.withOpacity(0);
  final answer = TextEditingController();
  final username = TextEditingController();
  String servername;
  String logoLink;
  String serverLink;
  int id;
  //String adUnitId = 'ca-app-pub-1403436244598664/4332387941';

  Server _listServer;

  void makeRequest() async {
    //print(_listServer.getName());
    String url = "http://playserver.co/index.php/Vote/ajax_getpic/" +
        serverLink.toString();
    var response;
    //print(Uri.encodeFull(url));
    try {
      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "/",
        "Content-Length": "0",
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36",
        "Origin": "http://playserver.in.th",
        "Referer": Uri.encodeFull(
            "http://playserver.in.th/index.php/Vote/prokud/" +
                serverLink.toString()),
        "Accept-Encoding": "gzip, deflate",
        "Accept-Language": "en-US,en;q=0.9",
        "Connection": "close"
      }).timeout(Duration(seconds: 5));

      //print('get ID = ' + response.body);
      List data;
      var id = response.body.toString();
      RegExp regExp = new RegExp(
        '"checksum":"(.+?)"',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(id);
      final matchGroup = match.group(1);
      //print(matchGroup);
      idImageOld = idImage;
      idImage = matchGroup;
    } catch (e) {
      print('error http');
    }
    //print(idImage);
  }

  void getPicture() async {
    if ((serverLink != null && serverLink != '')) {
      if (storage > 0) {
        makeRequest();
        //auto();
        String url = ("http://playserver.co/index.php/VoteGetImage/" +
            idImage.toString());
        try {
          var response = await http.get(Uri.encodeFull(url), headers: {
            "Accept": "image/webp,image/apng,image/*,*/*;q=0.8",
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36",
            "Referer": Uri.encodeFull(
                'http://playserver.in.th/index.php/Vote/prokud/' +
                    serverLink.toString()),
            "Accept-Encoding": "gzip, deflate",
            "Accept-Language": "en-US,en;q=0.9",
            "Cookie":
                "__utma=123569098.25167225.1590924307.1590924307.1590924307.1; __utmz=123569098.1590924307.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided)",
            "Connection": "close"
          }).timeout(Duration(seconds: 5));
          //print('link ID = ' + url);

          print('image = ' + response.bodyBytes.toString());
          if (response.statusCode == 200 &&
              response.bodyBytes.toString() != '[]') {
            //imageData = response.bodyBytes;
            setState(() {
              print("setSTATE");
              imageData = response.bodyBytes;
              if (storage > 0) storage -= 1;
            });
          } else if (imageData.toString() == '[]') {
            //print('failed');
            //showFailedAlert(context);
            getPicture();
          }
        } catch (e) {
          print(e);
        }
      } else {
        showAlert(context);
      }
    } else {
      choosePage();
    }
    //print(imageData.toString());
  }
  //Timer waitTime;

  Future<http.Response> submit() async {
    //timer?.cancel();
    String url =
        //"http://httpbin.org/post";
        "http://playserver.co/index.php/Vote/ajax_submitpic/" +
            serverLink.toString();

    //src="http://playserver.co/index.php/VoteGetImage/"
    if (listAnswer.length != 0) {
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('Host', 'playserver.co');
      request.headers.set('Accept', '*/*');
      request.headers.set(
          'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      request.headers.set('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36');
      request.headers.set('Origin', 'http://playserver.in.th');
      request.headers.set(
          'Referer',
          Uri.encodeFull('http://playserver.in.th/index.php/Vote/prokud/' +
              serverLink.toString()));
      request.headers.set('Accept-Encoding', 'gzip, deflate');
      request.headers.set('Accept-Language', 'en-US,en;q=0.9');
      request.headers.set('Connection', 'close');
      request.headers.set(
          'Content-Length', utf8.encode(listAnswer.first).length.toString());
      request.add(utf8.encode(listAnswer.first));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      httpClient.close();
      print(reply);
      print(listAnswer.first);
      listAnswer.remove(listAnswer.first);
      setState(() {
        waitingTotal = listAnswer.length;
      });
      if (reply.contains('success":true')) {
        setState(() {
          success += 1;
          normalBox = correctBox;
        });
        sleepSec();
      } else {
        normalBox = incorrectBox;
        sleepSec();
        submit();
      }
    }

    // if (reply.contains('true')) {
    //   getPicture();
    // }
  }

  void auto() {
    const sec = const Duration(seconds: 1);
    int count = 1;
    Timer waitTime = new Timer.periodic(
        sec,
        (Timer s) => setState(() {
              //if (listAnswer.length != 0) {
              if (waitingTotal == 0) {
                if (waiting != 0) {
                  count = 1;
                } else {
                  count = 0;
                }
              } else {
                count = 1;
              }
              if (waiting != 0) {
                waiting -= count;
              } else if (waiting == 0) {
                if (waitingTotal != 0) {
                  submit();
                  waiting = 61;
                } else {
                  waiting = 0;
                }
              }
              //}
            }));
    //timer = new Timer.periodic(minute, (Timer t) => submit());
    //print(listAnswer);
  }

  void loadAuto(int count) {
    const sec = const Duration(seconds: 1);
    int changedCount = count;
    Timer waitTime = new Timer.periodic(
        sec,
        (Timer s) => setState(() {
              //if (listAnswer.length != 0) {
              if (storage >= 10) {
                if (loading != 0) {
                  count = changedCount;
                } else {
                  count = 0;
                }
              } else {
                count = changedCount;
              }
              if (loading != 0) {
                loading -= count;
              } else if (loading == 0) {
                if (storage < 10) {
                  storage += 1;
                  loading = 30;
                } else {
                  loading = 0;
                }
              }
              //}
            }));
    //timer = new Timer.periodic(minute, (Timer t) => submit());
    //print(listAnswer);
  }

  var listAnswer = [];

  void addToList(BuildContext context) {
    if ((serverLink != null && serverLink != '')) {
      if (storage > 0) {
        String bodies = ('server_id=$id&captcha=' +
            answer.text.toString().toLowerCase() +
            "&gameid=" +
            username.text +
            "&checksum=" +
            idImageOld);
        listAnswer.add(bodies);

        setState(() {
          waitingTotal = listAnswer.length;
        });
        getPicture();
        if (storage == 1) showAlert(context);
      } else {
        showAlert(context);
      }
      //print(listAnswer);
    } else {
      choosePage();
    }
  }

  Future sleepSec() {
    return new Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        normalBox = _normalBox;
      });
    });
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    username.text = prefs.getString('username');
    servername = prefs.getString('server');
    logoLink = prefs.getString('logo');
    serverLink = prefs.getString('link');
    id = prefs.getInt('id');
  }

  RewardedVideoAd videoAd = RewardedVideoAd.instance;
  bool _loaded = false;
  FocusNode _focusNode = FocusNode();

  //banner ad
  BannerAd myBanenr = BannerAd(
      adUnitId: bannerAndroid,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo);

  @override
  void initState() {
    super.initState();
    myBanenr
      ..load()
      ..show(anchorType: AnchorType.bottom, anchorOffset: 20);
    //videoAd.load(adUnitId: idImage, targetingInfo: targetingInfo);
    FirebaseAdMob.instance.initialize(appId: appIdAndroid);
    videoAd.listener =
        (RewardedVideoAdEvent event, {int rewardAmount, String rewardType}) {
      if (event == RewardedVideoAdEvent.completed) {
        setState(() {
          storage += 10;
        });
      } else if (event == RewardedVideoAdEvent.closed) {
        videoAd.load(
            adUnitId: unitRewardedAndroid, targetingInfo: targetingInfo);
      }
    };
    videoAd.load(adUnitId: unitRewardedAndroid, targetingInfo: targetingInfo);
    _loadData();
    auto();
    loadAuto(1);
    getPicture();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    // () async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.clear();
    // };
  }

  showFailedAlert(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(
        'แจ้งเตือน!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: 100,
        child: Column(children: [
          Text('ภาพเต็มหรือระบบมีปัญหา ลองใหม่อีกครั้ง'),
        ]),
      ),
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () {
              //getPicture();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
            label: Text('ปิด')),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlert(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(
        'แจ้งเตือน!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Text('ภาพของคุณหมดคลังแล้ว'),
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () {
              try {
                videoAd.show();
              } catch (e) {}
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.ondemand_video),
            label: Text(
              'รับ 10 ภาพ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            )),
        FlatButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
            label: Text('ปิด')),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showProfile(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(
        'Profile',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Container(
          width: 400,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image:
                        DecorationImage(image: Image.network(logoLink).image),
                  )),
              RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    choosePage();
                  },
                  child: Text(
                    servername,
                    overflow: TextOverflow.ellipsis,
                  )),
              TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'ชื่อผู้เล่น',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.person_outline),
                  )),
            ],
          )),
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('username', username.text);

              Navigator.of(context).pop();
            },
            icon: Icon(Icons.save),
            label: Text('Save')),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return alert;
          });
        });
  }

  choosePage() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    final resulted = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ServerPage()));
    _listServer = resulted;
    if (resulted != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('server', _listServer.getName());
      prefs.setString('logo', _listServer.getLogo());
      prefs.setString('link', _listServer.getUrl());
      prefs.setInt('id', _listServer.getID());
      setState(() {
        servername = prefs.getString('server') ?? 'ERROR';
        logoLink = prefs.getString('logo') ?? '';
        serverLink = prefs.getString('link') ?? 'MC-Surviver-19921';
        id = prefs.getInt('id') ?? 19921;
      });

      //idImage = '';

      getPicture();
      // setState(() {
      //   storage += 1;
      // });
      // getPicture();

      showProfile(context);
    }
  }

  var setText = TextStyle(fontSize: 18, color: Colors.black);

  Widget button() {
    return SizedBox(
        height: 62,
        width: 1000,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            //Padding(padding: EdgeInsets.all(20)),
            Container(
              padding: EdgeInsets.only(right: 10),
              color: Colors.white,
              width: 120,
              child: Column(children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      if ((serverLink != null && serverLink != '')) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        showProfile(context);
                      } else {
                        choosePage();
                      }
                    }),
                Text(
                  '    Profile',
                  style: TextStyle(fontSize: 10),
                )
              ]),
            ),
            Container(
              padding: EdgeInsets.only(right: 10),
              width: 100,
              color: Colors.white,
              child: Column(children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 38,
                      color: Colors.blueAccent[200],
                    ),
                    onPressed: () {
                      addToList(context);
                      answer.clear();
                    }),
                Text(
                  '    ส่งภาพ',
                  style: TextStyle(fontSize: 10),
                )
              ]),
            ),
            Container(
              padding: EdgeInsets.only(right: 10),
              width: 100,
              color: Colors.white,
              child: Column(children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.cloud_download,
                      size: 40,
                      color: Colors.lightGreen,
                    ),
                    onPressed: getPicture),
                Text(
                  '    รับภาพ',
                  style: TextStyle(fontSize: 10),
                )
              ]),
            ),
            Container(
              padding: EdgeInsets.only(right: 10),
              width: 100,
              color: Colors.white,
              child: Column(children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.search,
                      size: 40,
                      color: Colors.black,
                    ),
                    onPressed: choosePage),
                Text(
                  '    เลือกเซิร์ฟ',
                  style: TextStyle(fontSize: 10),
                )
              ]),
            ),
            Container(
              padding: EdgeInsets.only(right: 10),
              width: 100,
              color: Colors.white,
              child: Column(children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.photo_library,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    if (storage + 10 <= 30)
                      try {
                        videoAd.show();
                      } catch (e) {
                        showFailedAlert(context);
                      }
                    else
                      showFailedAlert(context);
                  },
                ),
                Text(
                  '    รับ 10 ภาพ',
                  style: TextStyle(fontSize: 10),
                )
              ]),
            ),
          ],
        ));
  }

  Widget picture() {
    return Container(
        margin: EdgeInsets.only(top: 15, left: 15, right: 15),
        //width: 325,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
        //color: Colors.white,
        //padding: EdgeInsets.only(top: 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          (imageData.toString() == '[]' || imageData == null || storage == 0)
              ? Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    //padding: EdgeInsets.only(top: 80, bottom: 20),
                    child: Text(
                      "\n\n\n\nไม่มีภาพ! โปรดรับภาพใหม่\n\n\n",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Expanded(
                  //alignment: Alignment.center,
                  //padding: EdgeInsets.only(top: 80, bottom: 30),
                  //height: 200,
                  //width: 300,
                  child: Container(
                    margin: EdgeInsets.only(top: 15, right: 15, left: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        onError: (exception, stackTrace) {
                          Text('โปรดรับภาพใหม่');
                        },
                        image: Image.memory(imageData).image,
                      ),
                    ),
                  ),
                ),
          Container(
              height: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 15),
              child: Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.white),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: answer,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: _focusNode,
                  //autofocus: true,
                  onFieldSubmitted: (term) {
                    addToList(context);
                    answer.clear();
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
                        icon: Icon(Icons.send),
                        onPressed: () {
                          addToList(context);
                          answer.clear();
                        },
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    hintText: "ใส่รหัสตัวพิมพ์ใหญ่/เล็ก",
                  ),
                ),
              ))
        ]));
  }

  Widget score() {
    return SafeArea(
        child: Container(
      //width: 500,
      height: 70,
      margin: EdgeInsets.only(top: 5, bottom: 0),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: 110,
            height: 70,
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: normalBox,
                border: Border.all(color: Colors.white, width: 0.8),
                borderRadius: BorderRadius.circular(15)),
            child: Container(
              margin: EdgeInsets.only(top: 12),
              child: Text(
                'โหวตถูก ' + success.toString() + ' ภาพ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            width: 110,
            height: 90,
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                //color: Colors.red[400],
                border: Border.all(color: Colors.white, width: 0.8),
                borderRadius: BorderRadius.circular(15)),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                'รอส่ง ' +
                    waiting.toString() +
                    " วินาที \nคงเหลือ " +
                    listAnswer.length.toString() +
                    ' ภาพ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            width: 110,
            height: 90,
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                //color: Colors.redAccent[200],
                border: Border.all(color: Colors.white, width: 0.8),
                borderRadius: BorderRadius.circular(15)),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                'รอรับ ' +
                    loading.toString() +
                    ' วินาที\n' +
                    ' คลังภาพ ' +
                    storage.toString() +
                    ' ภาพ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Colors.deepOrange[500],
            flexibleSpace: score(),
          ),
        ),
        body: SizedBox(
          width: 1200,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.deepOrange[300],
              Colors.orange[200],
            ])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //Padding(padding: EdgeInsets.only(top: 0)),
                button(),
                Expanded(
                  //margin: EdgeInsets.only(bottom: 40),
                  child: picture(),
                ),
                Expanded(
                    child: Container(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Icon(
                        Icons.keyboard,
                        size: 150,
                        color: Colors.grey,
                      ),
                      Text('Keyboard'),
                    ]),
                  ),
                  margin: EdgeInsets.only(top: 30, left: 15, right: 15),
                  //width: 325,
                  //height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    gradient:
                        LinearGradient(begin: Alignment.topCenter, colors: [
                      Colors.white,
                      Colors.white70,
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                ))
              ],
            ),
          ),
        ));
  }
}
