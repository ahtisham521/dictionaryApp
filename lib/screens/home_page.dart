import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = 'https://owlbot.info/api/v4/dictionary/';
  String token = 'YOUR API KEY HERE';

  TextEditingController textEditingController = TextEditingController();

  //stream for loading the text as soon as it is typed
  StreamController streamController;
  Stream _stream;

  Timer _timer;
  searchText() async {
    if (textEditingController.text.isEmpty ||
        textEditingController.text.length == 0) {
      streamController.add(null);
      return;
    }
    streamController.add('waiting');
    http.Response response = await http.get(
        url + textEditingController.text.trim(),
        headers: {"Authorization": "Token " + token});
    streamController.add(jsonDecode(response.body));
  }

  @override
  void initState() {
    streamController = StreamController();
    _stream = streamController.stream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      bottom: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      onChanged: (String text) {
                        if (_timer?.isActive ?? false) _timer.cancel();
                        _timer = Timer(const Duration(milliseconds: 1000), () {
                          searchText();
                        });
                      },
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Search for a word',
                        contentPadding: const EdgeInsets.only(left: 24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: searchText,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text('Enter a Search Word'),
              );
            }
            if (snapshot.data == 'waiting') {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data['definitions'].length,
              itemBuilder: (context, index) => ListBody(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: ListTile(
                      leading: snapshot.data['definitions'][index]
                                  ['image_url'] ==
                              null
                          ? null
                          : CircleAvatar(
                              backgroundImage: NetworkImage(snapshot
                                  .data['definitions'][index]['image_url']),
                            ),
                      title: Text(
                        textEditingController.text.trim() +
                            '(' +
                            snapshot.data['definitions'][index]['type'] +
                            ')',
                      ),
                      subtitle:
                          Text(snapshot.data['definitions'][index]['example']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child:
                        Text(snapshot.data['definitions'][index]['definition']),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
