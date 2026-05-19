class ResourceLinks {
  final Map<int, Map<int, String>> driveLinks; //StudyYear->AcademicYear->URL
  final Map<int, Map<int, String>> telegramLinks; //StudyYear->AcademicYear->URL

  const ResourceLinks({required this.driveLinks, required this.telegramLinks});

  //Example pattern implementation
  static ResourceLinks generatePlaceholderResources() {
    final Map<int, Map<int, String>> drive = {};
    final Map<int, Map<int, String>> telegram = {};

    for (int studyYear = 1; studyYear <= 7; studyYear++) {
      drive[studyYear] = {};
      telegram[studyYear] = {};

      //Academic years from 2017 to 2025(start year)
      for (int acadYear = 2017; acadYear <= 2025; acadYear++) {
        drive[studyYear]![acadYear] =
            "https://drive.google.com/drive/folders/placeholder_study${studyYear}_acad$acadYear";
        telegram[studyYear]![acadYear] =
            "https://t.me/placeholder_study${studyYear}_acad$acadYear";
      }
    }

    return ResourceLinks(driveLinks: drive, telegramLinks: telegram);
  }

  static final ResourceLinks algerianMedicalResources =
      generatePlaceholderResources();
}
