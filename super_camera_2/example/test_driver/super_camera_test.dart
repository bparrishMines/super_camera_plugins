// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

void main() async {
  final Map<String, String> envVars = Platform.environment;
  final String adbPath =
      envVars['ANDROID_HOME'] + '/platform-tools/adb';
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'com.example.supercameraexample',
    'android.permission.CAMERA',
  ]);
  final FlutterDriver driver = await FlutterDriver.connect();
  await driver.requestData(null, timeout: const Duration(minutes: 1));
  driver.close();
}
