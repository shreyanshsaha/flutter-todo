import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ListStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todo.list');
  }

  void writeList(List<String> itemList) async {
    if(itemList.length<=0) return;
    final file = await _localFile;
    final writeToFileString =
        itemList.reduce((value, element) => value + "\\n" + element);
    file.writeAsString(writeToFileString);
  }

  Future<List<String>> readList() async {
    try {
      final file = await _localFile;
      final String fileContents = await file.readAsString();
      print(fileContents);
      List<String> lines = fileContents.split("\\n");
      if(lines.length<=0) return ["Sample Data 1", "Sample Data 2", "Sample Data 3"];
      return lines;
    } catch (e) {
      debugPrint(e);
      exit(1);
      return null;
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final ListStorage storage = new ListStorage();
  List<String> _listItems = ["Sample Data 1", "Sample Data 2", "Sample Data 3"];

  @override
  void initState() {
    super.initState();
    storage.readList().then((List<String> value) {
      setState(() {
        _listItems = value;
      });
    });
  }

  bool _newItemFieldVisibility = true;
  TextEditingController _textController = new TextEditingController();

  // ***************************
  // * Functions related to list
  // ***************************

  void _addListItem(String item) {
    if (item.length <= 0) return;
    setState(() {
      _listItems.add(item);
      _textController.clear();
    });
    storage.writeList(_listItems);
  }

  void _deleteListItem(int index) {
    setState(() {
      _listItems.removeAt(index);
    });
    storage.writeList(_listItems);
  }

  void _reorderList(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      final String item = _listItems.removeAt(oldIndex);
      _listItems.insert(newIndex, item);
    });
    storage.writeList(_listItems);
  }

  Widget _buildList(int index) {
    return Card(
      key: ValueKey("Value$index"),
      child: ListTile(
        leading: Icon(Icons.drag_handle),
        title: Text(_listItems[index]),
        trailing: IconButton(
          iconSize: 24.0,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(0),
          onPressed: () => _deleteListItem(index),
          icon: Icon(
            Icons.delete_forever,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  // ***************************
  // * Functions end
  // ***************************

  Widget _newItemField(bool fieldVisibility) {
    return Card(
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: "Add Item",
          contentPadding: EdgeInsets.all(16.0),
        ),
        autocorrect: false,
        onSubmitted: (item) => _addListItem(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Container(
        margin: EdgeInsets.only(top: 48.0),
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              "TODO",
              style: TextStyle(fontSize: 36.0),
            ),
            Divider(),
            new Expanded(
              child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) =>
                    _reorderList(oldIndex, newIndex),
                children: List.generate(
                    _listItems.length, (index) => _buildList(index)),
              ),
            ),
            _newItemField(_newItemFieldVisibility),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addListItem(item),
      //   tooltip: 'Add item',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

// Widget _buildList() {
//   return ListView.builder(
//     // padding: EdgeInsets.all(18.0),
//     itemCount: _listItems.length,
//     itemBuilder: (BuildContext context, int index) {
//       return Card(
//         child: ListTile(
//           leading: Icon(Icons.more_vert),
//           title: Text(_listItems[index]),
//           trailing: IconButton(
//             iconSize: 24.0,
//             alignment: Alignment.centerRight,
//             padding: EdgeInsets.all(0),
//             onPressed: () => _deleteListItem(index),
//             icon: Icon(
//               Icons.delete_forever,
//               color: Colors.redAccent,
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
