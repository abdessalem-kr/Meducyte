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
