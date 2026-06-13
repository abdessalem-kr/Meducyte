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

// ---Examens Complémentaires (Paraclinique) State---
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

// ---Unified Observation Report State---
class ObservationReportState {
  final PatientInfo patientInfo;
  final IntroductionData introductionData;
  final String motifHospitalisation;
  final String histoireMaladie;
  final Antecedents antecedents;
  final Vitals vitals;
  final Set<String> selectedSymptoms;
  final Map<String, String> physicalExam;
  final List<ExamFieldConfig> customPhysicalExamFields;
  final String assessmentAndPlan;
  final List<ParaclinicalExam> paracliniqueExams;
  final String resumeTotal;
  final int? activeObservationId;
  final Map<String, String> examChecklist;

  ObservationReportState({
    required this.patientInfo,
    required this.introductionData,
    required this.motifHospitalisation,
    required this.histoireMaladie,
    required this.antecedents,
    required this.vitals,
    required this.selectedSymptoms,
    required this.physicalExam,
    required this.customPhysicalExamFields,
    required this.assessmentAndPlan,
    required this.paracliniqueExams,
    required this.resumeTotal,
    this.activeObservationId,
    required this.examChecklist,
  });

  factory ObservationReportState.initial() => ObservationReportState(
        patientInfo: PatientInfo(),
        introductionData: IntroductionData(),
        motifHospitalisation: '',
        histoireMaladie: '',
        antecedents: Antecedents(),
        vitals: Vitals(),
        selectedSymptoms: {},
        physicalExam: {},
        customPhysicalExamFields: [],
        assessmentAndPlan: '',
        paracliniqueExams: [],
        resumeTotal: '',
        activeObservationId: null,
        examChecklist: {},
      );

  ObservationReportState copyWith({
    PatientInfo? patientInfo,
    IntroductionData? introductionData,
    String? motifHospitalisation,
    String? histoireMaladie,
    Antecedents? antecedents,
    Vitals? vitals,
    Set<String>? selectedSymptoms,
    Map<String, String>? physicalExam,
    List<ExamFieldConfig>? customPhysicalExamFields,
    String? assessmentAndPlan,
    List<ParaclinicalExam>? paracliniqueExams,
    String? resumeTotal,
    int? activeObservationId,
    Map<String, String>? examChecklist,
  }) {
    return ObservationReportState(
      patientInfo: patientInfo ?? this.patientInfo,
      introductionData: introductionData ?? this.introductionData,
      motifHospitalisation: motifHospitalisation ?? this.motifHospitalisation,
      histoireMaladie: histoireMaladie ?? this.histoireMaladie,
      antecedents: antecedents ?? this.antecedents,
      vitals: vitals ?? this.vitals,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      physicalExam: physicalExam ?? this.physicalExam,
      customPhysicalExamFields: customPhysicalExamFields ?? this.customPhysicalExamFields,
      assessmentAndPlan: assessmentAndPlan ?? this.assessmentAndPlan,
      paracliniqueExams: paracliniqueExams ?? this.paracliniqueExams,
      resumeTotal: resumeTotal ?? this.resumeTotal,
      activeObservationId: activeObservationId ?? this.activeObservationId,
      examChecklist: examChecklist ?? this.examChecklist,
    );
  }
}

class ObservationReportNotifier extends Notifier<ObservationReportState> {
  @override
  ObservationReportState build() {
    return ObservationReportState.initial();
  }

  void updatePatientInfo(PatientInfo patientInfo) {
    state = state.copyWith(patientInfo: patientInfo);
  }

  void updateIntroductionData(IntroductionData introductionData) {
    state = state.copyWith(introductionData: introductionData);
  }

  void updateMotifHospitalisation(String val) {
    state = state.copyWith(motifHospitalisation: val);
  }

  void updateHistoireMaladie(String val) {
    state = state.copyWith(histoireMaladie: val);
  }

  void updateAntecedents(Antecedents antecedents) {
    state = state.copyWith(antecedents: antecedents);
  }

  void updateVitals(Vitals vitals) {
    state = state.copyWith(vitals: vitals);
  }

  void updateSelectedSymptoms(Set<String> selectedSymptoms) {
    state = state.copyWith(selectedSymptoms: selectedSymptoms);
  }

  void updatePhysicalExam(Map<String, String> physicalExam) {
    state = state.copyWith(physicalExam: physicalExam);
  }

  void updateCustomPhysicalExamFields(List<ExamFieldConfig> customPhysicalExamFields) {
    state = state.copyWith(customPhysicalExamFields: customPhysicalExamFields);
  }

  void updateAssessmentAndPlan(String val) {
    state = state.copyWith(assessmentAndPlan: val);
  }

  void updateParacliniqueExams(List<ParaclinicalExam> paracliniqueExams) {
    state = state.copyWith(paracliniqueExams: paracliniqueExams);
  }

  void updateResumeTotal(String val) {
    state = state.copyWith(resumeTotal: val);
  }

  void updateActiveObservationId(int? id) {
    state = state.copyWith(activeObservationId: id);
  }

  void updateExamChecklist(Map<String, String> checklist) {
    state = state.copyWith(examChecklist: checklist);
  }

  void reset() {
    state = ObservationReportState.initial();
    ref.read(activeQuillControllerProvider.notifier).state = null;
    ref.read(focusRequestProvider.notifier).state = null;
  }
}

final observationReportProvider = NotifierProvider<ObservationReportNotifier, ObservationReportState>(
  () => ObservationReportNotifier(),
);

// ---Selector Providers for Reading (Backward Compatibility)---
final patientInfoProvider = Provider<PatientInfo>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.patientInfo));
});

final introductionDataProvider = Provider<IntroductionData>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.introductionData));
});

final motifHospitalisationProvider = Provider<String>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.motifHospitalisation));
});

final histoireMaladieProvider = Provider<String>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.histoireMaladie));
});

final antecedentsProvider = Provider<Antecedents>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.antecedents));
});

final vitalsProvider = Provider<Vitals>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.vitals));
});

final selectedSymptomsProvider = Provider<Set<String>>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.selectedSymptoms));
});

final physicalExamProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.physicalExam));
});

final customPhysicalExamFieldsProvider = Provider<List<ExamFieldConfig>>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.customPhysicalExamFields));
});

final assessmentAndPlanProvider = Provider<String>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.assessmentAndPlan));
});

final paracliniqueExamsProvider = Provider<List<ParaclinicalExam>>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.paracliniqueExams));
});

final resumeTotalProvider = Provider<String>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.resumeTotal));
});

final activeObservationIdProvider = Provider<int?>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.activeObservationId));
});

final examChecklistProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(observationReportProvider.select((s) => s.examChecklist));
});

// ---Form Reset Action---
void resetObservationReport(dynamic ref) {
  ref.read(observationReportProvider.notifier).reset();
}

// ---Transient/UI States remain as StateProviders---
final activeQuillControllerProvider = StateProvider<QuillController?>((ref) => null);
final focusRequestProvider = StateProvider<String?>((ref) => null);
