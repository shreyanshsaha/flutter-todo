# todo_app

A new Flutter project build to demonstrate Stateful Widget, File Handling, ReorderableListView and state events.

## Getting Started
### Prerequisite
Add path_provider line to **pubspec.yaml** which is used for file handling.
```yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  path_provider: ^1.0.0
 ```

The jist of the app is to make a todo/ shopping list and store the items in a file so they are present when app is closed. The app also has option to delete items, add more items and reorder items. It doesn't have an option to edit the list items _yet_.

We'll go over the important changes in the code which deviates from the default app given to us by flutter:

### Storage Class

```dart
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
```
The segment of code implements out file operations. Making this in in its own class keeps our code easy and modular. Also it helps in debugging.

```dart
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todo.list');
  }
  ```
  These two variables are defined as asynchronous. They return the document path and the file. For me the document path was `/data/user/0/com.example.todo_app/app_flutter` where the list file was stored.
  
  ```dart
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
  ```
  This segment contains the code to read and write code. I tried saving the list as json but it didn't work for some reason. So, i just convert the list to a string seperated by \n (newline) and store it in the file. I was also unable to use the Sync Write functions that's why I have to write all data at once otherwise its overwritten.
  
  The read function just reads the file and splits it by \n (newline) and returns. Incase the file is empty then we send a sample list.
  
  ### Widget class
  
  ```dart
  @override
  void initState() {
    super.initState();
    storage.readList().then((List<String> value) {
      setState(() {
        _listItems = value;
      });
    });
  }
  ```
  
  This is called to initialize the state. Since we need to build the list from the file we set it up as we init the state. _\_listItems_ is a private class variable.
  
  ```dart
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
```
  
These functions all change the state of the app, thus, they call the setState function. They change the state by deleting, adding or reordering the items. _\_reorderList_ is a function required by **ReorderableListView** widget.

```dart
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
```

To keep the code clean and make my life a little easier I have a seperate function which generates the card you see in the app. It takes the index for _\_listItems_ and returns a card with the todo item. **Key** param is only required for **ReorderableListView**.

```dart
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
```
This handles the input text field. I made a controller in case I need more control over the input data. You can do fine without the textController.

```dart
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
    );
  }
  ```
  This is the main code for the complete app. It's smaller than most flutter codes since i have divided most things into functions. Here we create a container for padding and margin, which contains a Column Widget. It has the main heading, divider, todo list and the inpu field.

```dart
 child: ReorderableListView(
    onReorder: (int oldIndex, int newIndex) =>
                 _reorderList(oldIndex, newIndex),
    children: List.generate(
          _listItems.length, (index) => _buildList(index)),
  ),
```
This is the reorderable list. Here we need the _\_reorderList()_ function. Also instead of keeping a fixed list we generate a list and change the widget's state when required to update the view.



For help getting started with Flutter, view
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
