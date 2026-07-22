import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatelessWidget {
  const Home({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keep Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.lightGreen,
        ),
      ),
      home: const MyHomePage(title: 'Keep Notes'),
    );
  }
}

// above it was Stateless == static
// -----------------------------------------------------------------------------------------------------------------------------//
// below it is Statefull == Dynamic



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 //  reference data
  final _notebook = Hive.box("notebook");

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    final List<Map<String, dynamic>> data = _notebook.keys.map((key) {
      final item = Map<String, dynamic>.from(_notebook.get(key) as Map);
      return {
        "key": key,
        "title": (item["title"] ?? "") as String,
        "content": (item["content"] ?? "") as String,
      };
    }).toList();

    setState(() {
      _notes.clear();
      _notes.addAll(data);
    });
  }


 final List<Map<String, dynamic>> _notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 5,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: _notes.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: const Center(
              child: Text('No notes yet!!!'),
            ),
          )
          : Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _notebook.delete(_notes[index]['key']).then((_) {
                      _refreshNotes();
                    });
                  },
                  child: Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        _notes[index]['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _notes[index]['content'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNoteScreen(
                              note: {
                                "title": _notes[index]["title"],
                                "content": _notes[index]["content"],
                              },
                            ),
                          ),
                        );

                        if (result != null && result is Map<String, String>) {
                          await _notebook.put(_notes[index]['key'], result);
                          _refreshNotes();
                        } else if (result == 'delete') {
                          await _notebook.delete(_notes[index]['key']);
                          _refreshNotes();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditNoteScreen(),
            ),
          );

          if (result != null && result is Map<String, String>) {
            await _notebook.add(result);
            _refreshNotes();
          }
        },
        tooltip: 'Add Note',
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  final Map<String, String>? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.note?['title'] ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?['content'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 5,
        foregroundColor: Colors.white,
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context, 'delete');
              },
            ),
         ],
      ),
      body:
        Form(
          key: _formKey,
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Content',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final content = _contentController.text;
                  // if (title.isNotEmpty || content.isNotEmpty) {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notes Saved')),
                    );
                    Navigator.pop(context, {'title': title, 'content': content});
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 150.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child: const Text(
                      "Save Note",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
