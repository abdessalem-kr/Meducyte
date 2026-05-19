import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:meducyte_app/features/observation/data/providers/observation_providers.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

final observationRepositoryProvider = Provider((ref) {
  final db = ref.watch(
    appDatabaseProvider,
  ); //Assuming appDatabaseProvider exists
  return ObservationRepository(db, ref);
});

class ObservationRepository {
  final AppDatabase _db;
  final Ref _ref;

  ObservationRepository(this._db, this._ref);

  Future<int> saveCurrentReport(String specialtyKey) async {
    final patient = _ref.read(patientInfoProvider);
    final examFields = _ref.read(customPhysicalExamFieldsProvider);

    final contentMap = {
      'patient': {
        'name': patient.name,
        'age': patient.age,
        'gender': patient.gender,
      },
      'introduction': {
        'origin': _ref.read(introductionDataProvider).origin,
        'maritalStatus': _ref.read(introductionDataProvider).maritalStatus,
        'profession': _ref.read(introductionDataProvider).profession,
        'admissionDate': _ref.read(introductionDataProvider).admissionDate,
        'signs': _ref.read(introductionDataProvider).signs,
      },
      'motif': _ref.read(motifHospitalisationProvider),
      'histoire': _ref.read(histoireMaladieProvider),
      'antecedents': {
        'medicaux': _ref.read(antecedentsProvider).medicaux,
        'chirurgicaux': _ref.read(antecedentsProvider).chirurgicaux,
        'familiaux': _ref.read(antecedentsProvider).familiaux,
        'gyneco': _ref.read(antecedentsProvider).gynecoObstetriques,
        'modeDeVie': _ref.read(antecedentsProvider).modeDeVie,
      },
      'vitals': {
        'temp': _ref.read(vitalsProvider).temperature,
        'bp': _ref.read(vitalsProvider).bloodPressure,
        'hr': _ref.read(vitalsProvider).heartRate,
        'rr': _ref.read(vitalsProvider).respiratoryRate,
        'spo2': _ref.read(vitalsProvider).oxygenSaturation,
        'weight': _ref.read(vitalsProvider).weight,
      },
      'physicalExam': _ref.read(physicalExamProvider),
      'customFields': examFields
          .map(
            (f) => {'key': f.key, 'label': f.label, 'normalText': f.normalText},
          )
          .toList(),
      'paraclinical': _ref
          .read(paracliniqueExamsProvider)
          .map(
            (e) => {
              'title': e.title,
              'parameters': e.parameters
                  .map((p) => {'key': p.key, 'name': p.name, 'value': p.value})
                  .toList(),
            },
          )
          .toList(),
      'resume': _ref.read(resumeTotalProvider),
      'assessment': _ref.read(assessmentAndPlanProvider),
    };

    final jsonContent = jsonEncode(contentMap);
    final existingId = _ref.read(activeObservationIdProvider);

    if (existingId != null) {
      await _db.updateObservation(existingId, patient.name, jsonContent);
      return existingId;
    } else {
      final newId = await _db.insertObservation(
        patient.name,
        specialtyKey,
        jsonContent,
      );
      _ref.read(activeObservationIdProvider.notifier).state = newId;
      return newId;
    }
  }

  Future<void> loadReport(DbSavedObservation report) async {
    final data = jsonDecode(report.contentJson) as Map<String, dynamic>;

    //Reset first
    resetObservationReport(_ref);

    //Load pieces
    if (data.containsKey('patient')) {
      final p = data['patient'];
      _ref.read(patientInfoProvider.notifier).state = PatientInfo(
        name: p['name'] ?? '',
        age: p['age'] ?? '',
        gender: p['gender'] ?? '',
      );
    }

    if (data.containsKey('introduction')) {
      final intro = data['introduction'];
      if (intro is Map) {
        _ref.read(introductionDataProvider.notifier).state = IntroductionData(
          origin: intro['origin'] ?? '',
          maritalStatus: intro['maritalStatus'] ?? '',
          profession: intro['profession'] ?? '',
          admissionDate: intro['admissionDate'] ?? '',
          signs: intro['signs'] ?? '',
        );
      } else {
        //Fallback for old simple string data if any
        _ref.read(introductionDataProvider.notifier).state = IntroductionData(
          signs: intro?.toString() ?? '',
        );
      }
    }
    if (data.containsKey('motif')) {
      _ref.read(motifHospitalisationProvider.notifier).state =
          data['motif'] ?? '';
    }

    if (data.containsKey('histoire')) {
      _ref.read(histoireMaladieProvider.notifier).state =
          data['histoire'] ?? '';
    }

    if (data.containsKey('antecedents')) {
      final a = data['antecedents'];
      _ref.read(antecedentsProvider.notifier).state = Antecedents(
        medicaux: a['medicaux'] ?? '',
        chirurgicaux: a['chirurgicaux'] ?? '',
        familiaux: a['familiaux'] ?? '',
        gynecoObstetriques: a['gyneco'] ?? '',
        modeDeVie: a['modeDeVie'] ?? '',
      );
    }

    if (data.containsKey('vitals')) {
      final v = data['vitals'];
      _ref.read(vitalsProvider.notifier).state = Vitals(
        temperature: v['temp'] ?? '',
        bloodPressure: v['bp'] ?? '',
        heartRate: v['hr'] ?? '',
        respiratoryRate: v['rr'] ?? '',
        oxygenSaturation: v['spo2'] ?? '',
        weight: v['weight'] ?? '',
      );
    }

    if (data.containsKey('physicalExam')) {
      _ref.read(physicalExamProvider.notifier).state = Map<String, String>.from(
        data['physicalExam'],
      );
    }

    if (data.containsKey('customFields')) {
      final fields = (data['customFields'] as List)
          .map(
            (f) => ExamFieldConfig(
              key: f['key'],
              label: f['label'],
              normalText: f['normalText'],
            ),
          )
          .toList();
      _ref.read(customPhysicalExamFieldsProvider.notifier).state = fields;
    }

    if (data.containsKey('paraclinical')) {
      final exams = (data['paraclinical'] as List)
          .map(
            (e) => ParaclinicalExam(
              title: e['title'],
              parameters: (e['parameters'] as List)
                  .map(
                    (p) => ExamParameter(
                      key: p['key'],
                      name: p['name'],
                      value: p['value'],
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
      _ref.read(paracliniqueExamsProvider.notifier).state = exams;
    }

    if (data.containsKey('resume')) {
      _ref.read(resumeTotalProvider.notifier).state = data['resume'] ?? '';
    }

    if (data.containsKey('assessment')) {
      _ref.read(assessmentAndPlanProvider.notifier).state =
          data['assessment'] ?? '';
    }

    //Set the active ID so auto-save updates this entry instead of creating a new one
    _ref.read(activeObservationIdProvider.notifier).state = report.id;
  }

  Future<List<DbSavedObservation>> getAllReports() => _db.getAllObservations();

  Future<void> deleteReport(int id) => _db.deleteObservation(id);
}
