import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

// ---Patient Info State---
class PatientInfo {
  final String name;
  final String age;
  final String gender;

  PatientInfo({this.name = '', this.age = '', this.gender = ''});

  PatientInfo copyWith({String? name, String? age, String? gender}) {
    return PatientInfo(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
}

final patientInfoProvider = StateProvider<PatientInfo>((ref) => PatientInfo());

// ---Introduction State---
class IntroductionData {
  final String origin;
  final String maritalStatus;
  final String profession;
  final String admissionDate;
  final String signs;

  IntroductionData({
    this.origin = '',
    this.maritalStatus = '',
    this.profession = '',
    this.admissionDate = '',
    this.signs = '',
  });

  IntroductionData copyWith({
    String? origin,
    String? maritalStatus,
    String? profession,
    String? admissionDate,
    String? signs,
  }) {
    return IntroductionData(
      origin: origin ?? this.origin,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      profession: profession ?? this.profession,
      admissionDate: admissionDate ?? this.admissionDate,
      signs: signs ?? this.signs,
    );
  }
}

final introductionDataProvider = StateProvider<IntroductionData>(
  (ref) => IntroductionData(),
);

// ---Motif d'hospitalisation State---
final motifHospitalisationProvider = StateProvider<String>((ref) => '');

// ---Histoire de la maladie State---
final histoireMaladieProvider = StateProvider<String>((ref) => '');

// ---Antécédents State---
class Antecedents {
  final String medicaux;
  final String chirurgicaux;
  final String familiaux;
  final String gynecoObstetriques;
  final String modeDeVie;

  Antecedents({
    this.medicaux = '',
    this.chirurgicaux = '',
    this.familiaux = '',
    this.gynecoObstetriques = '',
    this.modeDeVie = '',
  });

  Antecedents copyWith({
    String? medicaux,
    String? chirurgicaux,
    String? familiaux,
    String? gynecoObstetriques,
    String? modeDeVie,
  }) {
    return Antecedents(
      medicaux: medicaux ?? this.medicaux,
      chirurgicaux: chirurgicaux ?? this.chirurgicaux,
      familiaux: familiaux ?? this.familiaux,
      gynecoObstetriques: gynecoObstetriques ?? this.gynecoObstetriques,
      modeDeVie: modeDeVie ?? this.modeDeVie,
    );
  }
}

final antecedentsProvider = StateProvider<Antecedents>((ref) => Antecedents());

// ---Vitals State---
class Vitals {
  final String bloodPressure;
  final String heartRate;
  final String temperature;
  final String respiratoryRate;
  final String oxygenSaturation;
  final String weight;

  Vitals({
    this.bloodPressure = '',
    this.heartRate = '',
    this.temperature = '',
    this.respiratoryRate = '',
    this.oxygenSaturation = '',
    this.weight = '',
  });

  Vitals copyWith({
    String? bloodPressure,
    String? heartRate,
    String? temperature,
    String? respiratoryRate,
    String? oxygenSaturation,
    String? weight,
  }) {
    return Vitals(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      weight: weight ?? this.weight,
    );
  }
}

final vitalsProvider = StateProvider<Vitals>((ref) => Vitals());

// ---Symptoms State---
final selectedSymptomsProvider = StateProvider<Set<String>>((ref) => {});

// ---Physical Examination State---
final physicalExamProvider = StateProvider<Map<String, String>>((ref) => {});

//User-defined physical exam sections
final customPhysicalExamFieldsProvider = StateProvider<List<ExamFieldConfig>>(
  (ref) => [],
);

// ---Assessment&Plan State---
final assessmentAndPlanProvider = StateProvider<String>((ref) => '');

// ---Examens Complémentaires(Paraclinique)State---
class ExamParameter {
  final String key;
  final String name;
  final String value;

  ExamParameter({required this.key, required this.name, this.value = ''});

  ExamParameter copyWith({String? key, String? name, String? value}) {
    return ExamParameter(
      key: key ?? this.key,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

class ParaclinicalExam {
  final String title;
  final List<ExamParameter> parameters;

  ParaclinicalExam({required this.title, required this.parameters});

  ParaclinicalExam copyWith({String? title, List<ExamParameter>? parameters}) {
    return ParaclinicalExam(
      title: title ?? this.title,
      parameters: parameters ?? this.parameters,
    );
  }
}

final paracliniqueExamsProvider = StateProvider<List<ParaclinicalExam>>(
  (ref) => [],
);

// ---RésuméSyndromique/Au Total State---
final resumeTotalProvider = StateProvider<String>((ref) => '');

// ---Form Reset Action---
void resetObservationReport(dynamic ref) {
  ref.read(patientInfoProvider.notifier).state = PatientInfo();
  ref.read(introductionDataProvider.notifier).state = IntroductionData();
  ref.read(motifHospitalisationProvider.notifier).state = '';
  ref.read(histoireMaladieProvider.notifier).state = '';
  ref.read(antecedentsProvider.notifier).state = Antecedents();
  ref.read(vitalsProvider.notifier).state = Vitals();
  ref.read(selectedSymptomsProvider.notifier).state = {};
  ref.read(physicalExamProvider.notifier).state = {};
  ref.read(customPhysicalExamFieldsProvider.notifier).state = [];
  ref.read(paracliniqueExamsProvider.notifier).state = [];
  ref.read(resumeTotalProvider.notifier).state = '';
  ref.read(assessmentAndPlanProvider.notifier).state = '';
  ref.read(activeQuillControllerProvider.notifier).state = null;
  ref.read(activeObservationIdProvider.notifier).state = null;
}

final activeObservationIdProvider = StateProvider<int?>((ref) => null);

// ---Active Quill Controller for Shared Toolbar---
final activeQuillControllerProvider = StateProvider<QuillController?>(
  (ref) => null,
);
