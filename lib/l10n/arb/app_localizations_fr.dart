// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get all => 'Tous';

  @override
  String get sortBy => 'Trier par';

  @override
  String get nameAZ => 'Nom (A-Z)';

  @override
  String get nameZA => 'Nom (Z-A)';

  @override
  String get genericAZ => 'Générique (A-Z)';

  @override
  String get genericZA => 'Générique (Z-A)';

  @override
  String get filters => 'Filtres';

  @override
  String get enrichedOnly => 'Enrichis seulement';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get noDrugsFound => 'Aucun médicament trouvé.';

  @override
  String get category => 'Catégorie';

  @override
  String get onBoardingTitle => 'Apprenez la médecine plus intelligemment';

  @override
  String get onBoardingDescription =>
      'Meducyte transforme votre étude avec des outils interactifs, des répétitions espacées et un véritable raisonnement clinique.';

  @override
  String get onBoardingConinueBtn => 'Continuer';

  @override
  String get searchHint => 'Rechercher médicaments, maladies...';

  @override
  String get search => 'Rechercher';

  @override
  String get inProgress => 'EN COURS';

  @override
  String get continueQuiz => 'Continuer le Quiz';

  @override
  String get quickAccess => 'Accès Rapide';

  @override
  String get quizTraining => 'Entraînement Quiz';

  @override
  String get drugDatabase => 'Base de Médicaments';

  @override
  String get drugInteractions => 'Interactions Médicamenteuses';

  @override
  String get clinicalGuidelines => 'Guides Cliniques';

  @override
  String get medicalAbbreviations => 'Abréviations Médicales';

  @override
  String get observationReport => 'Rapport d\'Observation';

  @override
  String get clinicalCases => 'Cas Cliniques';

  @override
  String get medicalCalculator => 'Calculateur Médical';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get goodMorning => 'Bon matin';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String noResultsFound(Object query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get statistics => 'Statistiques';

  @override
  String get medicalInsight => 'Aperçu Médical';

  @override
  String get refreshMemory => 'Rafraîchissez votre mémoire';

  @override
  String get readArticle => 'Lire l\'article';

  @override
  String get dailyGoal => 'Objectif Quotidien';

  @override
  String get activity => 'Activité';

  @override
  String get viewStats => 'Voir Stats';

  @override
  String get viewDetails => 'Détails';

  @override
  String get accuracy => 'Précision';

  @override
  String get previous => 'Précédent';

  @override
  String get verify => 'Vérifier';

  @override
  String get nextQuestion => 'Question Suivante';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get partiallyCorrect => 'Partiellement correct';

  @override
  String get explanation => 'Explication';

  @override
  String get reportError => 'Signaler une erreur';

  @override
  String get selectReason => 'Choisir un motif';

  @override
  String get reasonTypo => 'Faute de frappe / Orthographe';

  @override
  String get reasonInaccurate => 'Information inexacte';

  @override
  String get reasonMissing => 'Information manquante';

  @override
  String get reasonUnclearExplanation => 'Explication peu claire';

  @override
  String get reasonWrongAnswer => 'Mauvaise réponse correcte';

  @override
  String get reasonUnclear => 'Question/Options peu claires';

  @override
  String get reasonOther => 'Autre';

  @override
  String get otherDescription => 'Décrivez brièvement l\'erreur...';

  @override
  String get sendReport => 'Envoyer le rapport';

  @override
  String get reportSent => 'Signalement envoyé avec succès !';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get name => 'Nom';

  @override
  String get email => 'Email';

  @override
  String get year => 'Année';

  @override
  String get specialty => 'Spécialité';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour !';

  @override
  String get profileUpdateFailed => 'Échec de la mise à jour';

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get core => 'Cœur';

  @override
  String get themeMode => 'Mode Thème';

  @override
  String get language => 'Langue';

  @override
  String get fontSize => 'Taille Police';

  @override
  String get highContrast => 'Haut Contraste';

  @override
  String get userPreferences => 'Préférences Utilisateur';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettingsTitle => 'Paramètres de notification';

  @override
  String get notificationSettingsInfo =>
      'Personnalisez vos alertes pour rester concentré sur vos objectifs sans être interrompu.';

  @override
  String get globalNotifications => 'Notifications Globales';

  @override
  String get productiveBayRemindersTitle => 'RAPPELS PRODUCTIVE BAY';

  @override
  String get examReminders => 'Examens';

  @override
  String get examRemindersDesc => 'Alertes 24h avant vos examens enregistrés.';

  @override
  String get taskReminders => 'Tâches';

  @override
  String get taskRemindersDesc => 'Rappels 1h avant l\'échéance de vos tâches.';

  @override
  String get studyReminders => 'Séances d\'Étude';

  @override
  String get studyRemindersDesc =>
      'Notification 10 min avant le début d\'une session.';

  @override
  String get communityNotifications => 'Communauté';

  @override
  String get communityNotificationsDesc =>
      'Réponses à vos commentaires et mentions.';

  @override
  String get systemSettingsPrompt =>
      'Les notifications sont désactivées dans les paramètres système.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get fontSettingsTitle => 'Taille du texte';

  @override
  String get fontSettingsDesc =>
      'Ajuster la taille du texte améliore la lisibilité. Les modifications s\'appliqueront à toute l\'application.';

  @override
  String get fontPreviewTitle => 'Aperçu';

  @override
  String get fontPreviewText =>
      'Meducyte est une plateforme d\'apprentissage avancée conçue pour les étudiants en médecine. Elle offre des cas cliniques, des flashcards et un espace de travail dédié.';

  @override
  String get fontSmall => 'Petit';

  @override
  String get fontMedium => 'Moyen (Défaut)';

  @override
  String get fontLarge => 'Grand';

  @override
  String get quizFontSizeTitle => 'Taille du texte Quiz';

  @override
  String get courseFontSizeTitle => 'Taille du texte Cours';

  @override
  String get shareQuestion => 'Partager la question';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get syncSettings => 'Synchronisation';

  @override
  String get spacedRepetition => 'Spaced Repetition';

  @override
  String get studyPlan => 'Plan d\'étude';

  @override
  String get downloadMode => 'Mode téléchargement';

  @override
  String get advancedAbout => 'Avancé / À propos';

  @override
  String get securityPrivacy => 'Sécurité et Confidentialité';

  @override
  String get resetData => 'Réinitialiser les données';

  @override
  String get resetDataSubtitle => 'Effacez vos paramètres et le cache local';

  @override
  String get resetDataWarning =>
      'Cela effacera tous vos paramètres locaux, le contenu en cache et vous déconnectera. Cette action est irréversible.';

  @override
  String get deleteAccountTitle => 'Supprimer mon compte';

  @override
  String get deleteAccountSubtitle =>
      'Supprimer définitivement votre compte et données';

  @override
  String get deleteAccountWarning =>
      'ATTENTION : Cette action est définitive et supprimera toute votre progression, l\'historique des quiz et vos abonnements. Vous ne pourrez pas annuler cela.';

  @override
  String get deleteConfirmationInstruction =>
      'Pour confirmer, veuillez taper \'SUPPRIMER\' ci-dessous :';

  @override
  String get deleteConfirmationHint => 'Tapez SUPPRIMER ici';

  @override
  String get dataResetSuccess =>
      'Toutes les données locales ont été effacées avec succès.';

  @override
  String get accountDeletedSuccess =>
      'Votre compte a été supprimé définitivement.';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Confidentialité & Conditions';

  @override
  String get support => 'Support Client';

  @override
  String get rateUs => 'Nous évaluer';

  @override
  String get rateUsTitle => 'Dites-nous ce que vous en pensez';

  @override
  String get rateUsSubtitle =>
      'Vos retours nous aident à rendre Meducyte meilleur pour tous les étudiants en médecine.';

  @override
  String get rateOnStore => 'Évaluer sur l\'App Store';

  @override
  String get rateFeedback => 'Envoyer un avis';

  @override
  String get subscription => 'Abonnement';

  @override
  String get basicPlan => 'Basique';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get comparePlans => 'Comparer les Plans';

  @override
  String get featureAcademicModules => 'Modules Académiques';

  @override
  String get featureAiAssistant => 'Assistant Intelligent IA';

  @override
  String get featureClinicalCases => 'Cas Cliniques';

  @override
  String get featureAdvancedStats => 'Statistiques Avancées';

  @override
  String get logout => 'Déconnexion';

  @override
  String get saveQuiz => 'Enregistrer Quiz';

  @override
  String get saveToCollection => 'Ajouter à une collection';

  @override
  String get createCollection => 'Créer collection';

  @override
  String get renameCollection => 'Renommer collection';

  @override
  String get collectionName => 'Nom de collection';

  @override
  String get quizSaved => 'Quiz enregistré !';

  @override
  String get myCollections => 'Mes Collections';

  @override
  String get searchCollections => 'Chercher collections...';

  @override
  String get highlight => 'Surligner';

  @override
  String get addNote => 'Ajouter note';

  @override
  String get chooseColor => 'Choisir couleur';

  @override
  String get saveNote => 'Enregistrer note';

  @override
  String get editNote => 'Modifier note';

  @override
  String get editComment => 'Modifier commentaire';

  @override
  String get cancel => 'Annuler';

  @override
  String get interactionSpace => 'Espace d\'interaction';

  @override
  String get commentsFeed => 'Flux de commentaires';

  @override
  String get myNotes => 'Mes Notes';

  @override
  String get noComments =>
      'Pas encore de commentaires. Commencez la discussion !';

  @override
  String get noNotes => 'Vous n\'avez pas de note ici.';

  @override
  String get addPublicComment => 'Ajouter un commentaire...';

  @override
  String get selectionReminder => 'Rappel de sélection :';

  @override
  String get myNote => 'Ma Note :';

  @override
  String get edit => 'Éditer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edited => 'Modifié';

  @override
  String get confirmDelete => 'Confirmer suppression';

  @override
  String get deleteCommentConfirm => 'Supprimer ce commentaire ?';

  @override
  String get questionInfo => 'Infos Question';

  @override
  String get source => 'Source';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLearn => 'Étudier';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navSimulation => 'Simulation';

  @override
  String get productiveBay => 'Productive Bay';

  @override
  String get focusFatigueAnalysis => 'Analyse Focus & Fatigue (IA)';

  @override
  String get dashboardHub => 'Tableau de Bord';

  @override
  String get deepWorkMode => 'Mode Deep Work';

  @override
  String get examCountdown => 'Compte à Rebours';

  @override
  String get aiPlanner => 'Planificateur IA';

  @override
  String get planner => 'Planificateur';

  @override
  String get myTasks => 'Mes Tâches';

  @override
  String urgentTasksCount(Object count) {
    return '$count Tâches Urgentes';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get studyPatterns => 'Habitudes d\'Étude';

  @override
  String get groups => 'Groups';

  @override
  String get studyTogether => 'Étudier Ensemble';

  @override
  String get deepWork => 'DEEP WORK';

  @override
  String get shortBreak => 'PAUSE COURTE';

  @override
  String get longBreak => 'PAUSE LONGUE';

  @override
  String get start => 'Start';

  @override
  String get none => 'None';

  @override
  String get forest => 'Forêt';

  @override
  String get rain => 'Pluie';

  @override
  String get waves => 'Vagues';

  @override
  String focusOn(Object task) {
    return 'Focus : $task';
  }

  @override
  String get taskListTitle => 'Ma Liste de Tâches';

  @override
  String get newTask => 'Nouvelle Tâche Focus';

  @override
  String get whatWillYouAchieve => 'Qu\'allez-vous accomplir ?';

  @override
  String get priority => 'Priorité';

  @override
  String get estimatedWork => 'Estimation du travail';

  @override
  String get addToList => 'Ajouter à ma liste';

  @override
  String get jumpToQuestion => 'Aller à la question';

  @override
  String get finishQuiz => 'Terminer Quiz';

  @override
  String get quizResult => 'Résultat du Quiz';

  @override
  String get score => 'Score';

  @override
  String get correctAnswer => 'Réponse Correcte';

  @override
  String get clinicalCase => 'Cas Clinique';

  @override
  String get correctAnswers => 'Correct';

  @override
  String get incorrectAnswers => 'Incorrect';

  @override
  String get partiallyCorrectAnswers => 'Partiel';

  @override
  String get reviewErrors => 'Revoir Erreurs';

  @override
  String get backToHome => 'Retour Accueil';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get keepImproving => 'Continuez à progresser !';

  @override
  String get startQuiz => 'Commencer Quiz';

  @override
  String get startRevision => 'Commencer Révision';

  @override
  String get numberOfQuestions => 'Nombre de Questions';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => 'Expert';

  @override
  String get practice => 'ENTRAÎNEMENT';

  @override
  String get simulation => 'SIMULATION RÉELLE';

  @override
  String get theoretical => 'THÉORIQUE';

  @override
  String get clinical => 'CLINIQUE';

  @override
  String get explore => 'EXPLORER';

  @override
  String get exploreRevision => 'Réviser Directement';

  @override
  String get simulationSubtitle => 'Environnement d\'Examen Réel';

  @override
  String get finishRevision => 'Terminer Révision';

  @override
  String get studyYear => 'Année d\'Étude';

  @override
  String get chapters => 'Chapitres';

  @override
  String get lessons => 'Cours';

  @override
  String get lesson => 'Cours';

  @override
  String get module => 'Module';

  @override
  String get unitOfIntegratedTeaching => 'Unité d\'Enseignement Intégré';

  @override
  String get lessonCompleted => 'Leçon terminée !';

  @override
  String get finishLesson => 'Terminer la leçon';

  @override
  String get lessonCompletedSub =>
      'Félicitations ! Vous avez maîtrisé cette leçon.';

  @override
  String get finishLessonSub =>
      'Prêt à passer à la suite ? Marquez cette leçon comme étudiée.';

  @override
  String get markAsUnstudied => 'Marquer comme non étudiée';

  @override
  String get markAsStudied => 'Marquer comme étudiée';

  @override
  String get chatbotTitle => 'Meducyte AI';

  @override
  String get online => 'En ligne';

  @override
  String get newChat => 'Nouv. Chat';

  @override
  String get history => 'Historique';

  @override
  String get deleteChat => 'Supprimer Chat';

  @override
  String get clearHistory => 'Effacer Historique';

  @override
  String get askMedicalQuestion => 'Poser une question médicale...';

  @override
  String get chatbotDescription => 'Votre Assistant Clinique';

  @override
  String get askYourQuestion => 'Posez votre question...';

  @override
  String get chatbotError => 'Une erreur est survenue.';

  @override
  String get chatSuggestion1 => 'Comment m\'aider à étudier ?';

  @override
  String get chatSuggestion2 => 'Expliquer un concept médical complexe';

  @override
  String get chatSuggestion3 => 'Résumer une pathologie';

  @override
  String get chatSuggestion4 => 'Infos sur les indications d\'un médicament';

  @override
  String get chatHistory => 'Historique Chat';

  @override
  String get noHistoryFound => 'Aucun historique.';

  @override
  String get databaseStatus => 'État de la base';

  @override
  String get registeredDrugs => 'Médicaments enregistrés';

  @override
  String get uniqueDrugPrincipals => 'Principes Actifs Uniques';

  @override
  String get enrichedClinicalInfos => 'Infos Cliniques Enrichies';

  @override
  String get close => 'Fermer';

  @override
  String get databaseStatistics => 'Statistiques Base de Données';

  @override
  String get enrichedOnlySubtitle => 'Médicaments avec détails complets';

  @override
  String get therapeuticClass => 'Classe Thérapeutique';

  @override
  String get allClasses => 'Toutes les Classes';

  @override
  String get errorLoadingData => 'Erreur de chargement.';

  @override
  String get general => 'Général';

  @override
  String get administrativeInfos => 'Détails Admin';

  @override
  String get labAndForm => 'Labo & Forme';

  @override
  String get therapeuticIndications => 'Indications Thérapeutiques';

  @override
  String get contraindications => 'Contre-indications';

  @override
  String get sideEffects => 'Effets Secondaires';

  @override
  String get mechanismOfAction => 'Mécanisme d\'Action';

  @override
  String get clinicalInfoUpdating => 'Mise à jour quotidienne...';

  @override
  String get drugNotFound => 'Médicament non trouvé';

  @override
  String get selectedDrugs => 'Sélectionnés';

  @override
  String get addDrug => 'Ajouter';

  @override
  String get noDrugsSelectedPrompt => 'Sélectionnez au moins deux médicaments.';

  @override
  String get selectTwoDrugsPrompt => 'Sélectionnez au moins deux médicaments.';

  @override
  String get noInteractionsFound => 'Aucune interaction connue.';

  @override
  String get management => 'Conduite à tenir :';

  @override
  String get addDrugToChecker => 'Ajouter au vérificateur';

  @override
  String get searchDrugHint => 'Chercher un médicament...';

  @override
  String get severe => 'Sévère';

  @override
  String get moderate => 'Modérée';

  @override
  String get minor => 'Mineure';

  @override
  String get spec_general => 'Médecine Générale';

  @override
  String get spec_cardiology => 'Cardiologie';

  @override
  String get spec_neurology => 'Neurologie';

  @override
  String get spec_anesthesiereanimation => 'Anesthésie-Réanimation';

  @override
  String get spec_anesthesiereanimationpediatrique =>
      'Anesthésie-Réanimation Pédiatrique';

  @override
  String get spec_biophysiquemedicale => 'Biophysique Médicale';

  @override
  String get spec_dermatologieetvenereologie => 'Dermatologie et Vénéréologie';

  @override
  String get spec_diabetologieendocrinologieetmaladiesmetaboliques =>
      'Endocrinologie-Diabétologie';

  @override
  String get spec_epidemiologieetmedecinepreventive => 'Épidémiologie';

  @override
  String get spec_hepatogastroenterologie => 'Hépato-Gastro-Entérologie';

  @override
  String get spec_hematologie => 'Hématologie';

  @override
  String get spec_gynecologieobstetrique => 'Gynécologie-Obstétrique';

  @override
  String get spec_infectiologie => 'Infectiologie';

  @override
  String get spec_medecineinterne => 'Médecine Interne';

  @override
  String get spec_medecinelegaledroitmedicaletethique => 'Médecine Légale';

  @override
  String get spec_medecinenucleaireetimageriemoleculaire =>
      'Médecine Nucléaire';

  @override
  String get spec_medecinedusport => 'Médecine du Sport';

  @override
  String get spec_medecinedutravail => 'Médecine du Travail';

  @override
  String get spec_medecinephysiqueetreadaptation => 'MPR';

  @override
  String get spec_nephrologie => 'Néphrologie';

  @override
  String get spec_oncologiemedicale => 'Oncologie Médicale';

  @override
  String get spec_ophtalmologie => 'Ophtalmologie';

  @override
  String get spec_orl => 'ORL';

  @override
  String get spec_pediatrie => 'Pédiatrie';

  @override
  String get spec_psychiatrie => 'Psychiatrie';

  @override
  String get spec_pedopsychiatrie => 'Pédopsychiatrie';

  @override
  String get spec_pneumophtisiologie => 'Pneumo-Phtisiologie';

  @override
  String get spec_radiotherapieoncologie => 'Radiothérapie';

  @override
  String get spec_rhumatologie => 'Rhumatologie';

  @override
  String get spec_reanimationmedicale => 'Réanimation Médicale';

  @override
  String get spec_chirurgiegenerale => 'Chirurgie Générale';

  @override
  String get spec_chirurgiecardiaque => 'Chirurgie Cardiaque';

  @override
  String get spec_chirurgiemaxillofaciale => 'Chirurgie Maxillo-Faciale';

  @override
  String get spec_chirurgieneurologique => 'Neurochirurgie';

  @override
  String get spec_chirurgieorthopediqueettraumatologie =>
      'Orthopédie-Traumatologie';

  @override
  String get spec_chirurgiepediatrique => 'Chirurgie Pédiatrique';

  @override
  String get spec_chirurgiethoracique => 'Chirurgie Thoracique';

  @override
  String get spec_chirurgieurologique => 'Urologie';

  @override
  String get spec_chirurgievasculaire => 'Chirurgie Vasculaire';

  @override
  String get spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie =>
      'Chirurgie Plastique';

  @override
  String get spec_pulmonology => 'Pneumologie';

  @override
  String get spec_endocrinology => 'Endocrinologie';

  @override
  String get spec_surgery => 'Chirurgie';

  @override
  String get spec_orthopedics => 'Orthopédie';

  @override
  String get spec_urology => 'Urologie';

  @override
  String get spec_radiology => 'Radiologie';

  @override
  String get spec_pathology => 'Anatomopathologie';

  @override
  String get spec_emergency => 'Médecine d\'Urgence';

  @override
  String get selectSpecialty => 'Choisir une spécialité';

  @override
  String get chooseTemplateDescription =>
      'Utilisez un modèle adapté à votre spécialité pour gagner du temps.';

  @override
  String get addParameter => 'Paramètre';

  @override
  String get parameterNameHint => 'Nom (ex: CK-MB)';

  @override
  String get addExam => 'Examens :';

  @override
  String get pendingOrNotProvided => '- *En attente / Non fourni*';

  @override
  String get enterResultHint => 'Saisir résultat...';

  @override
  String get selectExamHint => 'Choisir';

  @override
  String get observationHistory => 'Historique';

  @override
  String get save => 'Enreg.';

  @override
  String get noSavedReports => 'Aucun rapport enregistré.';

  @override
  String get deleteReportConfirm => 'Supprimer ce rapport ?';

  @override
  String get reportSaved => 'Rapport enregistré !';

  @override
  String get loadReport => 'Charger Rapport';

  @override
  String get searchPatients => 'Chercher patients...';

  @override
  String get gender => 'Genre';

  @override
  String get gender_male => 'Homme';

  @override
  String get gender_female => 'Femme';

  @override
  String get intro_patient_name_hint => 'Nom du patient';

  @override
  String get intro_age_hint => 'Âge';

  @override
  String get intro_origin_hint => 'Ville / Quartier';

  @override
  String get intro_marital_status_hint => 'État civil';

  @override
  String get intro_profession_hint => 'Profession';

  @override
  String get intro_date_hint => 'JJ/MM/AAAA';

  @override
  String get intro_signs_hint => 'Signes cliniques';

  @override
  String get intro_patient_prefix => 'Le patient';

  @override
  String get intro_age_label_masculine => 'ans';

  @override
  String get intro_age_label_feminine => 'ans';

  @override
  String get intro_age_prefix => ' âgé de ';

  @override
  String get intro_origin_prefix => ' résidant à ';

  @override
  String get intro_admitted_masculine => 'hospitalisé le';

  @override
  String get intro_admitted_feminine => 'hospitalisée le';

  @override
  String get intro_date_prefix => ' le ';

  @override
  String get intro_for_prefix => ' pour : ';

  @override
  String get section_introduction => 'Introduction';

  @override
  String get section_motif => 'Motif d\'Admission';

  @override
  String get section_history => 'Histoire de la Maladie';

  @override
  String get section_antecedents => 'Antécédents';

  @override
  String get section_general_vitals =>
      'Examen Clinique - État Général & Constantes';

  @override
  String get section_paraclinical => 'Examens Paracliniques';

  @override
  String get section_summary => 'Résumé Syndromique';

  @override
  String get section_conclusion => 'Conclusion / Conduite à tenir';

  @override
  String get vitals_bp => 'TA';

  @override
  String get vitals_hr => 'FC';

  @override
  String get vitals_rr => 'FR';

  @override
  String get vitals_temp => 'Temp';

  @override
  String get vitals_spo2 => 'SpO2';

  @override
  String get addCustomSection => 'Ajouter section';

  @override
  String get exam_general_state_label => 'Impression Globale / État Général';

  @override
  String get exam_general_state_hint =>
      'Bon EG, conscient, coopérant, bien orienté';

  @override
  String get exam_hydration_label => 'Hydratation et Nutrition';

  @override
  String get exam_hydration_hint => 'Pas de pli cutané, IMC normal';

  @override
  String get exam_head_neck_label => 'Examen Tête et Cou';

  @override
  String get exam_head_neck_hint => 'Conjonctives roses, pas d\'ictère';

  @override
  String get exam_respiratory_label => 'Examen Pulmonaire';

  @override
  String get exam_respiratory_hint => 'Murmure vésiculaire symétrique';

  @override
  String get exam_cardio_label => 'Examen Cardiaque';

  @override
  String get exam_cardio_hint => 'Bruits réguliers, pas de souffle';

  @override
  String get exam_abdominal_label => 'Examen Abdominal';

  @override
  String get exam_abdominal_hint => 'Abdomen souple, dépressible, indolore';

  @override
  String get exam_urogenital_label => 'Examen Urogénital';

  @override
  String get exam_urogenital_hint => 'Fosses lombaires libres';

  @override
  String get exam_locomotor_label => 'Examen Locomoteur';

  @override
  String get exam_locomotor_hint => 'Mobilité conservée, pas d\'inflammation';

  @override
  String get exam_neuro_mental_label => 'Examen Neuro/Mental';

  @override
  String get exam_neuro_mental_hint => 'Pas de signe de focalisation';

  @override
  String get exam_skin_label => 'Examen Cutané';

  @override
  String get exam_skin_hint => 'Pas de purpura';

  @override
  String get exam_cardio_edema_label => 'Inspection : Œdèmes';

  @override
  String get exam_cardio_edema_hint => 'Absents';

  @override
  String get exam_cardio_cyanosis_label => 'Inspection : Cyanose';

  @override
  String get exam_cardio_cyanosis_hint => 'Absente';

  @override
  String get exam_neuro_glasgow_label => 'Conscience (Glasgow)';

  @override
  String get exam_neuro_glasgow_hint => '15/15';

  @override
  String get exam_neuro_orient_label => 'Orientation';

  @override
  String get exam_neuro_orient_hint => 'Bien orienté';

  @override
  String get yourJourney => 'Votre Parcours';

  @override
  String get noModulesForYear => 'Aucun module pour cette année.';

  @override
  String get accessContent => 'Voir Contenu';

  @override
  String get quickTraining => 'Entraînement Rapide';

  @override
  String get readingInProgress => 'Lecture en cours';

  @override
  String get firstYearOrdinal => '1ère Année';

  @override
  String otherYearOrdinal(Object year) {
    return '$yearème Année';
  }

  @override
  String get noLessonsAvailable => 'Aucun cours disponible.';

  @override
  String get loading => 'Chargement...';

  @override
  String get modules => 'Modules';

  @override
  String get quizzes => 'Quiz';

  @override
  String get upgradeToResidencyToUnlockYears =>
      'Passez au plan Résidanat pour débloquer !';

  @override
  String get studyTools => 'Outils d\'Étude';

  @override
  String get performanceStats => 'Stats de Performance';

  @override
  String get accuracyLabel => 'Précision';

  @override
  String get streakLabel => 'Série';

  @override
  String daysLabel(Object days) {
    return '$days Jours';
  }

  @override
  String get reviseSubtitle => 'Par module ou spécialité';

  @override
  String get simulateSubtitle => 'Environnement réel d\'examen';

  @override
  String get revisionModeSubtitle => 'Lire et réviser le contenu';

  @override
  String get questionDetails => 'Détails Question';

  @override
  String get noQuestionsFound => 'Aucune question trouvée.';

  @override
  String get selectPrompt => 'Sélectionner';

  @override
  String get deleteHighlight => 'Enlever surlignage';

  @override
  String get editNoteLabel => 'Modifier la note';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get notes => 'Notes';

  @override
  String get savedQuizzes => 'Quiz Enregistrés';

  @override
  String get residencyExam => 'Concours Résidanat';

  @override
  String get allOrNothingScore => 'Tout ou\nRien';

  @override
  String get partialPointsScore => 'Points\nPartiels';

  @override
  String get unsaveQuestion => 'Désenregistrer';

  @override
  String get unsaveQuestionConfirmation => 'Retirer cette question ?';

  @override
  String get confirm => 'Confirmer';

  @override
  String questionsCount(Object count) {
    return '$count questions';
  }

  @override
  String get voiceReader => 'Lecteur Vocal';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get speed => 'Vitesse';

  @override
  String get print => 'Imprimer';

  @override
  String get voiceSettings => 'Paramètres Voix';

  @override
  String get aiHelper => 'Assistant IA';

  @override
  String get explain => 'Expliquer';

  @override
  String get summarize => 'Résumer';

  @override
  String get mnemonic => 'Mémo';

  @override
  String get refine => 'Affiner';

  @override
  String get printLesson => 'Imprimer Cours';

  @override
  String get generatingPdf => 'Génération PDF...';

  @override
  String get paragraph => 'Paragraphe';

  @override
  String get sq3rTechnique => 'Technique SQ3R';

  @override
  String get activeRecall => 'Rappel Actif';

  @override
  String get moreTools => 'Plus d\'Outils';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get reportQuestion => 'Signaler Question';

  @override
  String get quizHub => 'Centre de Quiz';

  @override
  String get studyDecks => 'PAQUETS D\'ÉTUDE';

  @override
  String get savedQuizzesSubtitle => 'Questions enregistrées';

  @override
  String get spacedRepetitionSubtitle => 'Répétition espacée';

  @override
  String get byModule => 'Par Module';

  @override
  String get byModuleSubtitle => 'Par module spécifique';

  @override
  String get masterYourMemory => 'Maîtrisez votre mémoire';

  @override
  String get flashcardsHeaderSubtitle =>
      'Répétition espacée pour ne jamais oublier.';

  @override
  String get noSavedQuestionsToStudy => 'Aucune question enregistrée.';

  @override
  String get errorLoadingQuestions => 'Erreur de chargement';

  @override
  String get allCaughtUp => 'Tout à jour ! Pas de révisions aujourd\'hui.';

  @override
  String get noCardsToStudy => 'Pas de cartes à étudier.';

  @override
  String get showAnswerToGrade => 'Voir la réponse';

  @override
  String get howWellDidYouRecall => 'QUALITÉ DU RAPPEL ?';

  @override
  String get studyComplete => 'ÉTUDE TERMINÉE';

  @override
  String studySummary(Object count, Object time) {
    return 'Vous avez révisé $count cartes en $time';
  }

  @override
  String get questionLabel => 'QUESTION';

  @override
  String get tapToFlip => 'TAP POUR TOURNER';

  @override
  String get correctAnswerLabel => 'RÉPONSE CORRECTE';

  @override
  String get clinicalContext => 'CONTEXTE CLINIQUE';

  @override
  String get nowGradeYourRecall => 'ÉVALUEZ VOTRE RAPPEL';

  @override
  String get performanceAgain => 'REVOIR';

  @override
  String get performanceHard => 'DIFF';

  @override
  String get performanceGood => 'BIEN';

  @override
  String get performanceEasy => 'FACILE';

  @override
  String get folders => 'Dossiers';

  @override
  String get studyByFolder => 'Réviser par dossier';

  @override
  String get selectModule => 'Choisir Module';

  @override
  String get selectFolder => 'Choisir Dossier';

  @override
  String get startNewQuiz => 'Nouveau Quiz';

  @override
  String get noActiveQuiz => 'Pas de quiz en cours';

  @override
  String get checkBackTomorrow => 'Rejouez demain !';

  @override
  String get srsEmptyTitle => 'Votre SRS est vide';

  @override
  String get srsEmptySubtitle => 'Ajoutez des questions pendant vos quiz.';

  @override
  String get learningLabel => 'Apprentissage';

  @override
  String get masteredLabel => 'Maîtrisé';

  @override
  String get totalLabel => 'Total';

  @override
  String get dueToday => 'À RÉVISER';

  @override
  String startReviewCount(Object count) {
    return 'LANCER ($count)';
  }

  @override
  String get srsDueTitle => 'Spaced Repetition';

  @override
  String cardsDueText(Object count) {
    return '$count cartes à réviser';
  }

  @override
  String get startReview => 'Lancer révision';

  @override
  String get sessionComplete => 'Session Terminée';

  @override
  String get greatJob => 'Bravo !';

  @override
  String completionTime(Object time) {
    return 'Terminé en $time';
  }

  @override
  String get finish => 'TERMINER';

  @override
  String get resetProgressTitle => 'Réinitialiser ?';

  @override
  String get resetProgressSubtitle => 'Effacera toute votre progression SRS.';

  @override
  String get srsReset => 'RESET';

  @override
  String get srsResetSuccess => 'Progression réinitialisée.';

  @override
  String get srsSettingsTitle => 'Paramètres SRS';

  @override
  String get srsSettingsInfo =>
      'Personnalisez votre rythme d\'apprentissage et vos rappels.';

  @override
  String get srsNewCardsTitle => 'Nouvelles cartes par jour';

  @override
  String get srsNewCardsDesc =>
      'Nombre de nouvelles questions introduites quotidiennement.';

  @override
  String get srsReviewLimitTitle => 'Limite quotidienne de révisions';

  @override
  String get srsReviewLimitDesc =>
      'Nombre maximum de cartes à réviser par jour.';

  @override
  String get srsNotificationTitle => 'Rappel de révision';

  @override
  String get srsNotificationDesc =>
      'Soyez averti lorsqu\'il est temps de réviser vos cartes.';

  @override
  String get srsNotificationTimeTitle => 'Heure du rappel';

  @override
  String get addedToSrs => 'Ajouté au SRS';

  @override
  String get errorLoadingQuestionsShort => 'Erreur chargement';

  @override
  String get noQuestionsInModule => 'Aucune question';

  @override
  String get noQuestionsInFolder => 'Dossier vide';

  @override
  String get premiumContent => 'Contenu Premium';

  @override
  String get unlockPremiumDescription => 'Abonnez-vous pour un accès complet !';

  @override
  String get discoverPlans => 'Découvrir les plans';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get testFeatures => 'Tester les fonctionnalités';

  @override
  String get selectBestOption => 'Choisissez la meilleure option';

  @override
  String get correctionMode => 'Mode Correction';

  @override
  String get instantCorrection => 'Correction Instantanée';

  @override
  String get instantCorrectionDesc => 'Résultats après chaque question';

  @override
  String get deferredCorrection => 'Correction Différée';

  @override
  String get deferredCorrectionDesc => 'Résultats à la fin du quiz';

  @override
  String get personalNote => 'Note Perso';

  @override
  String get communityComments => 'Commentaires Communauté';

  @override
  String get saveQuestion => 'Sauver Question';

  @override
  String get removeFromSrs => 'Retirer du SRS';

  @override
  String get removedFromSrs => 'Retiré du SRS';

  @override
  String get exploreDescription =>
      'Ressources cliniques et communauté médicale.';

  @override
  String get medicalWorld => 'Monde Médical';

  @override
  String get externalResources => 'Ressources & Communauté';

  @override
  String get interpretationHelpers => 'Aides à l\'Interprétation';

  @override
  String get caseOfTheDay => 'Cas du Jour';

  @override
  String get medicalNews => 'Actualités Médicales';

  @override
  String get clinicalPearls => 'Perles Cliniques';

  @override
  String get quickCalcHub => 'Calculateurs Rapides';

  @override
  String get joinOfficialDrive => 'Accéder au Drive';

  @override
  String get joinTelegram => 'Canal Telegram';

  @override
  String get booksLibrary => 'Livres Médicaux';

  @override
  String get booksLibraryDesc => 'Téléchargez vos livres et polycopiés';

  @override
  String get firstAid => 'Secourisme';

  @override
  String get firstAidDesc => 'Gestes qui sauvent et urgences';

  @override
  String get ecgInterpretation => 'Aide ECG';

  @override
  String get radiologyHelper => 'Guide Radio (Thorax)';

  @override
  String get labInterpretation => 'Aide Bio';

  @override
  String get simulationDescription => 'Simulations cliniques interactives.';

  @override
  String get aiPatientInteraction => 'Interaction Patient IA';

  @override
  String get ecosExamSimulator => 'Simulateur ECOS';

  @override
  String get emergencyRoomChallenge => 'Urgences Médicales';

  @override
  String get virtualWardRounds => 'Visites de Service';

  @override
  String get diagnosticChallenge => 'Challenge Radio';

  @override
  String get proceduralGuide => 'Sutures & Gestes';

  @override
  String get globalLeaderboards => 'Classement Global';

  @override
  String get aiPatientDesc => 'Dialoguez avec un patient';

  @override
  String get ecosDesc => 'Préparez vos examens';

  @override
  String get erChallengeDesc => 'Gérez les urgences';

  @override
  String get wardRoundsDesc => 'Gérez votre service';

  @override
  String get diagnosticChallengeDesc => 'Maîtrisez l\'imagerie';

  @override
  String get proceduralGuideDesc => 'Apprenez les gestes';

  @override
  String get leaderboardsDesc => 'Défiez les autres';

  @override
  String get coreSimulations => 'Simulations Cœur';

  @override
  String get specializedExams => 'Examens Spécialisés';

  @override
  String get driveDescription => 'Milliers de documents';

  @override
  String get telegramDescription => 'Communauté active';

  @override
  String get caseOfDayDescription => 'Raisonnement clinique';

  @override
  String get medicalNewsDescription => 'Dernières avancées';

  @override
  String get clinicalPearlsDescription => 'Conseils médicaux';

  @override
  String get calcHubDescription => 'Calculateurs essentiels';

  @override
  String get interactiveLearning => 'Apprentissage Interactif';

  @override
  String get questionNavigation => 'Navigation Quiz';

  @override
  String get correction => 'Correction';

  @override
  String get ecgInterpretationReport => 'Rapport d\'Interprétation ECG';

  @override
  String get ecgAnalysisReport => 'RAPPORT d\'ANALYSE ECG';

  @override
  String get ecgCase => 'Cas';

  @override
  String get ecgAiActive => 'IA ACTIVE';

  @override
  String get ecgHeartRate => 'FRÉQUENCE CARDIAQUE';

  @override
  String get ecgQtcInterval => 'INTERVALLE QTC';

  @override
  String get ecgRhythmAnalysis => 'ANALYSE DU RYTHME';

  @override
  String get ecgAiConfidence => 'CONFIANCE IA';

  @override
  String get ecgLeadClinicalGrid => 'GRILLE CLINIQUE 12 DÉRIV.';

  @override
  String get ecgGuidedInterpretation => 'Checklist d\'Interprétation';

  @override
  String get ecgShareReport => 'Partager Rapport';

  @override
  String get ecgEducationalTool => 'Outil Pédagogique Uniquement';

  @override
  String get ecgEducationalToolDesc =>
      'Ce guide interactif est destiné aux étudiants. Ce n\'est PAS un dispositif médical certifié et ne doit pas servir au diagnostic clinique.';

  @override
  String get ecgSourceTitle => 'Source de l\'ECG';

  @override
  String get ecgSourceCamera => 'Appareil Photo';

  @override
  String get ecgSourceGallery => 'Galerie';

  @override
  String get ecgSourceDraw => 'Dessiner';

  @override
  String get ecgSourceClear => 'Effacer';

  @override
  String get ecgStatusNormal => 'NORMAL';

  @override
  String get ecgStatusStable => 'STABLE';

  @override
  String get ecgStatusClear => 'CLAIR';

  @override
  String get ecgStatusIschemia => 'ISCHÉMIE';

  @override
  String get ecgChapterRateRhythm => '1. Rythme & Fréquence';

  @override
  String get ecgChapterAxisIntervals => '2. Axe & Intervalles';

  @override
  String get ecgChapterIschemiaInfarction => '3. Ischémie & Infarctus';

  @override
  String get ecgChapterHypertrophyConduction => '4. Hypertrophie & Conduction';

  @override
  String get ecgChapterPatternRecognition => '5. Reconnaissance de Formes';

  @override
  String get ecgChapterClinicalCorrelation => '6. Corrélation Clinique';

  @override
  String get ecgRrCalculator => 'Calculateur FC (Rythme Régulier)';

  @override
  String get ecgSmallSquares => 'Petits Carreaux (R-R)';

  @override
  String get ecgQtcCalculator => 'Calculateur QTc Bazett';

  @override
  String get ecgQtInterval => 'Intervalle QT (Petits Carreaux)';

  @override
  String get ecgProlonged => 'Allongé';

  @override
  String get ecgNormal => 'Normal';

  @override
  String get ecgLeadI => 'D1';

  @override
  String get ecgLeadaVF => 'aVF';

  @override
  String get ecgPositive => 'Positive (+)';

  @override
  String get ecgNegative => 'Négative (-)';

  @override
  String get ecgEquivocal => 'Équivoque';

  @override
  String get ecgTerritoryLateral => 'Latéral';

  @override
  String get ecgTerritoryInferior => 'Inférieur';

  @override
  String get ecgTerritorySeptal => 'Septal';

  @override
  String get ecgTerritoryAnterior => 'Antérieur';

  @override
  String get ecgTerritoryReciprocal => 'Miroir';

  @override
  String get ecgAbnormalLeadsDetected => 'Anomalies détectées';

  @override
  String get ecgCheckRhythmRegular => 'Rythme régulier ?';

  @override
  String get ecgCheckRhythmRegularDesc =>
      'Vérifiez si l\'espace entre les ondes R est constant.';

  @override
  String get ecgCheckPWave => 'Onde P avant chaque QRS ?';

  @override
  String get ecgCheckPWaveDesc => 'Confirme l\'origine sinusale.';

  @override
  String get ecgLeadIDirection => 'D1 (Direction QRS)';

  @override
  String get ecgLeadaVFDirection => 'aVF (Direction QRS)';

  @override
  String get ecgCurrentAxis => 'Axe actuel';

  @override
  String get ecgCheckStElevation => 'Sus-décalage ST > 1mm ?';

  @override
  String get ecgCheckStElevationDesc => 'Visez le point J.';

  @override
  String get ecgCheckStDepression => 'Sous-décalage ST ?';

  @override
  String get ecgCheckStDepressionDesc =>
      'Significatif si horizontal/descendant > 0.5mm.';

  @override
  String get ecgCheckTWaveInversion => 'Inversion onde T ?';

  @override
  String get ecgCheckTWaveInversionDesc => 'Symétrique en V1-V6 : ischémie.';

  @override
  String get ecgCheckQrsWide => 'QRS > 120ms (3px) ?';

  @override
  String get ecgCheckQrsWideDesc => 'Bloc de branche.';

  @override
  String get ecgCheckSokolow => 'Critères de Sokolow-Lyon ?';

  @override
  String get ecgCheckSokolowDesc => 'S en V1 + R en V5/V6 > 35mm (HVG).';

  @override
  String get ecgCheckHyperkalemia => 'Signes d\'Hyperkaliémie ?';

  @override
  String get ecgCheckHyperkalemiaDesc => 'Ondes T pointues, QRS large.';

  @override
  String get ecgCheckPe => 'Embolie Pulmonaire (S1Q3T3) ?';

  @override
  String get ecgCheckPeDesc => 'S en D1, Q en D3, T inv en D3.';

  @override
  String get ecgCheckBrugada => 'Pattern de Brugada ?';

  @override
  String get ecgCheckBrugadaDesc => 'ST en dôme en V1-V2.';

  @override
  String get ecgCheckChestPain => 'Douleur Thoracique / Dyspnée ?';

  @override
  String get ecgCheckChestPainDesc => 'Corrélation clinique nécessaire.';

  @override
  String get ecgCheckPreviousEcg => 'ECG antérieur disponible ?';

  @override
  String get ecgCheckPreviousEcgDesc => 'La comparaison est clé.';

  @override
  String get ecgChapterPWavePr => '3. Onde P & Intervalle PR';

  @override
  String get ecgChapterQrs => '4. Complexe QRS';

  @override
  String get ecgChapterStTWave => '5. Segment ST & Onde T';

  @override
  String get ecgChapterQtInterval => '6. Intervalle QT (QTc)';

  @override
  String get ecgChapterBlockHypertrophy => '7. Blocs & Hypertrophies';

  @override
  String get ecgChapterTerritories => '8. Territoires d\'Infarctus';

  @override
  String get ecgChapterElectrolytes => '9. Électrolytes & ECG';

  @override
  String get ecgStatusAnalyzed => 'ANALYSE';

  @override
  String get ecgStatusNoIschemia => 'PAS D\'ISCHÉMIE';

  @override
  String get ecgStatusAbsent => 'ABSENT';

  @override
  String get ecgStatusUnremarkable => 'UNREMARKABLE';

  @override
  String get ecgPWaveLeadII => 'Onde P (D2)';

  @override
  String get ecgCheckPMitrale => 'Durée P < 120ms ?';

  @override
  String get ecgCheckPMitraleDesc =>
      'Élargie : hypertrophie auriculaire gauche.';

  @override
  String get ecgCheckPPulmonale => 'Ampli P < 2.5mm ?';

  @override
  String get ecgCheckPPulmonaleDesc =>
      'Ample : hypertrophie auriculaire droite.';

  @override
  String get ecgPrInterval => 'Intervalle PR';

  @override
  String get ecgCheckPrDuration => 'PR entre 120-200ms ?';

  @override
  String get ecgCheckPrDurationDesc => 'Court : WPW. Long : BAV1.';

  @override
  String get ecgCheckQrsDuration => 'Durée < 120ms ?';

  @override
  String get ecgCheckQrsDurationDesc => 'Large : Bloc de Branche.';

  @override
  String get ecgCheckPathologicalQ => 'Onde Q absente ?';

  @override
  String get ecgCheckPathologicalQDesc => 'Signe de séquelle d\'infarctus.';

  @override
  String get ecgCheckQrsAmplitude => 'Amplitude QRS normale ?';

  @override
  String get ecgCheckQrsAmplitudeDesc => 'Bas voltage : épanchement.';

  @override
  String get ecgStSegmentIschemia => 'Segment ST';

  @override
  String get ecgCheckStIsoelectric => 'ST à la ligne isoélectrique ?';

  @override
  String get ecgCheckStIsoelectricDesc => 'Décalage = lésion myocardique.';

  @override
  String get ecgTWave => 'Onde T';

  @override
  String get ecgCheckTWaveUpright => 'T positive (sauf aVR/V1) ?';

  @override
  String get ecgCheckTWaveUprightDesc => 'Négative : ischémie.';

  @override
  String get ecgBazettCalculator => 'Bazett';

  @override
  String get ecgQtSmallSquares => 'QT (carreaux)';

  @override
  String get ecgWarningQtProlonged => 'ALERTE : QT allongé. Risque de TdP.';

  @override
  String get ecgCheckQtHalfRr => 'QT < moitié de R-R ?';

  @override
  String get ecgCheckQtHalfRrDesc => 'Règle visuelle rapide.';

  @override
  String get ecgBundleBranchBlocks => 'Blocs de Branche';

  @override
  String get ecgWilliamMarrow =>
      'Règle WiLLiaM MaRRoW :\n- W en V1, M en V6 -> BAVG\n- M en V1, W en V6 -> BAVD';

  @override
  String get ecgCheckV1MsShape => 'V1 : aspect rsR\' (M) ?';

  @override
  String get ecgCheckV1MsShapeDesc => 'Indique un BAVD.';

  @override
  String get ecgCheckV6SlurredS => 'V6 : onde S traînante ?';

  @override
  String get ecgCheckV6SlurredSDesc => 'Séquelle classique du BAVD.';

  @override
  String get ecgLeftVentricularHypertrophy => 'HVG';

  @override
  String get ecgCheckSokolowLyon => 'S V1 + R V5/V6 > 35mm ?';

  @override
  String get ecgCheckSokolowLyonDesc => 'Critère de HVG.';

  @override
  String get ecgCoronaryTerritories => 'Territoires Coronaires';

  @override
  String get ecgTerritoryMap =>
      'Inf : D2, D3, aVF\nLat : D1, aVL, V5, V6\nAnt : V1-V4';

  @override
  String get ecgElectrolytesTarget => 'Cible';

  @override
  String get ecgHyperkalemia => 'Hyperkaliémie :';

  @override
  String get ecgHyperkalemiaDesc => 'T pointues, QRS large.';

  @override
  String get ecgHypokalemia => 'Hypokaliémie :';

  @override
  String get ecgHypokalemiaDesc => 'Ondes U, T aplaties.';

  @override
  String get ecgCalciumTitle => 'Calcium (Ca2+)';

  @override
  String get ecgHypercalcemia => 'Hypercalcémie : QT court.';

  @override
  String get ecgHypocalcemia => 'Hypocalcémie : QT long.';

  @override
  String get ecgPdfCriteria => 'Critère';

  @override
  String get ecgPdfEvaluation => 'Évaluation';

  @override
  String get ecgPdfYes => 'Oui';

  @override
  String get ecgPdfNo => 'Non';

  @override
  String get ecgPdfUnanswered => 'Non répondu';

  @override
  String get ecgPdfResponses => 'Réponses d\'Interprétation';

  @override
  String get ecgPdfDisclaimer =>
      'Note : Ce rapport est pédagogique uniquement.';

  @override
  String get ecgAxisNormal => 'Axe Normal';

  @override
  String get ecgAxisLad => 'Déviation Gauche (LAD)';

  @override
  String get ecgAxisRad => 'Déviation Droite (RAD)';

  @override
  String get ecgAxisExtreme => 'Axe Extrême';

  @override
  String get ecgAxisIndeterminate => 'Indéterminé';

  @override
  String get ecgPdfDeducedAxis => 'Axe déduit';

  @override
  String get ecgBpm => 'BPM';

  @override
  String get ecgClear => 'Effacer';

  @override
  String get ecgPdfReportTitle => 'Rapport d\'Interprétation ECG';

  @override
  String get radInterpretationReport =>
      'Rapport d\'Interprétation Radiologique';

  @override
  String get radAnalysisReport => 'RAPPORT D\'ANALYSE RADIOLOGIQUE';

  @override
  String get radCase => 'Cas';

  @override
  String get radAiActive => 'IA ACTIVE';

  @override
  String get radEducationalTool => 'Outil Pédagogique Uniquement';

  @override
  String get radEducationalToolDesc =>
      'Destiné aux étudiants. Ce n\'est PAS un dispositif médical.';

  @override
  String get radShareReport => 'Partager';

  @override
  String get radGuidedInterpretation => 'Checklist d\'Interprétation Radio';

  @override
  String get radSourceTitle => 'Source de l\'Image';

  @override
  String get radSourceCamera => 'Appareil Photo';

  @override
  String get radSourceGallery => 'Galerie';

  @override
  String get radSourceDraw => 'Dessiner';

  @override
  String get radSourceClear => 'Effacer';

  @override
  String get radStatusNormal => 'NORMAL';

  @override
  String get radStatusStable => 'STABLE';

  @override
  String get radStatusClear => 'CLAIR';

  @override
  String get radChapterAirway => 'A - Airway (Voies Aériennes)';

  @override
  String get radChapterBreathing => 'B - Breathing (Poumons)';

  @override
  String get radChapterCirculation => 'C - Circulation (Cœur/Vaisseaux)';

  @override
  String get radChapterDiaphragm => 'D - Diaphragm (Diaphragme)';

  @override
  String get radChapterEverythingElse =>
      'E - Everything Else (Os & Parties Molles)';

  @override
  String get radCheckTracheaCentral => 'La trachée est-elle médiane ?';

  @override
  String get radCheckTracheaCentralDesc =>
      'Déviation vers la lésion (atélectasie) ou à l\'opposé (pneumothorax compressif).';

  @override
  String get radCheckLungsExpanded => 'Poumons bien expansés ?';

  @override
  String get radCheckLungsExpandedDesc =>
      'Au moins 10 arcs costaux postérieurs visibles.';

  @override
  String get radCheckCostophrenicAngles => 'Culs-de-sac libres ?';

  @override
  String get radCheckCostophrenicAnglesDesc =>
      'Un émoussement évoque une pleurésie.';

  @override
  String get radCheckHeartSize => 'Taille du cœur normale ?';

  @override
  String get radCheckHeartSizeDesc =>
      'L\'index cardio-thoracique (ICT) < 0.5 (en incidence de face).';

  @override
  String get radCheckDiaphragmPosition => 'Diaphragme en place ?';

  @override
  String get radCheckDiaphragmPositionDesc =>
      'Coupole droite plus haute (foie), convexité respectée.';

  @override
  String get radCheckBonesSoftTissues => 'Os et tissus mous normaux ?';

  @override
  String get radCheckBonesSoftTissuesDesc =>
      'Côtes, clavicules, emphysème sous-cutané.';

  @override
  String get radLearnMore => 'En savoir plus';

  @override
  String get radTipAirwayTitle => 'Analyse des Voies Aériennes';

  @override
  String get radTipAirwayDesc =>
      'Trachée médiane, carina visible. Une déviation peut indiquer un processus compressif ou rétractile.';

  @override
  String get radTipBreathingTitle => 'Évaluation Parenchymateuse';

  @override
  String get radTipBreathingDesc =>
      'Comparez les champs pulmonaires. Cherchez des opacités, hyperclartés ou lignes pleurales.';

  @override
  String get radTipCirculationTitle => 'Cœur & Médiastin';

  @override
  String get radTipCirculationDesc =>
      'ICT < 50%. Signe de la silhouette : effacement du bord droit = lésion du lobe moyen.';

  @override
  String get radTipDiaphragmTitle => 'Le Diaphragme';

  @override
  String get radTipDiaphragmDesc =>
      'Liberté des culs-de-sac. Air sous-coupoles = pneumopéritoine (urgence chirurgicale).';

  @override
  String get radTipEverythingElseTitle => 'Structures Extra-pulmonaires';

  @override
  String get radTipEverythingElseDesc =>
      'Inspectez les côtes (fractures, lyse) et les parties molles (emphysème). Tracé des drains/sondes.';

  @override
  String get radChapterDiagnosisGuide => 'Guide Diagnostic';

  @override
  String get radDiagnosisPneumonia => 'Pneumonie';

  @override
  String get radDiagnosisPneumoniaDesc =>
      'Opacité systématisée, limites floues, bronchogramme aérien.';

  @override
  String get radDiagnosisHeartFailure => 'OAP (Insuffisance Cardiaque)';

  @override
  String get radDiagnosisHeartFailureDesc =>
      'Cardiomégalie, lignes de Kerley B, ailes de papillon.';

  @override
  String get radDiagnosisPneumothorax => 'Pneumothorax';

  @override
  String get radDiagnosisPneumothoraxDesc =>
      'Hyperclarté avasculaire, ligne pleurale visible.';

  @override
  String get radDiagnosisEffusion => 'Pleurésie (Épanchement)';

  @override
  String get radDiagnosisEffusionDesc =>
      'Opacité basale, ligne de Damoiseau, émoussement des culs-de-sac.';

  @override
  String get radDiagnosisAtelectasis => 'Atélectasie (Collapsus)';

  @override
  String get radDiagnosisAtelectasisDesc =>
      'Perte de volume, attraction du médiastin, déviation scissurale.';

  @override
  String get radSyndromeParietal => 'Syndrome Pariétal';

  @override
  String get radSyndromeParietalDesc =>
      '**Définition** :\nL’ensemble des signes radiologiques correspondant à une lésion de la paroi thoracique (parties molles ou os).\n\n**Sémiologie radiologique** :\n* **Parties molles** : Opacité périphérique de densité hydrique, homogène, contour net si tangentiel, raccordement en \'pente douce\'.\n* **Lésions osseuses** : Ostéolytiques ou condensantes (lyse osseuse, érosion costale type encoche, fracture pathologique).\n\n**Description des images (Sémiologie Illustrée)** :\n* **Opacité périphérique** : Densité hydrique, homogène.\n* **Raccordement à la paroi** : En pente douce avec un angle de raccordement obtus.\n* **Signe du liseré pleural** : Interface nette avec le parenchyme pulmonaire.\n* **Dimensions** : Diamètre horizontal (base) de l\'opacité presque aussi grand que son diamètre vertical.\n* **Signes associés** : Lésions osseuses (lyse costale) often présentes ; l\'opacité est solidaire des mouvements du gril costal.';

  @override
  String get radSyndromePleural => 'Syndrome Pleural';

  @override
  String get radSyndromePleuralDesc =>
      '**Définition** :\nSignes traduisant la présence de liquide, d’air ou de tissu anormal entre les feuillets pleuraux.\n\n**Sémiologie** :\n* **Épanchement liquidien libre (Pleurésie)** : Opacité basale en nappe, efface les culs-de-sac. Courbe de Damoiseau (concave vers le haut). Mobile with le changement de position. Sans bronchogramme.\n* **Pneumothorax (Air)** : Hyperclarté périphérique avasculaire (zone noire sans trame), ligne de la plèvre viscérale (ligne bordante fine).\n* **Hydro-pneumothorax** : Niveau hydro-aérique horizontal.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Ligne de Damoisseau** : Limite supérieure concave en haut et en dedans de l\'épanchement liquidien.\n* **Hyperclarté avasculaire** : Zone noire sans aucune trame vasculaire (PNX).\n* **Ligne bordante** : Fine ligne correspondant à la plèvre viscérale limitant le poumon rétracté vers le hile.';

  @override
  String get radSyndromeAlveolar => 'Syndrome Alvéolaire';

  @override
  String get radSyndromeAlveolarDesc =>
      '**Définition** :\nComblement des alvéoles par du liquide (eau, pus, sang) ou des cellules.\n\n**Sémiologie caractéristique** :\n* **Opacité de densité hydrique**.\n* **Limites floues** (sauf si contre une scissure).\n* **Confluence** (diffusion par les pores de Kohn).\n* **Systématisation** (territoire anatomique précis).\n* **Bronchogramme aérien** : Bronches aérées au sein de l\'opacité.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Aspect nuageux ou cotonneux** : Opacités à bords flous typiques.\n* **Confluence** : Tendance des lésions à se rejoindre.\n* **Bronchogramme & Alvéologramme** : Visibilité des bronches et alvéoles claires au sein de l\'opacité blanche.\n* **Ailes de papillon** : Opacités péri-hilaires symétriques respectant la périphérie (OAP).';

  @override
  String get radSyndromeInterstitial => 'Syndrome Interstitiel';

  @override
  String get radSyndromeInterstitialDesc =>
      '**Définition** :\nPrésence de liquide ou de cellules anormales dans l’interstitiel pulmonaire.\n\n**Caractères sémiologiques** :\n* **Limites nettes**.\n* **Non confluent**, non systématisé.\n* **Sans bronchogramme aérien**.\n* Évolution lente.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Lignes de Kerley (B)** : Épaississements des septums visibles à la base comme de courtes lignes horizontales.\n* **Réticulations** : Aspect en \'maille de filet\'.\n* **Verre dépoli** : Augmentation discrète de la densité pulmonaire n\'effaçant pas les vaisseaux.\n* **Rayon de miel (Honeycombing)** : Petites clartés kystiques groupées (stade terminal de fibrose).';

  @override
  String get radSyndromeBronchial => 'Syndrome Bronchique';

  @override
  String get radSyndromeBronchialDesc =>
      '**Définition** :\nEnsemble des signes liés à une pathologie des bronches (épaississement, dilatation ou obstruction).\n\n**Signes directs** :\n* **Rails et Anneaux** : Épaississement des parois bronchiques.\n* **Bague à chaton** : Diamètre bronchique > Diamètre de l\'artère adjacente.\n\n**Signes indirects** :\n* **Atélectasie** : Opacité rétractile systématisée.\n* **Piégeage** : Hyperclarté localisée à l\'expiration.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Signe des rails** : Épaississement des parois en vue longitudinale.\n* **Signe des anneaux** : Épaississement des parois en vue transversale.\n* **Signe de la bague à chaton** : Dilatation des bronches (DDB) avec diamètre bronchique supérieur à l\'artère.\n* **Opacité rétractile** : Atélectasie avec attraction du médiastin et déplacement des scissures vers la lésion.';

  @override
  String get radSyndromeCavitary => 'Syndrome Cavitaire';

  @override
  String get radSyndromeCavitaryDesc =>
      '**Définition** :\nPrésence d’une clarté (cavité) au sein d’une zone d’opacité ou du parenchyme.\n\n**Sémiologie** :\n* **Paroi** : Épaisseur fixe ou variable. Fine (< 3mm) ou épaisse (> 15mm).\n* **Niveau hydro-aérique** : Ligne horizontale (air au-dessus, liquide en dessous).\n* **Grelot** : Masse mobile à l\'intérieur de la cavité.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Image de clarté** : Zone de transparence (noire) au sein du parenchyme.\n* **Niveau hydro-aérique** : Ligne horizontale stricte entre air et liquide.\n* **Image en grelot** : Masse mobile (ex: aspergillome) au sein d\'une cavité.\n* **Image en nénuphar** : Membrane flottante typique d\'un kyste hydatique rompu.';

  @override
  String get radSyndromeMediastinal => 'Syndrome Médiastinal';

  @override
  String get radSyndromeMediastinalDesc =>
      '**Définition** :\nSignes traduisant la présence d\'une masse ou d\'un épanchement dans le médiastin.\n\n**Signes de localisation** :\n* **Bord externe net et convexe** vers le poumon.\n* **Signe de la silhouette** : Effacement d\'un bord au contact d\'une structure de même densité.\n* **Signe de l\'iceberg** : Masse thoraco-abdominale s\'écartant du rachis.\n\n**Description des images (Sémiologie Illustrée)** :\n* **Signe de la silhouette** : Effacement des bords entre deux structures de même densité au contact.\n* **Signe cervico-thoracique** : Opacité dépassant le bord supérieur de la clavicule (indique une position postérieure).\n* **Signe de l\'iceberg (thoraco-abdominal)** : Masse s\'écartant du rachis sous le diaphragme.\n* **Signe du recouvrement hilaire** : Visibilité des vaisseaux à travers l\'opacité (indique une position ant/post au hile).';

  @override
  String get radResetFindings => 'Réinitialiser les signes';

  @override
  String get radTechnicalQuality => 'Évaluation de la Qualité (CRIP)';

  @override
  String get radDifferentialDiagnosis => 'Diagnostics Différentiels';

  @override
  String get radCommonEtiologies => 'Étiologies communes';

  @override
  String get radRelatedSyndromes => 'Relatif aux syndromes :';

  @override
  String get radSemiologySigns => 'Sémiologie (Signes)';

  @override
  String get radClinicalPearls => 'Perles Cliniques';

  @override
  String get radSyndromeProbabilityAnalysis =>
      'Analyse de Probabilité Syndromique';

  @override
  String radSignsCount(Object score, Object total) {
    return '$score/$total signes';
  }

  @override
  String radObjective(Object target) {
    return 'Objectif : $target';
  }

  @override
  String get radSemiologyCourse => 'Cours de Sémiologie';

  @override
  String get labAnalysisReport => 'RAPPORT D\'ANALYSE BIOLOGIQUE';

  @override
  String get labGuidedInterpretation => 'Checklist d\'Interprétation Bio';

  @override
  String get labChapterHematology => 'Hématologie (NFS)';

  @override
  String get labChapterElectrolytes => 'Ionogramme Sanguin';

  @override
  String get labChapterBloodGas => 'Gaz du Sang';

  @override
  String get labChapterRenal => 'Fonction Rénale';

  @override
  String get labChapterHepatic => 'Bilan Hépatique';

  @override
  String get labChapterInflammatory => 'Bilan Inflammatoire';

  @override
  String get labCheckAnemia => 'Hémoglobine (Anémie ?)';

  @override
  String get labCheckAnemiaDesc =>
      'Diminution de l\'Hb selon l\'âge et le sexe.';

  @override
  String get labCheckPlq => 'Plaquettes (Hémostase ?)';

  @override
  String get labCheckPlqDesc =>
      'Rechercher une thrombopénie ou hyperthrombocytose.';

  @override
  String get labCheckK => 'Potassium (Dyskaliémie ?)';

  @override
  String get labCheckKDesc => 'Urgence vitale si anomalie sévère (ECG).';

  @override
  String get labCheckNa => 'Natrémie (Hydratation ?)';

  @override
  String get labCheckNaDesc =>
      'Reflet de l\'état d\'hydratation intracellulaire.';

  @override
  String get labCheckCreat => 'Créatinine (DFG ?)';

  @override
  String get labCheckCreatDesc =>
      'Évaluer la fonction rénale et le débit de filtration.';

  @override
  String get labCheckCRP => 'CRP (Inflammation ?)';

  @override
  String get labCheckCRPDesc => 'Marqueur rapide de l\'inflammation aiguë.';

  @override
  String get labCheckPH => 'pH et Gaz du sang';

  @override
  String get labCheckPHDesc => 'Rechercher une acidose ou alcalose.';

  @override
  String get labCheckLiver => 'Transaminases (Cytolyse ?)';

  @override
  String get labCheckLiverDesc => 'Augmentation des ALAT/ASAT.';

  @override
  String get labCheckCholestasis => 'PAL / GGT (Cholestase ?)';

  @override
  String get labCheckCholestasisDesc => 'Obstruction ou atteinte biliaire.';

  @override
  String get labTipHematologyTitle => 'Analyse de la NFS';

  @override
  String get labTipHematologyDesc =>
      'L\'hémoglobine définit l\'anémie. Les VGM/CCMH orientent le diagnostic. Les plaquettes sont vitales pour l\'hémostase.';

  @override
  String get labTipElectrolytesTitle => 'L\'Ionogramme';

  @override
  String get labTipElectrolytesDesc =>
      'Le potassium (K+) est le plus dangereux. Le sodium (Na+) reflète l\'eau. Toujours vérifier la fonction rénale associée.';

  @override
  String get labTipInflammatoryTitle => 'Marqueurs de l\'Inflammation';

  @override
  String get labTipInflammatoryDesc =>
      'La CRP monte vite et baisse vite. La VS est plus lente. Une hyperleucocytose à PNN oriente vers une infection bactérienne.';

  @override
  String get labSyndromeInflammatory => 'Syndrome Inflammatoire';

  @override
  String get labSyndromeAnemia => 'Anémie';

  @override
  String get labSyndromeThrombopenia => 'Thrombopénie';

  @override
  String get labSyndromeHyperkalemia => 'Hyperkaliémie';

  @override
  String get labSyndromeHypokalemia => 'Hypokaliémie';

  @override
  String get labSyndromeIRA => 'Insuffisance Rénale Aiguë';

  @override
  String get labSyndromeAcidosis => 'Acidose Métabolique';

  @override
  String get labSyndromeDehydration => 'Déshydratation';

  @override
  String get labSyndromeCholestasis => 'Cholestase';

  @override
  String get labSyndromeCytolysis => 'Cytolyse Hépatique';

  @override
  String get labResetFindings => 'Réinitialiser les résultats';

  @override
  String get labEncyclopedia => 'Encyclopédie Biologie';

  @override
  String get labEncyclopediaDesc => '250 examens de laboratoire détaillés';

  @override
  String get labChapterGasometry => 'Gaz du Sang (GDS)';

  @override
  String get labChapterHepatorenal => 'Bilan Hépatique & Rénal';

  @override
  String get labTipGasometryTitle => 'Gaz du Sang Artériels';

  @override
  String get labTipGasometryDesc =>
      'pH < 7.35 = acidose. Vérifier si métabolique (HCO3- bas) ou respiratoire (pCO2 élevé). Les lactates élevés signalent une hypoperfusion.';

  @override
  String get labTipHepatorenalTitle => 'Bilan Hépatique & Rénal';

  @override
  String get labTipHepatorenalDesc =>
      'ASAT > ALAT oriente vers une cause alcoolique. GGT isolée : alcool ou médicaments. Créatinine élevée : toujours vérifier urée et diurèse.';

  @override
  String get labSyndromeProbability => 'Analyse des Probabilités Syndromiques';

  @override
  String get labCommonEtiologies => 'Étiologies communes';

  @override
  String get labRelatedSyndromes => 'Relatif aux syndromes :';

  @override
  String get viewInEncyclopedia => 'Voir dans l\'encyclopédie';

  @override
  String get labNormalValues => 'Valeurs Normales';

  @override
  String get searchParameter => 'Rechercher un paramètre...';

  @override
  String get unitSI => 'Unité SI';

  @override
  String get unitTrad => 'Unité Trad.';

  @override
  String get paramReference => 'Feuille de Référence';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get notificationToday => 'Aujourd\'hui';

  @override
  String get notificationYesterday => 'Hier';

  @override
  String get notificationEarlier => 'Plus tôt';

  @override
  String get noNotificationsTitle => 'Tout est à jour !';

  @override
  String get noNotificationsSubtitle =>
      'Vous n\'avez aucune nouvelle notification.';

  @override
  String get notificationTypeContent => 'Contenu';

  @override
  String get notificationTypeCommunity => 'Communauté';

  @override
  String get notificationTypePerformance => 'Performance';

  @override
  String get notificationTypeSystem => 'Système';

  @override
  String get clearAllNotifications => 'Tout effacer';

  @override
  String get clearAllNotificationsConfirmation =>
      'Êtes-vous sûr de vouloir supprimer définitivement toutes vos notifications ?';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get markRead => 'Marquer comme lu';

  @override
  String get markUnread => 'Marquer comme non lu';

  @override
  String get studyGroups => 'Groupes d\'Étude';

  @override
  String get available => 'DISPONIBLES';

  @override
  String get myProgression => 'MA PROGRESSION';

  @override
  String get createGroup => 'CRÉER UN GROUPE';

  @override
  String get popularRooms => 'SALLES POPULAIRES';

  @override
  String get recommendedRooms => 'SALLES RECOMMANDÉES';

  @override
  String get joinRoom => 'REJOINDRE';

  @override
  String get members => 'MEMBRES';

  @override
  String get pomodoros => 'POMODOROS';

  @override
  String get details => 'DÉTAILS';

  @override
  String get waitingForSession => 'Attente d\'une session';

  @override
  String get adminWillStartSession =>
      'L\'administrateur va bientôt lancer un duel d\'étude. Préparez-vous !';

  @override
  String get theoreticalOnly => 'Théorique uniquement';

  @override
  String get clinicalOnly => 'Clinique uniquement';

  @override
  String get selectStudyYear => 'Choisir l\'année d\'étude';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get descriptionHint => 'Description (Objectif, spécialité...)';

  @override
  String get groupColor => 'Couleur du groupe';

  @override
  String get createRoom => 'CRÉER LA SALLE';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get liveSession => 'SESSION EN DIRECT';

  @override
  String get liveQuizBattles => 'Duels de Quiz en Cours';

  @override
  String get inviteFriend => 'Inviter un ami';

  @override
  String get startGStudy => 'LANCER UNE SESSION G-STUDY';

  @override
  String get liveQuizBattleInfo => 'Quiz Battle en Direct • +500 XP';

  @override
  String get liveFocus => 'FOCUS EN DIRECT';

  @override
  String get groupGoals => 'OBJECTIFS DU GROUPE';

  @override
  String get meducytesWall => 'MUR DES MEDUCYTES';

  @override
  String get sendEncouragement => 'Envoyer un encouragement...';

  @override
  String get you => 'Vous';

  @override
  String get aloneInBattle => 'Seul au combat pour l\'instant...';

  @override
  String get liveBattle => 'BATTLE EN DIRECT';

  @override
  String questionOf(Object current, Object total) {
    return 'QUESTION $current SUR $total';
  }

  @override
  String yourScore(Object score) {
    return 'VOTRE SCORE: $score';
  }

  @override
  String get excellent => 'EXCELLENT !';

  @override
  String get oopsNotQuite => 'OUPS, PAS TOUT À FAIT...';

  @override
  String get preparingBattle => 'PRÉPARATION DE LA BATTLE...';

  @override
  String get battleAboutToStart => 'LA BATTLE VA COMMENCER';

  @override
  String get getReadyTenQuestions =>
      'Préparez-vous ! 10 Questions sur le module';

  @override
  String participantsReady(Object count) {
    return '$count Participants prêts';
  }

  @override
  String get battleFinished => 'BATTLE TERMINÉE !';

  @override
  String get backToGroup => 'RETOUR AU GROUPE';

  @override
  String get searchByNameOrEmail => 'Rechercher par nom ou email...';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get invitationSent => 'Invitation envoyée !';

  @override
  String get invitationError => 'Erreur lors de l\'invitation';

  @override
  String get invite => 'INVITER';

  @override
  String get selectTopic => 'Sélectionner un Sujet';

  @override
  String get chooseModuleForBattle => 'Choisissez un module pour la Battle';

  @override
  String get searchRoomHint => 'Rechercher une salle ou un sujet...';

  @override
  String get recommendedForYou => 'RECOMMANDÉ POUR VOUS';

  @override
  String get onlineSuffix => 'EN LIGNE';

  @override
  String get yourSummary => 'VOTRE RÉSUMÉ';

  @override
  String get myActiveGroups => 'MES GROUPES ACTIFS';

  @override
  String get noActiveGroups => 'AUCUN GROUPE ACTIF';

  @override
  String get pomodorosToday => 'Pomodoros récoltés aujourd\'hui';

  @override
  String get syncingStats =>
      'Statistiques globales en cours de synchronisation...';

  @override
  String get silent => 'Silencieux';

  @override
  String get focus => 'Focus';

  @override
  String get qcmBattle => 'QCM Battle';

  @override
  String get categoryMedicine => 'Médecine';

  @override
  String get categorySurgery => 'Chirurgie';

  @override
  String get categoryGyneco => 'Gynéco';

  @override
  String get categoryPaces => 'PACES';

  @override
  String get categoryExam => 'Concours';

  @override
  String get roomNameLabel => 'NOM DE LA SALLE';

  @override
  String get descriptionOptional => 'DESCRIPTION (OPTIONNEL)';

  @override
  String get sessionType => 'TYPE DE SESSION';

  @override
  String get themeColorLabel => 'COULEUR DU THÈME';

  @override
  String get medicalCategory => 'CATÉGORIE MÉDICALE';

  @override
  String get roomCreatedSuccess => 'SALLE CRÉÉE AVEC SUCCÈS';

  @override
  String get roomCreationError => 'ERREUR LORS DE LA CRÉATION';

  @override
  String get topRated => 'TOP RATED';

  @override
  String get trending => 'TRENDING';

  @override
  String get allCaps => 'TOUT';

  @override
  String get activeSession => 'SESSION ACTIVE';

  @override
  String participantsCount(Object count) {
    return '$count Méducytes en bataille';
  }

  @override
  String get beFirstToEncourage => 'SOYEZ LE PREMIER À ENCOURAGER LE GROUPE !';

  @override
  String get groupTypeLabel => 'TYPE';

  @override
  String inProgressCount(Object count) {
    return '$count EN COURS';
  }

  @override
  String get aiOptimizedPlanning =>
      'L\'IA a optimisé votre planning selon vos points faibles et vos examens.';

  @override
  String daysRemaining(Object days) {
    return 'J-$days';
  }

  @override
  String get applyPlanning => 'Appliquer ce planning';

  @override
  String get nextSession => 'PROCHAINE SESSION';

  @override
  String get noSession => 'Aucune session';

  @override
  String get noUrgentTask => 'Aucune tâche urgente';

  @override
  String get days => 'Jours';

  @override
  String get nextExam => 'PROCHAIN EXAMEN';

  @override
  String get setExamDate => 'Définir la date de l\'examen';

  @override
  String get editExam => 'Modifier l\'examen';

  @override
  String get selectDateAndHour => 'Choisir date et heure';

  @override
  String get examTitle => 'Titre de l\'examen';

  @override
  String get noExam => 'Aucun examen';

  @override
  String get pomodoroLabel => 'POMODORO';

  @override
  String get personalization => 'Personnalisation';

  @override
  String get pomodoroWork => 'Focus';

  @override
  String get done => 'Terminé';

  @override
  String get errorLabel => 'Erreur';

  @override
  String get newStudyModuleTask => 'Nouveau module d\'étude';

  @override
  String get addSmartTask => 'Ajouter une tâche intelligente';

  @override
  String get urgentLabel => 'URGENT';

  @override
  String get examLabel => 'EXAMEN';

  @override
  String get optionalLabel => 'OPTIONNEL';

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String get taskDeselected => 'Tâche déselectionnée';

  @override
  String focusOnTask(Object task) {
    return 'Focus sur : $task';
  }

  @override
  String get optimalConcentrationMsg =>
      'Concentration optimale. Continuez sur la Cardiologie pendant encore 45 min.';

  @override
  String get loadLabel => 'Charge';

  @override
  String get capacityLabel => 'Capacité';

  @override
  String get breakDueLabel => 'Prochaine pause';

  @override
  String get focusPeak => 'Focus Peak';

  @override
  String get focusStable => 'Focus Stable';

  @override
  String get lightFatigue => 'Fatigue Légère';

  @override
  String get burnoutRisk => 'Burnout Risk';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noPriorityTask => 'Aucune tâche prioritaire';

  @override
  String get studyStreak => 'Série d\'étude';

  @override
  String get pomodoroToday => 'Pomodoro Aujourd\'hui';

  @override
  String get totalHours => 'Heures Totales';

  @override
  String get moduleEfficiency => 'Efficacité par Module';

  @override
  String get wind => 'Vent';

  @override
  String get cafe => 'Café';

  @override
  String get library => 'Bibliothèque';

  @override
  String get brownNoise => 'Bruit Brun';

  @override
  String get productiveBayTitle => 'La Baie Productive';

  @override
  String get searchError => 'Erreur lors de la recherche';

  @override
  String get editSession => 'Modifier la séance';

  @override
  String get planSession => 'Planifier la séance';

  @override
  String get weeklyPriorityObjectives => 'OBJECTIFS PRIORITAIRES DE LA SEMAINE';

  @override
  String get weeklyObjectives => 'Objectifs de la semaine';

  @override
  String get confidenceLevelQuestion => 'Quel est votre taux de confiance ?';

  @override
  String get difficultConceptQuestion =>
      'Le concept le plus difficile aujourd\'hui ?';

  @override
  String get finishSession => 'Finaliser la séance';

  @override
  String get startQuickRevision => 'Démarrer la révision rapide';

  @override
  String get customizeHub => 'Personnaliser le Hub';

  @override
  String get noDescription => 'Pas de description';

  @override
  String get groupGoalsHint => 'Objectifs, règles de la salle...';

  @override
  String get yearLabel => 'Année';

  @override
  String get monthlyView => 'Vue Mensuelle';

  @override
  String get weeklyView => 'Vue Hebdomadaire';

  @override
  String get dailyView => 'Vue Journalière';

  @override
  String get newSession => 'Nouvelle Séance';

  @override
  String get studySubject => 'Sujet d\'étude';

  @override
  String get subjectHint => 'Sujet (ex: Cardiologie)';

  @override
  String get startTime => 'Début';

  @override
  String get endTime => 'Fin';

  @override
  String get deleteLabel => 'Supprimer';

  @override
  String get typeLabel => 'Type';

  @override
  String get colorLabel => 'Couleur';

  @override
  String weekLabel(Object end, Object start) {
    return 'Semaine $start - $end';
  }

  @override
  String get defaultObjective1 => 'Maîtriser les blocs de branche (ECG)';

  @override
  String get defaultObjective2 => 'Terminer le module Pneumologie';

  @override
  String get defaultObjective3 => 'Pratiquer 50 QCM Cardiologie';

  @override
  String aiPrefix(Object title) {
    return 'IA : $title';
  }

  @override
  String get highPriorityTaskReason => 'Tâche prioritaire à réaliser bientôt';

  @override
  String get optimalTimeReason => 'Moment optimal pour cette tâche';

  @override
  String get noTasksReason =>
      'Aucune tâche en attente. C\'est le moment de découvrir de nouveaux modules !';

  @override
  String get exploreModulesTitle => 'Découvrir de nouveaux modules';

  @override
  String get exportPlannerTitle => 'Exportation Planning Clinique';

  @override
  String get clinicalRevisionPlanner => 'PLANIFICATEUR DE RÉVISION CLINIQUE';

  @override
  String weekOf(Object date) {
    return 'Semaine du $date';
  }

  @override
  String get hourTitle => 'HEURE';

  @override
  String get clinicalNotesReminders => 'NOTES CLINIQUES & RAPPELS';

  @override
  String get intensityTrackerAi => 'TRACKER D\'INTENSITÉ (IA)';

  @override
  String get authWelcomeTitle => 'Meducyte';

  @override
  String get authWelcomeSubtitle =>
      'Votre voyage vers l\'excellence clinique commence ici.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'dr.meducyte@exemple.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authOr => 'OU';

  @override
  String get authContinueGoogle => 'Google';

  @override
  String get authContinueApple => 'Apple';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String authSocialSoon(Object platform) {
    return 'Connexion $platform bientôt disponible';
  }

  @override
  String get authBiometricSuccess => 'Authentification biométrique réussie';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateAccountSub =>
      'Votre parcours vers la maîtrise clinique commence.';

  @override
  String get authStudySchedule => 'Définissez votre planning d\'étude';

  @override
  String get authStudyScheduleSub =>
      'La régularité est la clé de la réussite au résidanat.';

  @override
  String get authDailyStartTime => 'Début de l\'étude quotidienne';

  @override
  String get authTargetDuration => 'Durée d\'étude visée';

  @override
  String get authHours => 'HEURES';

  @override
  String get authMinutes => 'MINUTES';

  @override
  String authDailyCommitment(Object time) {
    return 'Engagement quotidien fixé pour $time.';
  }

  @override
  String authStudyGoal(Object h, Object m) {
    return 'Objectif : ${h}h ${m}m d\'étude ciblée.';
  }

  @override
  String get authInterests => 'Quels sont vos intérêts médicaux ?';

  @override
  String get authInterestsSub =>
      'Sélectionnez tout ce qui s\'applique pour personnaliser votre flux.';

  @override
  String get authMedicalSpec => 'Spécialités Médicales';

  @override
  String get authSurgicalSpec => 'Spécialités Chirurgicales';

  @override
  String get authOtherDisciplines => 'Autres Disciplines';

  @override
  String get authLearningStyleSub =>
      'Choisissez ce qui correspond le mieux à votre style d\'apprentissage.';

  @override
  String get authPasswordStrength => 'Force du mot de passe';

  @override
  String get authStrengthWeak => 'Faible';

  @override
  String get authStrengthFair => 'Moyen';

  @override
  String get authStrengthGood => 'Bon';

  @override
  String get authStrengthStrong => 'Très fort';

  @override
  String get authStrengthNone => 'Aucun';

  @override
  String authStrengthLabel(Object label) {
    return 'Force : $label';
  }

  @override
  String get authGoalTitle => 'Quel est votre objectif ?';

  @override
  String get authGoalAce => 'Réussir mes EMD et mon Concours de Résidanat';

  @override
  String get authGoalUnderstand =>
      'Approfondir mes connaissances médicales (Programme National)';

  @override
  String get authGoalPractical => 'Développer mes compétences cliniques au CHU';

  @override
  String get authGoalHabit => 'Instaurer une discipline d\'étude quotidienne';

  @override
  String get authHeardFromTitle => 'Comment nous avez-vous connus ?';

  @override
  String get authHeardFriend => 'Par un collègue / ami';

  @override
  String get authHeardSocial => 'Réseaux Sociaux';

  @override
  String get authHeardSchool => 'Ma Faculté / Mon CHU';

  @override
  String get authHeardOther => 'Autre source';

  @override
  String get authQuizPreferenceTitle => 'Quiz et Apprentissage';

  @override
  String get authQuizDaily => 'Quiz Quotidiens';

  @override
  String get authQuizWeekly => 'Quiz Hebdomadaires';

  @override
  String get authQuizVideo => 'Apprentissage Vidéo';

  @override
  String get authQuizPdf => 'Notes PDF';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authEmail => 'Email';

  @override
  String get authYear => 'Année';

  @override
  String get authSelectYear => 'Sélectionner l\'année';

  @override
  String get authMobileOptional => 'Téléphone (optionnel)';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authPassAtLeast8 => 'Au moins 8 caractères';

  @override
  String get authPassUppercase => 'Une lettre majuscule';

  @override
  String get authPassNumber => 'Un chiffre';

  @override
  String get authPassSpecial => 'Un caractère spécial (!@#\$^*~)';

  @override
  String get authAcceptTerms => 'J\'accepte les ';

  @override
  String get authTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get authPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get authAnd => ' et ';

  @override
  String get authBack => 'Retour';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authFinish => 'Terminer';

  @override
  String get authVerifyEmail => 'Vérifier l\'email';

  @override
  String get authResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get authVerifyYourEmail => 'Vérifiez votre email';

  @override
  String get authResetYourPassword => 'Réinitialisez votre mot de passe';

  @override
  String get authEnterOtp => 'Entrez le code OTP à 6 chiffres envoyé à :';

  @override
  String get authNoCode => 'Vous n\'avez pas reçu le code ?';

  @override
  String authResendIn(Object seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get authResendOtp => 'Renvoyer le code OTP';

  @override
  String get authInvalidOtp =>
      'Veuillez entrer un code OTP valide à 6 chiffres';

  @override
  String get authEmailVerified => 'Email vérifié avec succès !';

  @override
  String get authOtpVerified =>
      'OTP vérifié ! Définissez votre nouveau mot de passe.';

  @override
  String get authOtpSent => 'Code OTP envoyé avec succès !';

  @override
  String get authPrivacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get authPrivacySection1Title => '1. Collecte des données';

  @override
  String get authPrivacySection1Content =>
      'Nous recueillons les informations que vous nous fournissez directement, telles que votre nom, votre adresse e-mail et votre spécialité médicale lors de la création de votre compte. Nous collectons également des données sur votre progression pour personnaliser votre expérience.';

  @override
  String get authPrivacySection2Title => '2. Utilisation des données';

  @override
  String get authPrivacySection2Content =>
      'Vos informations sont utilisées pour fournir et améliorer nos services, suivre votre progression académique et proposer des recommandations d\'étude basées sur l\'IA. Vos données ne sont jamais vendues.';

  @override
  String get authPrivacySection3Title => '3. Sécurité des informations';

  @override
  String get authPrivacySection3Content =>
      'Nous mettons en œuvre des mesures de sécurité rigoureuses pour protéger vos données contre tout accès non autorisé. La confidentialité de votre parcours académique est notre priorité.';

  @override
  String get authPrivacySection4Title => '4. Vos Droits';

  @override
  String get authPrivacySection4Content =>
      'Vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données personnelles via les paramètres de votre compte.';

  @override
  String get authPrivacySection5Title => '5. Contact';

  @override
  String get authPrivacySection5Content =>
      'Pour toute question concernant cette politique, contactez-nous à contact@meducyte.com.';

  @override
  String get authPrivacyLastUpdated => 'Dernière mise à jour : Octobre 2023';

  @override
  String get authTermsOfUseTitle =>
      'Conditions d\'utilisation (Usage Conditions)';

  @override
  String get authTermsSection1Title => '1. Acceptation des conditions';

  @override
  String get authTermsSection1Content =>
      'En accédant à Meducyte, vous acceptez d\'être lié par les présentes conditions. Si vous ne les acceptez pas, nous vous prions de ne pas utiliser nos services.';

  @override
  String get authTermsSection2Title => '2. Avis Médical (Avertissement)';

  @override
  String get authTermsSection2Content =>
      'Meducyte est un outil pédagogique complémentaire. Il ne remplace en aucun cas l\'avis, le diagnostic ou le traitement d\'un médecin qualifié. Pour toute question médicale, consultez toujours un professionnel de santé.';

  @override
  String get authTermsSection3Title => '3. Comptes Utilisateurs';

  @override
  String get authTermsSection3Content =>
      'Vous êtes responsable du maintien de la confidentialité de votre compte et de votre mot de passe. Vous vous engagez à fournir des informations exactes.';

  @override
  String get authTermsSection4Title => '4. Propriété Intellectuelle';

  @override
  String get authTermsSection4Content =>
      'L\'intégralité du contenu (quiz, graphiques, notes de cours) est la propriété de Meducyte. Toute reproduction non autorisée est strictement interdite.';

  @override
  String get authTermsSection5Title => '5. Responsabilité';

  @override
  String get authTermsSection5Content =>
      'Meducyte ne pourra être tenu responsable des dommages indirects résultant de l\'utilisation ou de l\'incapacité d\'utiliser nos services académiques.';

  @override
  String get authTermsLastUpdated => 'Dernière mise à jour : Octobre 2023';

  @override
  String get authFaculteTitle => 'Quelle Faculté / CHU fréquentez-vous ?';

  @override
  String get authFaculteSub =>
      'Meducyte est actuellement exclusif aux étudiants de Constantine pour un alignement CHU optimal.';

  @override
  String get authClinicalStageTitle => 'Dans quel service (Stage) êtes-vous ?';

  @override
  String get authClinicalStageSub =>
      'Cela priorise les cas cliniques et les flashcards pour votre service hospitalier actuel.';

  @override
  String get authExamDateTitle => 'Quand est votre prochain examen majeur ?';

  @override
  String get authExamDateSub =>
      'Fixez un compte à rebours pour votre prochain EMD ou Concours pour bâtir votre plan d\'étude.';

  @override
  String get authCurrentFocusTitle => 'Que révisez-vous en ce moment ?';

  @override
  String get authCurrentFocusSub =>
      'Sélectionnez le module que vous préparez actuellement pour l\'EMD de votre CHU.';

  @override
  String get authDailyChallengeTitle => 'Activer l\'EMD du Jour ?';

  @override
  String get authDailyChallengeSub =>
      'Recevez une question clinique à haut rendement chaque jour à l\'heure de votre choix.';

  @override
  String get authCommunityTitle => 'Afficher votre profil à votre Faculté ?';

  @override
  String get authCommunitySub =>
      'Rejoignez les groupes d\'étude de votre CHU et voyez qui d\'autre révise le même module.';

  @override
  String get authStatusExtern => 'Externe (4ème-6ème Année)';

  @override
  String get authStatusIntern => 'Interne (7ème Année)';

  @override
  String get authStatusResident => 'Résident';

  @override
  String get authStatusDoctor => 'Médecin Généraliste';

  @override
  String get authStageCardio => 'Cardiologie';

  @override
  String get authStageSurgery => 'Chirurgie';

  @override
  String get authStagePediatrics => 'Pédiatrie';

  @override
  String get authStageInternal => 'Médecine Interne';

  @override
  String get authStageGyneco => 'Gynécologie & Obstétrique';

  @override
  String get authStageEmergency => 'Urgences / Réanimation';

  @override
  String get authExamEMD => 'Prochain EMD';

  @override
  String get authExamConcours => 'Concours de Résidanat';

  @override
  String get authFaculteAlgiers => 'Faculté d\'Alger';

  @override
  String get authFaculteOran => 'Faculté d\'Oran';

  @override
  String get authFaculteConstantine => 'Faculté de Constantine';

  @override
  String get authFaculteAnnaba => 'Faculté d\'Annaba';

  @override
  String get authFaculteSetif => 'Faculté de Sétif';

  @override
  String get authFaculteTizi => 'Faculté de Tizi Ouzou';

  @override
  String get authFaculteOther => 'Autre Faculté';

  @override
  String get authHowHeardTitle => 'Comment nous avez-vous connus ?';

  @override
  String get authHowHeardSub =>
      'Aidez-nous à faire grandir la communauté Meducyte pour tous les étudiants.';

  @override
  String get authIdentityTitle => 'Meducyte Identity';

  @override
  String get authIdentitySub =>
      'Créez votre persona Notion-style pour votre profil.';

  @override
  String get authIdentityTabHead => 'Forme';

  @override
  String get authIdentityTabHair => 'Coiffure';

  @override
  String get authIdentityTabFace => 'Visage';

  @override
  String get authIdentityTabColor => 'Aura';

  @override
  String get profileLearningGoal => 'Objectif d\'Apprentissage';

  @override
  String get profileHeardFrom => 'Comment nous avez-vous connus';

  @override
  String get profileQuizPreference => 'Préférence de Quiz';

  @override
  String get profileStudyTime => 'Heure d\'Étude Quotidienne';

  @override
  String get profileStudyDuration => 'Durée de la Session';

  @override
  String get profileInterests => 'Intérêts Médicaux';

  @override
  String get profileNextExam => 'Prochain Examen Majeur';

  @override
  String get profileDailyChallenge => 'EMD du Jour Activé';

  @override
  String get profileShowToFaculty => 'Visible par la Faculté';

  @override
  String get simTechnicalOverlay => 'SUPERPOSITION TECHNIQUE';

  @override
  String get simMoreOptions => 'Plus d\'options';

  @override
  String get simDifferentialChecklist => 'Liste de diagnostic différentiel';

  @override
  String get simTechnicalOptions => 'Options techniques';

  @override
  String get simTextScaling => 'Taille du texte';

  @override
  String get simHighContrastMode => 'Mode contraste élevé';

  @override
  String get simClinicalObservation => 'Observation médicale';

  @override
  String get simReportProblem => 'Signaler un problème';

  @override
  String get simSelectSpecialtyDiff =>
      'Sélectionnez une spécialité pour le diagnostic différentiel';

  @override
  String get simCheckSuspectedPathologies =>
      'Cochez toutes les pathologies suspectées. Elles seront examinées à la fin de la simulation.';

  @override
  String get simClinicalObservationReport => 'Rapport d\'observation médicale';

  @override
  String get simReportCopiedClipboard =>
      'Une observation médicale formatée a été copiée dans votre presse-papiers.';

  @override
  String get simReportABug => 'Signaler un bug';

  @override
  String get simReportBugDescription =>
      'Veuillez décrire le problème que vous avez rencontré lors de cette simulation.';

  @override
  String get simReportBugMetadata =>
      'L\'ID de session, la pathologie et les constantes actuelles seront inclus dans le rapport.';

  @override
  String get simDescribeIssueHint => 'Décrivez le problème...';

  @override
  String get simThankYou => 'Merci';

  @override
  String get simReportSubmitted => 'Votre rapport a été soumis.';

  @override
  String get simPatientBriefing => 'Briefing du patient';

  @override
  String get simAiConsultation => 'Consultation IA';

  @override
  String get simTechnicalDebug => 'Superposition de débogage technique';

  @override
  String get simStartMission => 'DÉMARRER LA MISSION';

  @override
  String get simNextStep => 'ÉTAPE SUIVANTE';

  @override
  String get simCurriculumFocus => 'Objectif du programme';

  @override
  String get simCaseSelection => 'Sélection du cas';

  @override
  String get simSetting => 'Cadre de la simulation';

  @override
  String get simFinalBriefing => 'Briefing final';

  @override
  String get simBackToSimulations => 'RETOUR AUX SIMULATIONS';

  @override
  String get simChooseModuleDesc =>
      'Sélectionnez un module de votre programme. L\'IA tirera des cas de patients pertinents de cette spécialité.';

  @override
  String get simNoCasesFound =>
      'Aucun cas trouvé pour ce module dans la base de données.';

  @override
  String get simChooseClinicalCase => 'Choisir un cas clinique';

  @override
  String get simSimParameters => 'Paramètres de simulation';

  @override
  String get simClinicalSetting => 'Cadre clinique';

  @override
  String get simSimDifficulty => 'Difficulté de la simulation';

  @override
  String get simReadyToInitialize => 'Prêt à initialiser ?';

  @override
  String get simDemographicsPersonalityDesc =>
      'Les données démographiques et la personnalité du patient sont prédéfinies dans la base de données pour ce cas clinique spécifique.';

  @override
  String get simEnterRoomDesc =>
      'Entrez dans la salle et commencez l\'anamnèse pour découvrir l\'identité et l\'histoire du patient.';

  @override
  String get simCase => 'Cas';

  @override
  String get simLocation => 'Lieu';

  @override
  String get simDifficulty => 'Difficulté';

  @override
  String get simSaveList => 'ENREGISTRER LA LISTE';

  @override
  String get simDescribeIssue =>
      'Qu\'est-ce qui s\'est mal passé ? Notre équipe technique examinera l\'état de la session.';

  @override
  String get simDiagnosticData => 'DONNÉES DE DIAGNOSTIC (AUTO-ATTACHÉES)';

  @override
  String get simSubmitReport => 'SOUMETTRE LE RAPPORT';

  @override
  String get simReportSent => 'Rapport envoyé. Merci pour votre retour !';

  @override
  String get simCopyAndClose => 'COPIER ET FERMER';

  @override
  String get simObservationCopied =>
      'Observation copiée dans le presse-papiers';

  @override
  String get simDifferentialDiagnosis => 'DIAGNOSTIC DIFFÉRENTIEL';

  @override
  String get simListDifferentialsHint => 'Listez vos diagnostics ici...';

  @override
  String get simEmergencyRoom => 'Salle d\'urgence';

  @override
  String get simEmergencyRoomDesc =>
      'Présentations aiguës, données initiales limitées.';

  @override
  String get simOutpatientClinic => 'Consultation externe';

  @override
  String get simOutpatientClinicDesc =>
      'Consultation de routine, accent sur l\'anamnèse.';

  @override
  String get simInterview => 'Entretien';

  @override
  String get simExam => 'Examen';

  @override
  String get simLabs => 'Laboratoire';

  @override
  String get simAuscultation => 'Auscultation';

  @override
  String get simPalpation => 'Palpation';

  @override
  String get simPercussion => 'Percussion';

  @override
  String get simNeurologicalExam => 'Examen Neurologique';

  @override
  String get simPupillaryReflex => 'Réflexe Pupillaire';

  @override
  String get simJVP => 'Pression Veineuse Jugulaire';

  @override
  String get simRevealInterpretation =>
      'Révéler l\'interprétation de l\'expert';

  @override
  String get simSaveContinue => 'Enregistrer & Continuer';

  @override
  String get simSubmitFinalDiagnosis => 'SOUMETTRE LE DIAGNOSTIC FINAL';

  @override
  String get simFinalDiagnosis => 'Diagnostic Final';

  @override
  String get simEnterPathology => 'Entrez votre pathologie suspectée...';

  @override
  String get simInterviewHint => 'Interrogez le patient...';

  @override
  String get simPatientThinking => 'Le patient réfléchit...';

  @override
  String get simPerformExamination => 'EFFECTUER L\'EXAMEN';

  @override
  String get simLatestFinding => 'DERNIÈRE CONSTATATION';

  @override
  String get simSearchInvestigations => 'Rechercher des investigations...';

  @override
  String get simDiagnosticResults => 'RÉSULTATS DIAGNOSTIQUES';

  @override
  String get simAiClinicalTutor => 'TUTEUR CLINIQUE IA';

  @override
  String get simAskTutorFindings => 'INTERROGEZ LE TUTEUR SUR LES RÉSULTATS';

  @override
  String get simWhySignificant =>
      'Pourquoi ce résultat est-il significatif dans ce cas ?';

  @override
  String get simYourInterpretation => 'VOTRE INTERPRÉTATION';

  @override
  String get simEnterFinding =>
      'Saisissez votre constat clinique ou votre interprétation...';

  @override
  String get simRefRange => 'VAL. RÉF';

  @override
  String get simNoDataAvailable =>
      'Aucune donnée clinique disponible pour cet examen.';

  @override
  String get simRetrievingData => 'Récupération des données cliniques...';

  @override
  String get simLoadingAudio => 'CHARGEMENT DE L\'AUDIO CLINIQUE...';

  @override
  String get simPlayingAuscultation => 'AUSCULTATION EN COURS...';

  @override
  String get simReadyToListen => 'PRÊT À ÉCOUTER';

  @override
  String get simInterpretation => 'INTERPRÉTATION';

  @override
  String get simExpertInterpretation => 'INTERPRÉTATION EXPERTE';

  @override
  String simViewMedia(Object mediaType) {
    return 'VOIR $mediaType';
  }

  @override
  String get simClinicalReasoningTutor => 'TUTEUR DE RAISONNEMENT CLINIQUE';

  @override
  String get simWelcomeDoctor => 'Bienvenue, Docteur.';

  @override
  String get simTutorHelp =>
      'Je peux vous aider à interpréter les résultats, suggérer des diagnostics différentiels ou expliquer la physiopathologie de ce cas. Comment puis-je vous aider ?';

  @override
  String get simSuggestedQuestions => 'Questions suggérées :';

  @override
  String get simAskTutorHint => 'Interrogez le tuteur...';

  @override
  String get simTutorDiff =>
      'Quels sont les diagnostics différentiels les plus probables ?';

  @override
  String get simTutorEcg =>
      'Pouvez-vous expliquer la signification des résultats ECG ?';

  @override
  String get simTutorManagement =>
      'Quelle serait ma prochaine priorité de prise en charge ?';

  @override
  String get simSessionExported => 'Journal de session exporté';

  @override
  String get simCancel => 'ANNULER';

  @override
  String get simSubmit => 'SOUMETTRE';

  @override
  String get simClose => 'FERMER';

  @override
  String get labBiochemistry => 'Biochimie';

  @override
  String get labHematology => 'Hématologie';

  @override
  String get labCardiac => 'Cardiaque';

  @override
  String get labRadiology => 'Radiologie';

  @override
  String get labMicrobiology => 'Microbiologie';

  @override
  String get labOthers => 'Autres';

  @override
  String get labBloodGlucose => 'Glycémie';

  @override
  String get labUreaElectrolytes => 'Urée & Électrolytes';

  @override
  String get labLiverFunction => 'Bilan Hépatique';

  @override
  String get labCrp => 'CRP';

  @override
  String get labHba1c => 'HbA1c';

  @override
  String get labLipidProfile => 'Bilan Lipidique';

  @override
  String get labFbc => 'NFS (Numération Formule Sanguine)';

  @override
  String get labCoagulation => 'Bilan de Coagulation';

  @override
  String get labDdimer => 'D-Dimères';

  @override
  String get labBloodFilm => 'Frottis Sanguin';

  @override
  String get labTroponin => 'Troponine I/T';

  @override
  String get labNtProBnp => 'NT-proBNP';

  @override
  String get labEcg => 'ECG (12 Dérivations)';

  @override
  String get labEcho => 'Échocardiographie';

  @override
  String get labCardiacEnzymes => 'Enzymes cardiaques';

  @override
  String get labCxr => 'Radiographie Pulmonaire';

  @override
  String get labAxr => 'ASP (Abdomen Sans Préparation)';

  @override
  String get labCtBrain => 'Scanner Cérébral';

  @override
  String get labCtpa => 'Angio-scanner Pulmonaire';

  @override
  String get labAbdoUs => 'Échographie Abdominale';

  @override
  String get labMriBrain => 'IRM Cérébrale';

  @override
  String get labBloodCultures => 'Hémocultures';

  @override
  String get labUrineCulture => 'ECBU (Urine)';

  @override
  String get labSputumCulture => 'ECBC (Crachats)';

  @override
  String get labPcr => 'PCR COVID/Grippe';

  @override
  String get labUrinalysis => 'Bandelette Urinaire';

  @override
  String get labAbg => 'Gaz du Sang';

  @override
  String get labPeakFlow => 'Débit de Pointe (Peak Flow)';

  @override
  String get simAllSpecialties => 'Toutes les spécialités';

  @override
  String get simSearchPathology =>
      'Rechercher une pathologie ou des symptômes...';
}
