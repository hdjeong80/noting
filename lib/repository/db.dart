import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'app_data.dart';

class NotingDatabase {
  Database _db;
  NoteRepository repo;
  var _dir;
  var _dbPath;

  Future<void> openDatabase() async {
    // get the application documents directory
    _dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await _dir.create(recursive: true);
    // build the database path
    _dbPath = join(_dir.path, 'notingDatabase.db');
    // open the database
    _db = await databaseFactoryIo.openDatabase(_dbPath);
    if (gisDatabaseLoaded) {
      print('registered');
    } else {
      print('new');
      gisDatabaseLoaded = true;
      GetIt.I.registerSingleton<Database>(_db);
      GetIt.I
          .registerLazySingleton<NoteRepository>(() => SembastNoteRepository());
    }
    repo = GetIt.I.get();

    gNotesSnapshot = await gNotingDatabase.repo.getAllNotes();
  }

  loadNotes() async {
    final notes = await repo.getAllNotes();
    gNotesSnapshot = notes;

    // setState(() => gNotesSnapshot = notes);
  }

  addNewNote() async {
    await repo.insertNote(NoteModel(
      createTime: DateFormat('yyyy.MM.dd').format(DateTime.now()),
      recentUpdateTime: DateFormat('yyyy.MM.dd').format(DateTime.now()),
      text: '',
    ));
    loadNotes();
    // Future.wait([
    //   loadNotes(),
    // ] as Iterable<Future>)
    //     .then((value) => gCurrentNote = gNotesSnapshot.last);
    Future.delayed(Duration(milliseconds: 100))
        .then((value) => gCurrentNote = gNotesSnapshot.last);

    // return newNote;
  }

  deleteNote(NoteModel note) async {
    await repo.deleteNote(note.id);
    loadNotes();
  }

  editNote(
      {NoteModel oldNote,
      String text,
      List<MapEntry<Path, Paint>> draw}) async {
    repo.updateNote(oldNote.copyWith(
        text: text,
        draw: draw,
        recentUpdateTime: DateFormat('yyyy.MM.dd').format(DateTime.now())));
  }
}

class SembastNoteRepository extends NoteRepository {
  final Database _database = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("note_store");

  @override
  Future<int> insertNote(NoteModel note) async {
    return await _store.add(_database, note.toMap());
  }

  @override
  Future updateNote(NoteModel note) async {
    await _store.record(note.id).update(_database, note.toMap());
  }

  @override
  Future deleteNote(int noteId) async {
    await _store.record(noteId).delete(_database);
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final snapshots = await _store.find(_database);
    return snapshots
        .map((snapshot) => NoteModel.fromMap(snapshot.key, snapshot.value))
        .toList(growable: false);
  }
}

abstract class NoteRepository {
  Future<int> insertNote(NoteModel note);

  Future updateNote(NoteModel note);

  Future deleteNote(int noteId);

  Future<List<NoteModel>> getAllNotes();
}

class NoteModel {
  final int id;
  final String createTime;
  String recentUpdateTime;
  String text;
  List<MapEntry<Path, Paint>> draw;

  NoteModel(
      {this.id, this.createTime, this.recentUpdateTime, this.text, this.draw});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'createTime': this.createTime,
      'recentUpdateTime': this.recentUpdateTime,
      'text': this.text,
      'draw': this.draw,
    };
  }

  factory NoteModel.fromMap(int id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      createTime: map['createTime'],
      recentUpdateTime: map['recentUpdateTime'],
      text: map['text'],
      draw: map['draw'],
    );
  }

  NoteModel copyWith(
      {int id,
      String createTime,
      String recentUpdateTime,
      String text,
      List<MapEntry<Path, Paint>> draw}) {
    return NoteModel(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      recentUpdateTime: recentUpdateTime ?? this.recentUpdateTime,
      text: text ?? this.text,
      draw: draw ?? this.draw,
    );
  }
}
