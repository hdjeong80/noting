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
    } else {
      print('database loaded');
      gisDatabaseLoaded = true;
      GetIt.I.registerSingleton<Database>(_db);
      GetIt.I
          .registerLazySingleton<NoteRepository>(() => SembastNoteRepository());
    }
    repo = GetIt.I.get();

    gNotesSnapshot = await gNotingDatabase.repo.getAllNotes();
    // if (gNotesSnapshot == null) {
    //   gNotesSnapshot = <NoteModel>[];
    // }
  }

  Future<bool> loadNotes() async {
    await repo.getAllNotes().then((value) {
      if (value == null) {
        print('loadNotes Fail');
        return false;
      } else {
        gNotesSnapshot = value;

        return true;
      }
    });
  }

  addNewNote() async {
    print('add note');
    await repo.insertNote(NoteModel(
      createTime: DateFormat('yyyy.MM.dd(hh.mm.ss)').format(DateTime.now()),
      recentUpdateTime:
          DateFormat('yyyy.MM.dd(hh.mm.ss)').format(DateTime.now()),
      text: '',
      textSize: ConfigConst.textSizeMin,
      textColorCode: 0xff000000,
      draw: '',
      bgPath: '',
      bgColor: 0xffffffff,
    ));
    loadNotes();
    // Future.wait([
    //   loadNotes(),
    // ] as Iterable<Future>)
    //     .then((value) => gCurrentNote = gNotesSnapshot.last);
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      gCurrentNote = gNotesSnapshot.last;
    });

    // return newNote;
  }

  deleteNote(NoteModel note) async {
    await repo.deleteNote(note.id);
    loadNotes();
  }

  editNote({
    NoteModel oldNote,
    String text,
    double textSize,
    int textColorCode,
    String draw,
    String bgPath,
    int bgColor,
  }) async {
    // map to datas

    repo.updateNote(oldNote.copyWith(
        text: text,
        textSize: textSize,
        textColorCode: textColorCode,
        draw: draw,
        bgPath: bgPath,
        bgColor: bgColor,
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
  double textSize;
  int textColorCode;
  String draw;
  String bgPath;
  int bgColor;

  NoteModel({
    this.id,
    this.createTime,
    this.recentUpdateTime,
    this.text,
    this.textSize,
    this.textColorCode,
    this.draw,
    this.bgPath,
    this.bgColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'createTime': this.createTime,
      'recentUpdateTime': this.recentUpdateTime,
      'text': this.text,
      'textSize': this.textSize,
      'textColorCode': this.textColorCode,
      'draw': this.draw,
      'bgPath': this.bgPath,
      'bgColor': this.bgColor,
    };
  }

  factory NoteModel.fromMap(int id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      createTime: map['createTime'],
      recentUpdateTime: map['recentUpdateTime'],
      text: map['text'],
      textSize: map['textSize'],
      textColorCode: map['textColorCode'],
      draw: map['draw'],
      bgPath: map['bgPath'],
      bgColor: map['bgColor'],
    );
  }

  NoteModel copyWith({
    int id,
    String createTime,
    String recentUpdateTime,
    String text,
    double textSize,
    int textColorCode,
    String draw,
    String bgPath,
    int bgColor,
  }) {
    return NoteModel(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      recentUpdateTime: recentUpdateTime ?? this.recentUpdateTime,
      text: text ?? this.text,
      textSize: textSize ?? this.textSize,
      textColorCode: textColorCode ?? this.textColorCode,
      draw: draw ?? this.draw,
      bgPath: bgPath ?? this.bgPath,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}
