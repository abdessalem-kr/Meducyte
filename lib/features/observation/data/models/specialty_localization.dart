import 'package:flutter/material.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

extension MedicalSpecialtyLocalization on MedicalSpecialty {
  String localizedName(BuildContext context) {
    switch (this) {
      case MedicalSpecialty.general:
        return AppLocalizations.of(context)!.spec_general;
      case MedicalSpecialty.cardiology:
        return AppLocalizations.of(context)!.spec_cardiology;
      case MedicalSpecialty.neurology:
        return AppLocalizations.of(context)!.spec_neurology;
      case MedicalSpecialty.anesthesiereanimation:
        return AppLocalizations.of(context)!.spec_anesthesiereanimation;
      case MedicalSpecialty.anesthesiereanimationpediatrique:
        return AppLocalizations.of(
          context,
        )!.spec_anesthesiereanimationpediatrique;
      case MedicalSpecialty.biophysiquemedicale:
        return AppLocalizations.of(context)!.spec_biophysiquemedicale;
      case MedicalSpecialty.dermatologieetvenereologie:
        return AppLocalizations.of(context)!.spec_dermatologieetvenereologie;
      case MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques:
        return AppLocalizations.of(
          context,
        )!.spec_diabetologieendocrinologieetmaladiesmetaboliques;
      case MedicalSpecialty.epidemiologieetmedecinepreventive:
        return AppLocalizations.of(
          context,
        )!.spec_epidemiologieetmedecinepreventive;
      case MedicalSpecialty.hepatogastroenterologie:
        return AppLocalizations.of(context)!.spec_hepatogastroenterologie;
      case MedicalSpecialty.hematologie:
        return AppLocalizations.of(context)!.spec_hematologie;
      case MedicalSpecialty.gynecologieobstetrique:
        return AppLocalizations.of(context)!.spec_gynecologieobstetrique;
      case MedicalSpecialty.infectiologie:
        return AppLocalizations.of(context)!.spec_infectiologie;
      case MedicalSpecialty.medecineinterne:
        return AppLocalizations.of(context)!.spec_medecineinterne;
      case MedicalSpecialty.medecinelegaledroitmedicaletethique:
        return AppLocalizations.of(
          context,
        )!.spec_medecinelegaledroitmedicaletethique;
      case MedicalSpecialty.medecinenucleaireetimageriemoleculaire:
        return AppLocalizations.of(
          context,
        )!.spec_medecinenucleaireetimageriemoleculaire;
      case MedicalSpecialty.medecinedusport:
        return AppLocalizations.of(context)!.spec_medecinedusport;
      case MedicalSpecialty.medecinedutravail:
        return AppLocalizations.of(context)!.spec_medecinedutravail;
      case MedicalSpecialty.medecinephysiqueetreadaptation:
        return AppLocalizations.of(
          context,
        )!.spec_medecinephysiqueetreadaptation;
      case MedicalSpecialty.nephrologie:
        return AppLocalizations.of(context)!.spec_nephrologie;
      case MedicalSpecialty.oncologiemedicale:
        return AppLocalizations.of(context)!.spec_oncologiemedicale;
      case MedicalSpecialty.ophtalmologie:
        return AppLocalizations.of(context)!.spec_ophtalmologie;
      case MedicalSpecialty.orl:
        return AppLocalizations.of(context)!.spec_orl;
      case MedicalSpecialty.pediatrie:
        return AppLocalizations.of(context)!.spec_pediatrie;
      case MedicalSpecialty.psychiatrie:
        return AppLocalizations.of(context)!.spec_psychiatrie;
      case MedicalSpecialty.pedopsychiatrie:
        return AppLocalizations.of(context)!.spec_pedopsychiatrie;
      case MedicalSpecialty.pneumophtisiologie:
        return AppLocalizations.of(context)!.spec_pneumophtisiologie;
      case MedicalSpecialty.radiotherapieoncologie:
        return AppLocalizations.of(context)!.spec_radiotherapieoncologie;
      case MedicalSpecialty.rhumatologie:
        return AppLocalizations.of(context)!.spec_rhumatologie;
      case MedicalSpecialty.reanimationmedicale:
        return AppLocalizations.of(context)!.spec_reanimationmedicale;
      case MedicalSpecialty.chirurgiegenerale:
        return AppLocalizations.of(context)!.spec_chirurgiegenerale;
      case MedicalSpecialty.chirurgiecardiaque:
        return AppLocalizations.of(context)!.spec_chirurgiecardiaque;
      case MedicalSpecialty.chirurgiemaxillofaciale:
        return AppLocalizations.of(context)!.spec_chirurgiemaxillofaciale;
      case MedicalSpecialty.chirurgieneurologique:
        return AppLocalizations.of(context)!.spec_chirurgieneurologique;
      case MedicalSpecialty.chirurgieorthopediqueettraumatologie:
        return AppLocalizations.of(
          context,
        )!.spec_chirurgieorthopediqueettraumatologie;
      case MedicalSpecialty.chirurgiepediatrique:
        return AppLocalizations.of(context)!.spec_chirurgiepediatrique;
      case MedicalSpecialty.chirurgiethoracique:
        return AppLocalizations.of(context)!.spec_chirurgiethoracique;
      case MedicalSpecialty.chirurgieurologique:
        return AppLocalizations.of(context)!.spec_chirurgieurologique;
      case MedicalSpecialty.chirurgievasculaire:
        return AppLocalizations.of(context)!.spec_chirurgievasculaire;
      case MedicalSpecialty
          .chirurgieplastiquereconstructriceesthetiqueetdebrulologie:
        return AppLocalizations.of(
          context,
        )!.spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie;
    }
  }
}
