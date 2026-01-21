import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'note.dart';
import 'note_db.dart';
import 'note_form_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes(); // Memuat data saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil data terbaru dari SQLite
  Future<void> _refreshNotes() async {
    setState(() => _loading = true);

    // Mengambil data dari database
    final data = await NoteDb.instance.queryAll();

    setState(() {
      // Mengubah List Map menjadi List Objek Note
      _notes = data.map((e) => Note.fromMap(e)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        elevation: 0,
        actions: [
          IconButton(onPressed: _refreshNotes, icon: const Icon(Icons.refresh)),
        ],
      ),
      // Tombol Tambah Note
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Menunggu hasil dari NoteFormPage
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormPage()),
          );
          // Jika ada data baru disimpan, refresh list
          if (result == true) _refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('Belum ada catatan.'))
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: _notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Menampilkan 2 kolom
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, i) {
                  final n = _notes[i];

                  // Menggunakan fungsi warna berdasarkan deadline dari note.dart
                  final color = noteColorByDeadline(n.deadline);

                  final deadlineText = n.deadline == null
                      ? 'Non-priority'
                      : DateFormat('dd MMM yyyy').format(n.deadline!);

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.up, // Swipe ke atas untuk hapus
                    onDismissed: (_) async {
                      if (n.id != null) {
                        await NoteDb.instance.delete(n.id!);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Catatan dihapus')),
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () async {
                        // Navigasi ke halaman edit
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteFormPage(note: n),
                          ),
                        );
                        if (result == true) _refreshNotes();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: color,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  n.content,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              Text(
                                deadlineText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}