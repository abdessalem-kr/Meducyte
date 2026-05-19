import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('DbChatSession')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DbChatMessage')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ChatSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DbMedicalTerm')
class MedicalTerms extends Table {
  @override
  String get tableName => 'terms';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get term => text()();
  TextColumn get spec => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get defn => text()();
}

@DataClassName('DbSavedObservation')
class SavedObservations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patientName => text().withLength(min: 0, max: 255)();
  TextColumn get specialty => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get contentJson => text()();
}

@DataClassName('DbQuestionReview')
class QuestionReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().unique()();
  IntColumn get box =>
      integer().withDefault(const Constant(1))(); //Leitner box 1-5
  DateTimeColumn get nextReview => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();
  IntColumn get repetitionCount => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval =>
      integer().withDefault(const Constant(0))(); //in days
}

@DataClassName('DbNotification')
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()(); //Firebase/Backend ID
  TextColumn get userId => text().nullable()(); //Associated user ID
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text()(); //enum logic
  TextColumn get data => text().nullable()(); //JSON data
}

@DataClassName('DbStudyEvent')
class StudyEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get color => text()();
  TextColumn get type => text()();
  BoolColumn get isAIPlaced => boolean().withDefault(const Constant(false))();
  TextColumn get relatedId => text().nullable()();
}

@DataClassName('DbWeeklyObjective')
class WeeklyObjectives extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStartDate => dateTime()();
  TextColumn get content => text()();
}

@DataClassName('DbModuleCache')
class ModuleCaches extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get dataJson => text()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ChatSessions,
    ChatMessages,
    MedicalTerms,
    SavedObservations,
    QuestionReviews,
    Notifications,
    StudyEvents,
    WeeklyObjectives,
    ModuleCaches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.createTable(medicalTerms);
      if (from < 3) {
        //Handle migration 2 to 3
      }
      if (from < 4) await m.createTable(savedObservations);
      if (from < 5) await m.createTable(questionReviews);
      if (from < 6) await m.createTable(notifications);
      if (from < 7) {
        await m.createTable(studyEvents);
        await m.createTable(weeklyObjectives);
      }
      if (from < 8) {
        await m.createTable(moduleCaches);
      }
      if (from < 9) {
        //Add userId column to notifications table
        await m.addColumn(notifications, notifications.userId);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meducyte_db');
  }

  // ---Observation History methods---
  Future<List<DbSavedObservation>> getAllObservations() => (select(
    savedObservations,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Future<int> insertObservation(
    String patientName,
    String specialty,
    String jsonContent,
  ) {
    return into(savedObservations).insert(
      SavedObservationsCompanion.insert(
        patientName: patientName,
        specialty: specialty,
        contentJson: jsonContent,
        date: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateObservation(
    int id,
    String patientName,
    String jsonContent,
  ) {
    return (update(savedObservations)..where((t) => t.id.equals(id))).write(
      SavedObservationsCompanion(
        patientName: Value(patientName),
        contentJson: Value(jsonContent),
        date: Value(DateTime.now()), //Update date to show"last modified"
      ),
    );
  }

  Future<void> deleteObservation(int id) =>
      (delete(savedObservations)..where((t) => t.id.equals(id))).go();

  Future<DbSavedObservation?> getObservationById(int id) => (select(
    savedObservations,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---Session DAO methods---
  Future<List<DbChatSession>> getAllSessions() => select(chatSessions).get();

  Future<int> createSession(String title) {
    return into(chatSessions).insert(
      ChatSessionsCompanion.insert(
        title: title,
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteSession(int id) =>
      (delete(chatSessions)..where((t) => t.id.equals(id))).go();

  // ---Message DAO methods---
  Future<List<DbChatMessage>> getMessagesForSession(int sessionId) {
    return (select(
      chatMessages,
    )..where((t) => t.sessionId.equals(sessionId))).get();
  }

  Future<int> insertMessage(int sessionId, String text, bool isUser) {
    return into(chatMessages).insert(
      ChatMessagesCompanion.insert(
        sessionId: sessionId,
        content: text,
        isUser: isUser,
        timestamp: Value(DateTime.now()),
      ),
    );
  }

  Future<int> getTotalUserMessageCount() async {
    final countExp = chatMessages.id.count();
    final query = selectOnly(chatMessages)
      ..where(chatMessages.isUser.equals(true))
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  // ---Medical Dictionary DAO methods---
  Future<List<DbMedicalTerm>> searchMedicalTerms(
    String query, {
    int limit = 100,
    int offset = 0,
    String? specialty,
    bool sortAscending = true,
    bool isTermView = true,
  }) {
    final selectQuery = select(medicalTerms);

    if (query.isNotEmpty) {
      final search = '%$query%';
      selectQuery.where(
        (t) => t.term.like(search) | t.name.like(search) | t.defn.like(search),
      );
    }

    if (specialty != null && specialty.isNotEmpty) {
      selectQuery.where((t) => t.spec.equals(specialty));
    }

    if (isTermView) {
      selectQuery.where((t) {
        final hasAbbrevName =
            t.name.like('(Syn.%') |
            t.name.like('Syn.%') |
            t.name.like('(Abrév.%') |
            t.name.like('Abrév.%') |
            t.name.like('(Abrev.%') |
            t.name.like('Abrev.%');

        final hasAbbrevDefn =
            t.defn.like('(Syn.%') |
            t.defn.like('Syn.%') |
            t.defn.like('(Abrév.%') |
            t.defn.like('Abrév.%') |
            t.defn.like('(Abrev.%') |
            t.defn.like('Abrev.%');

        return hasAbbrevDefn.not() & (t.name.isNull() | hasAbbrevName.not());
      });
    } else {
      selectQuery.where((t) {
        final hasAbbrevName =
            t.name.like('(Syn.%') |
            t.name.like('Syn.%') |
            t.name.like('(Abrév.%') |
            t.name.like('Abrév.%') |
            t.name.like('(Abrev.%') |
            t.name.like('Abrev.%');

        final hasAbbrevDefn =
            t.defn.like('(Syn.%') |
            t.defn.like('Syn.%') |
            t.defn.like('(Abrév.%') |
            t.defn.like('Abrév.%') |
            t.defn.like('(Abrev.%') |
            t.defn.like('Abrev.%');

        return hasAbbrevDefn | (t.name.isNotNull() & hasAbbrevName);
      });
    }

    selectQuery.orderBy([
      (t) =>
          sortAscending ? OrderingTerm.asc(t.term) : OrderingTerm.desc(t.term),
    ]);

    return (selectQuery..limit(limit, offset: offset)).get();
  }

  Future<List<String>> getMedicalSpecialties() async {
    final query = selectOnly(medicalTerms, distinct: true)
      ..addColumns([medicalTerms.spec]);
    final result = await query.map((row) => row.read(medicalTerms.spec)).get();
    return result.whereType<String>().where((s) => s.isNotEmpty).toList()
      ..sort();
  }

  Future<int> getMedicalTermsCount() async {
    final countExp = medicalTerms.id.count();
    final query = selectOnly(medicalTerms)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<void> insertMedicalTermsBatch(
    List<MedicalTermsCompanion> terms,
  ) async {
    await batch((batch) {
      batch.insertAll(medicalTerms, terms);
    });
  }

  Future<void> importDataFromAssetDatabase(String sourcePath) async {
    //ATTACH DATABASE cannot be executed within a transaction.
    await customStatement("ATTACH DATABASE'$sourcePath'AS asset_db");
    try {
      //We use INSERT OR IGNORE just in case,though it should be empty
      await customStatement(
        "INSERT OR IGNORE INTO terms(id,term,spec,name,defn)SELECT id,term,spec,name,defn FROM asset_db.terms",
      );
    } finally {
      await customStatement("DETACH DATABASE asset_db");
    }
  }

  // ---Spaced Repetition(SRS)Methods---
  Future<List<DbQuestionReview>> getDueQuestions() {
    return (select(questionReviews)
          ..where(
            (t) => t.nextReview.isSmallerOrEqual(Variable(DateTime.now())),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextReview)]))
        .get();
  }

  Future<int> upsertQuestionReview(QuestionReviewsCompanion review) {
    return into(questionReviews).insert(
      review,
      onConflict: DoUpdate(
        (old) => review,
        target: [questionReviews.questionId],
      ),
    );
  }

  Future<DbQuestionReview?> getReviewByQuestionId(int questionId) {
    return (select(
      questionReviews,
    )..where((t) => t.questionId.equals(questionId))).getSingleOrNull();
  }

  Future<void> deleteReview(int questionId) {
    return (delete(
      questionReviews,
    )..where((t) => t.questionId.equals(questionId))).go();
  }

  Future<List<DbQuestionReview>> getAllReviews() =>
      select(questionReviews).get();

  Future<void> deleteAllReviews() => delete(questionReviews).go();

  // ---Notification methods---
  Future<List<DbNotification>> getAllNotifications(String? userId) =>
      (select(notifications)
            ..where(
              (t) => userId != null
                  ? t.userId.equals(userId)
                  : const Constant(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
          .get();

  Stream<List<DbNotification>> watchNotifications(String? userId) =>
      (select(notifications)
            ..where(
              (t) => userId != null
                  ? t.userId.equals(userId)
                  : const Constant(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
          .watch();

  Future<int> insertNotification(NotificationsCompanion companion) =>
      into(notifications).insert(companion);

  Future<void> updateNotificationReadStatus(int id, bool isRead) =>
      (update(notifications)..where((t) => t.id.equals(id))).write(
        NotificationsCompanion(isRead: Value(isRead)),
      );

  Future<void> markAllNotificationsAsRead(
    String? userId, {
    bool isRead = true,
  }) =>
      (update(notifications)..where(
            (t) =>
                userId != null ? t.userId.equals(userId) : const Constant(true),
          ))
          .write(NotificationsCompanion(isRead: Value(isRead)));

  Future<void> deleteNotification(int id) =>
      (delete(notifications)..where((t) => t.id.equals(id))).go();

  Future<DbNotification?> getNotificationById(int id) =>
      (select(notifications)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> clearAllNotifications(String? userId) =>
      (delete(notifications)..where(
            (t) =>
                userId != null ? t.userId.equals(userId) : const Constant(true),
          ))
          .go();

  // ---Study Calendar methods---
  Future<List<DbStudyEvent>> getAllStudyEvents() => select(studyEvents).get();

  Future<int> insertStudyEvent(StudyEventsCompanion companion) =>
      into(studyEvents).insert(companion);

  Future<void> deleteStudyEvent(int id) =>
      (delete(studyEvents)..where((t) => t.id.equals(id))).go();

  Future<void> updateStudyEvent(int id, StudyEventsCompanion companion) =>
      (update(studyEvents)..where((t) => t.id.equals(id))).write(companion);

  Future<List<DbWeeklyObjective>> getObjectivesForWeek(DateTime weekStart) {
    return (select(
      weeklyObjectives,
    )..where((t) => t.weekStartDate.equals(weekStart))).get();
  }

  Future<int> insertWeeklyObjective(WeeklyObjectivesCompanion companion) =>
      into(weeklyObjectives).insert(companion);

  Future<void> clearObjectivesForWeek(DateTime weekStart) => (delete(
    weeklyObjectives,
  )..where((t) => t.weekStartDate.equals(weekStart))).go();

  // ---Module Cache methods---
  Future<void> saveModulesCache(String json) async {
    await into(moduleCaches).insert(
      ModuleCachesCompanion(
        id: const Value(1),
        dataJson: Value(json),
        lastUpdated: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<String?> getModulesCache() async {
    final result = await (select(
      moduleCaches,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return result?.dataJson;
  }
}
