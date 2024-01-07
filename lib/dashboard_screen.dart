import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:intl/intl.dart';

import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class AudioModel {
  int idaudios;
  String filename;
  bool audited;
  String level;
  String author;
  String date;
  AudioModel(this.idaudios, this.filename, this.level, this.author,
      this.audited, this.date);

  AudioModel.fromJson(Map<String, dynamic> json)
      : idaudios = json['idaudios'],
        filename = json['filename'],
        audited = json['audited'] == 0 ? false : true,
        level = json['level'],
        author = json['author'],
      //  date =   json['date'].toString().substring(0,10) ;
       date =  DateFormat('dd-MM-yyyy').format(DateTime.parse( json['date']));
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<AudioModel> audioListWaiting = <AudioModel>[];
  List<AudioModel> audioListAccepted = <AudioModel>[];

  late ProgressDialog pd;
  AudioPlayer audioPlayer = AudioPlayer();

//final url = Uri.parse('http://192.168.0.20:3000');
  //final url = Uri.parse('http://localhost/');
  final url = Uri.parse(
      "https://4371d04djc.execute-api.us-east-1.amazonaws.com/default/MustakisAudioDBManager-staging");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _makeGetRequest();
    });
    pd = ProgressDialog(context: context);
  }

  _makeLambdaCall(requestPayload) async {
    Response response;
    var dio = Dio();
    response = await dio.post(
      url.toString(),
      data: requestPayload,
    );
    final result = jsonDecode(response.data['body']);
    return result;
  }

  _makeGetRequest() async {
    Map<String, dynamic> requestPayload = {
      "RPC": "FetchAllAudioRecordsFromDatabase"
    };

    List<dynamic> list = await _makeLambdaCall(requestPayload);
    audioListAccepted.clear();
    audioListWaiting.clear();
    for (var item in list) {
      AudioModel audio = AudioModel.fromJson(item);

      if (audio.audited)
        audioListAccepted.add(audio);
      else
        audioListWaiting.add(audio);
    }
    print(audioListAccepted.length);
    setState(() {});
  }



  _onSwipe(direction, idAudios) async {
    final bMustAdd = direction != DismissDirection.endToStart;
    _processSwipe(bMustAdd, idAudios);
  }

  _processSwipe(acceptAudio, idAudios) async {
    int removeIndex = -1;
    for (var i = 0; i < audioListWaiting.length; i++) {
      // print(audioList[i].key + " ==" + item);

      if (audioListWaiting[i].idaudios == idAudios) {
        removeIndex = i;
        break;
      }
    }
    if (removeIndex < 0) return;
    pd.show(
      max: 100,
      msg: 'Actualizando...',
      progressType: ProgressType.normal,
    );
    Map<String, dynamic> requestPayload = {
      'RPC': acceptAudio ? 'acceptAudioInDatabase' : 'removeAudioFromDatabase',
      'audioId': audioListWaiting[removeIndex].idaudios,
      'fileName': audioListWaiting[removeIndex].filename
    };
    final result = await _makeLambdaCall(requestPayload);
    print(requestPayload);
    setState(() {
      audioListWaiting.removeAt(removeIndex);
    });
    for (int i = 0; i <= 100; i++) {
      /// You can indicate here that the download has started.
      pd.update(value: i, msg: 'Actualizando...');
      i++;
      await Future.delayed(Duration(milliseconds: 30));
    }
    _makeGetRequest();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [
                Tab(text: "En espera", icon: Icon(Icons.access_alarm)),
                Tab(
                    text: ('Aceptados'),
                    icon: Icon(Icons.cloud_done, color: Colors.greenAccent))
              ]),
              title: const Text('Audio list'),
            ),
            body: TabBarView(children: [
              ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.green),
                itemCount: audioListWaiting.length,
                itemBuilder: (context, index) {
                  final item = audioListWaiting[index];
                  return Dismissible(
                      key: Key(audioListWaiting[index].filename),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        decoration: BoxDecoration(
                          //                    <-- BoxDecoration
                          border: Border(bottom: BorderSide()),
                          color: Colors.blue,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.favorite, color: Colors.white),
                              Text('Agregar a Aceptados',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.delete, color: Colors.white),
                              Text('Borrar del sistema',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      onDismissed: (direction) => {
                            _onSwipe(
                                direction, audioListWaiting[index].idaudios)
                          },
                      child: ListTile(
                        title: Text(audioListWaiting[index].level),
                       subtitle:Wrap(children: <Widget>[Text(audioListWaiting[index].author),Padding(padding: const EdgeInsets.only(left: 30),child: Text(audioListWaiting[index].date, style: TextStyle(fontWeight: FontWeight.bold),),)]),
                       // subtitle:Wrap(children: <Widget>[Text(audioListWaiting[index].author)]),

                          leading: CircleAvatar(
                          child: IconButton(
                              onPressed: () async {
                                final audioUrl =
                                    'https://bosque-mustakis.s3.amazonaws.com/Audios/${audioListWaiting[index].filename}';

                                try {
                                  await audioPlayer.setUrl(audioUrl);
                                  audioPlayer.play();
                                } on PlayerException catch (e) {
                                  _showAlert(
                                      "Archivo no existe en servidor", context);
                                  print("Error code: ${e.code}");
                                } catch (e) {
                                  // Fallback for all errors
                                  print(e);
                                }
                              },
                              icon: Icon(Icons.play_arrow_rounded)),
                        ),
                        trailing: Container(
                            width: 300,
                            margin: const EdgeInsets.fromLTRB(0, 0, 60.0, 0),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.swipe, color: Colors.blue),
                                Text('swipe para borrar o aceptar',
                                    style: TextStyle(color: Colors.blueGrey)),
                              ],
                            )),
                      ));
                },
              ),
              ///accepted List
              ListView.builder(
                itemCount: audioListAccepted.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    title: Text(audioListAccepted[index].level),
                       //   subtitle:Wrap(children: <Widget>[Text(audioListAccepted[index].author),Padding(padding: const EdgeInsets.only(left: 30),child: Text(audioListAccepted[index].date, style: TextStyle(fontWeight: FontWeight.bold),),)]),
                          subtitle:Wrap(children: <Widget>[Text(audioListAccepted[index].author)]),

                    leading: CircleAvatar(
                      child: IconButton(
                          onPressed: () async {
                            final audioUrl =
                                'https://bosque-mustakis.s3.amazonaws.com/Audios/${audioListAccepted[index].filename}';

                            try {
                              await audioPlayer.setUrl(audioUrl);
                              audioPlayer.play();
                            } on PlayerException catch (e) {
                              _showAlert(
                                  "Archivo no existe en servidor", context);
                              print("Error code: ${e.code}");
                            } catch (e) {
                              // Fallback for all errors
                              print(e);
                            }
                          },
                          icon: Icon(Icons.play_arrow_rounded)),
                    ),
                    trailing: Wrap(
                      spacing: 24,
                      children: [
                        IconButton(
                            icon: Icon(Icons.check_circle_rounded),
                            color: Colors.green,
                            onPressed: () {})
                      ],
                    ),
                  ));
                },
              )
            ]),
          )),
    );
  }
}

Future<void> _showAlert(String message, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alerta'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Alerta:$message!',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class AudioCard extends StatelessWidget {
  final int audioId;
  final String audioTitle;
  final String filename;
  final ValueSetter<int> onDelete;
  final ValueSetter<int> onAccept;

  final AudioPlayer audioPlayer = AudioPlayer();
  AudioCard(this.audioId, this.audioTitle, this.filename, this.onAccept,
      this.onDelete);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: SizedBox(
          width: 50,
          height: 50,
          child: Card(
              color: Colors.orange.shade100,
              child: ListTile(
                title: Text(audioTitle),
                leading: CircleAvatar(
                  child: IconButton(
                      onPressed: () async {
                        try {
                          await audioPlayer.setUrl(
                              'https://bosque-mustakis.s3.amazonaws.com/Audios/$filename');
                          audioPlayer.play();
                        } on PlayerException catch (e) {
                          //  _showAlert("Archivo no existe en servidor", context);
                          print("Error code: ${e.code}");
                        } catch (e) {
                          // Fallback for all errors
                          print(e);
                        }
                      },
                      icon: Icon(Icons.play_arrow_rounded)),
                ),
                trailing: Wrap(
                  spacing: 24,
                  children: [
                    IconButton(
                        icon: Icon(Icons.check_circle_rounded),
                        color: Colors.green,
                        onPressed: () {
                          onAccept(audioId);
                        }),
                    IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          onDelete(audioId);
                        })
                  ],
                ),
                subtitle: ButtonBar(
                  children: <Widget>[],
                ),
              ))),
    );
  }
}
