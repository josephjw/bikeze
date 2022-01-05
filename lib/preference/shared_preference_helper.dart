import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'Constants.dart';

class SharedPreferenceHelper {
  // shared pref instance
     SharedPreferences? _sharedPreference;

   void init(SharedPreferences preferences) {
    _sharedPreference = preferences;
  }
   Future<void> forceInit() async {
    _sharedPreference =  await SharedPreferences.getInstance();
  }
   void delete() {
    _sharedPreference?.clear();
  }

   Future<bool> get isOnboarded async {
    bool? onboarded = await getBool(Preferences.onboarded);
    return onboarded != null && onboarded;
  }

   Future<String?> getString(String key) async {
    if(_sharedPreference != null) {
      return _sharedPreference?.getString(key);
    }
    return null;
  }

   Future<bool?> getBool(String key) async {
    return _sharedPreference?.getBool(key);
  }

   Future<double?> getDouble(String key) async {
    return _sharedPreference!.getDouble(key);
  }

   Future<int?> getInt(String key) async {
    return _sharedPreference?.getInt(key);
  }

   Future<Future<bool>?> saveString(String key, String value) async {
    return _sharedPreference?.setString(key, value);
  }

   Future<Future<bool>> saveBool(String key, bool value) async {
    return _sharedPreference!.setBool(key, value);
  }

   Future<Future<bool>?> saveDouble(String key, double value) async {
    return _sharedPreference?.setDouble(key, value);
  }

   Future<Future<bool>?> saveInt(String key, int value) async {
    return _sharedPreference?.setInt(key, value);
  }

   Future<Future<bool>?> removePreference(String key) async {
    return _sharedPreference?.remove(key);
  }
}
