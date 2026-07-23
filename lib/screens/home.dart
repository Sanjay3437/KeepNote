import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'edit_note_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});


  @override
  Widget build(BuildContext context) {
    String title1 = 'Keep Notes';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title1,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.green,       //main app color—AppBar, primary buttons.
          secondary: Colors.lightGreen,//accent color—highlights, secondary controls.
          surface: Colors.white,       //background color of cards, dialogs, sheets.
          // error:  Colors.red,           //validation/error color.
          error:  Color(0xFFFF4B2B),           //validation/error color.
          onPrimary: Colors.white,     //text/icon color displayed on top of primary.
          onSecondary: Colors.black,   //text/icon color displayed on top of secondary.
          onSurface: Colors.black,     //text/icon color displayed on top of surface.
        ),
      ),
      home:  MyHomePage(title: title1),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Material(
              elevation: 7,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _notes.isEmpty
          ? Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/bg.svg',
                width: 100,
                height: 100,
                semanticsLabel: 'App Logo',
              ),
              const SizedBox(height: 20),
              const Text(
                'No notes yet. Tap + to add one!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      )
        : Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset('assets/images/bglast.svg', fit: BoxFit.cover,),
            ),
            Padding(
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
              },)
            ),
          ],
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


