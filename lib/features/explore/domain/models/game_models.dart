class AnatomyQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? imagePath;
  final String category;

  const AnatomyQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.imagePath,
    this.category = 'Anatomy',
  });
}

class WordAssociationPair {
  final String id;
  final String word;
  final String relatedWord;
  final String logic;

  const WordAssociationPair({
    required this.id,
    required this.word,
    required this.relatedWord,
    required this.logic,
  });
}

class DiagnosisCase {
  final String id;
  final String patientProfile;
  final String symptoms;
  final List<String> findings;
  final List<String> options; //Diagnoses
  final int correctIndex;
  final String explanation;

  const DiagnosisCase({
    required this.id,
    required this.patientProfile,
    required this.symptoms,
    required this.findings,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class EcgStrip {
  final String id;
  final String imagePath;
  final String diagnosis;
  final List<String> options;
  final int correctIndex;
  final String keyFeature;

  const EcgStrip({
    required this.id,
    required this.imagePath,
    required this.diagnosis,
    required this.options,
    required this.correctIndex,
    required this.keyFeature,
  });
}

class PharmaPair {
  final String id;
  final String drug;
  final String drugClass;
  final String mechanism;

  const PharmaPair({
    required this.id,
    required this.drug,
    required this.drugClass,
    required this.mechanism,
  });
}

class LabResult {
  final String id;
  final String parameter; //e.g. "Potassium"
  final double value;
  final String unit;
  final double minNormal;
  final double maxNormal;
  final String interpretation;

  const LabResult({
    required this.id,
    required this.parameter,
    required this.value,
    required this.unit,
    required this.minNormal,
    required this.maxNormal,
    required this.interpretation,
  });
}

class SurgicalStep {
  final String id;
  final String instruction;
  final String tool;
  final int order;

  const SurgicalStep({
    required this.id,
    required this.instruction,
    required this.tool,
    required this.order,
  });
}

class CrosswordGame {
  final String id;
  final String title;
  final List<CrosswordWord> words;

  const CrosswordGame({
    required this.id,
    required this.title,
    required this.words,
  });
}

class CrosswordWord {
  final String word;
  final String clue;
  final int row;
  final int col;
  final bool isHorizontal;

  const CrosswordWord({
    required this.word,
    required this.clue,
    required this.row,
    required this.col,
    required this.isHorizontal,
  });
}

class ClueOption {
  final String label;
  final String result;
  final int cost;

  const ClueOption({
    required this.label,
    required this.result,
    required this.cost,
  });
}

class CaseDetectiveCase {
  final String id;
  final String difficulty; // "Débutant", "Intermédiaire", "Avancé"
  final String patientDemographics;
  final String chiefComplaint;
  final String vitals;
  final List<ClueOption> historyOptions;
  final List<ClueOption> labOptions;
  final List<ClueOption> imagingOptions;
  final String correctDiagnosis;
  final List<String> differentials;
  final String teachingPoints;

  const CaseDetectiveCase({
    required this.id,
    required this.difficulty,
    required this.patientDemographics,
    required this.chiefComplaint,
    required this.vitals,
    required this.historyOptions,
    required this.labOptions,
    required this.imagingOptions,
    required this.correctDiagnosis,
    required this.differentials,
    required this.teachingPoints,
  });
}

class PhysiologyFlowCase {
  final String id;
  final String title;
  final String description;
  final List<String> correctSteps;
  final List<String> explanations;

  const PhysiologyFlowCase({
    required this.id,
    required this.title,
    required this.description,
    required this.correctSteps,
    required this.explanations,
  });
}
