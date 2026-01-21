import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'note.dart';
import 'note_db.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;
  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _contentC = TextEditingController();

  DateTime? _deadline;

  bool get _isEdit => widget.note != null;

  // FUNGSI BARU: Menentukan warna box preview berdasarkan deadline
  Color _getPreviewColor() {
    if (_deadline == null) return Colors.grey.shade300;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = _deadline!.difference(today).inDays;

    if (diff < 0) return Colors.red.shade300; // Terlewat
    if (diff <= 3) return Colors.orange.shade300; // Mendekati (3 hari)
    return Colors.green.shade300; // Masih lama
  }

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    if (n != null) {
      _titleC.text = n.title;
      _contentC.text = n.content;
      _deadline = n.deadline;
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _contentC.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final init = _deadline ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _clearDeadline() {
    setState(() => _deadline = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id,
      title: _titleC.text.trim(),
      content: _contentC.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      deadline: _deadline,
    );

    if (_isEdit) {
      await NoteDb.instance.update(note.id!, note.toMap());
    } else {
      await NoteDb.instance.insert(note.toMap());
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      true,
    ); // Tambahkan true agar halaman sebelumnya tahu ada perubahan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Note' : 'Tambah Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // PERBAIKAN: Warna container sekarang dinamis
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPreviewColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Preview Prioritas Catatan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _deadline == null
                          ? 'Tanpa Deadline (Normal)'
                          : 'Deadline: ${DateFormat('dd MMMM yyyy').format(_deadline!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentC,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 4,
                maxLines: 8,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Isi tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDeadline,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Pilih Deadline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_deadline !=
                      null) // Tampilkan tombol hapus hanya jika ada deadline
                    IconButton.filledTonal(
                      onPressed: _clearDeadline,
                      icon: const Icon(Icons.delete_sweep),
                      color: Colors.red,
                    ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isEdit ? 'PERBARUI CATATAN' : 'SIMPAN CATATAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}