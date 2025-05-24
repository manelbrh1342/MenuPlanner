// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(error) =>
      "Erreur lors de l\'enregistrement de la langue : ${error}";

  static String m1(error) =>
      "Erreur lors de l\'enregistrement des paramètres : ${error}";

  static String m2(language) => "Langue changée en ${language}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "autoUpdate":
            MessageLookupByLibrary.simpleMessage("Mise à jour automatique"),
        "errorSavingLanguage": m0,
        "errorSavingSettings": m1,
        "languageChanged": m2,
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Choisir la langue"),
        "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "settingsSaved": MessageLookupByLibrary.simpleMessage(
            "Paramètres enregistrés avec succès")
      };
}
