import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum PERMISSION_STATUS { GRANTED, DENIED, SETTINGS }

enum PERMISSION_TYPE { CAMERA, GALLERY, LOCATION,STORAGE }

class PermissionUtils {

  late Function(PERMISSION_STATUS) _callback;
  late BuildContext _context;
  late bool _isMandatory;
  late List<Permission> _permissionGroups;
  late List<Permission> allpermissions;

  bool _isAllGranted = true;
  bool _isNeverAskAgain = false;

  void checkAndRequestPermission(BuildContext context,
      PERMISSION_TYPE type,
      bool isMandatory,
      Function(PERMISSION_STATUS) callback) {

    _permissionGroups = [];

    _context = context;
    _callback = callback;
    _isMandatory = isMandatory;

    switch(type) {
      case PERMISSION_TYPE.CAMERA:
        _permissionGroups.add(Permission.camera);
        _permissionGroups.add(Permission.storage);
        break;
      case PERMISSION_TYPE.GALLERY:
        _permissionGroups.add(Permission.storage);
        break;
      case PERMISSION_TYPE.LOCATION:
        _permissionGroups.add(Permission.location);
        break;
      case PERMISSION_TYPE.STORAGE:
        _permissionGroups.add(Permission.storage);
        break;
    }
    _checkAndRequestPermission();
  }

  void _checkAndRequestPermission() async {
     _checkPermissionGroups();
    if (_isAllGranted) {
      _callback(PERMISSION_STATUS.GRANTED);
    } else if (_isNeverAskAgain) {
      _checkIfMandatory();
    } else {
      _requestPermissons();
    }
  }
  // Future<bool> checkPermissionGivenOrNot(PERMISSION_TYPE type) async {
  //   allpermissions = [];
  //   switch(type) {
  //     case PERMISSION_TYPE.CAMERA:
  //       allpermissions.add(Permission.camera);
  //       allpermissions.add(Permission.storage);
  //       break;
  //     case PERMISSION_TYPE.GALLERY:
  //       allpermissions.add(Permission.storage);
  //       break;
  //   }
  //   return await checkPermissionGranted();
  // }
  // Future<bool>checkPermissionGranted() async {
  //   bool granted = false;
  //   await Future.forEach(allpermissions, (permissionGroup) async {
  //     // PermissionStatus permission = await PermissionHandler.checkPermissionStatus(permissionGroup);
  //     var permission = await permissionGroup.status;
  //     print("PERMISSION ${permission}");
  //     if (permission == PermissionStatus.granted) {
  //       return granted = true;
  //     }else if (permission == PermissionStatus.denied) {
  //       return granted = true;
  //     }else if (permission == PermissionStatus.permanentlyDenied) {
  //       return granted = true;
  //     }else if (permission == PermissionStatus.limited) {
  //       return granted = true;
  //     }else if (permission == PermissionStatus.restricted) {
  //        granted = false;
  //     }
  //   });
  //   return granted;
  // }

  void _checkPermissionGroups() async {
    await Future.forEach(_permissionGroups, (Permission permissionGroup) async {
      var permission = await permissionGroup.status;
      if (permission != PermissionStatus.granted) {
        if (Platform.isAndroid) {

          if (permission == PermissionStatus.restricted) {
            _isNeverAskAgain = true;
          }
        } else {
          if (permission == PermissionStatus.permanentlyDenied) {
            _isNeverAskAgain = true;
          }
        }
        _isAllGranted = false;
      }
    });
  }

  void _checkPermissionStatus(List<PermissionStatus> status) async {
    _isAllGranted = true;
    for (PermissionStatus permission in status) {

      if (permission != PermissionStatus.granted) {
        if (Platform.isAndroid) {
          if (permission == PermissionStatus.restricted) {
            _isNeverAskAgain = true;
          }
        } else {

          if (permission == PermissionStatus.permanentlyDenied) {
            _isNeverAskAgain = true;
          }
        }
        _isAllGranted = false;
      }
    }

    if (_isAllGranted) {
      _callback(PERMISSION_STATUS.GRANTED);
    } else {
      _checkIfMandatory();
    }
  }

  void _requestPermissons() async {

    Map<Permission, PermissionStatus> permissions = await _permissionGroups.request();

    _checkPermissionStatus(permissions.values.toList(growable: false));
  }

  void _checkIfMandatory() {
    if(_isMandatory) {
      showPermissionDialog(_context, _callback);
    } else {
      _callback(PERMISSION_STATUS.DENIED);
    }
  }

  void showPermissionDialog(BuildContext context, Function(PERMISSION_STATUS) callback) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(_context);
        callback(PERMISSION_STATUS.DENIED);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Settings"),
      onPressed: () async {
        Navigator.pop(_context);
        await openAppSettings();
        callback(PERMISSION_STATUS.SETTINGS);
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Permission required"),
          content:
              new Text("This permission is required to access the feature"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            cancelButton,
            continueButton
          ],
        );
      },
    );
  }
}
