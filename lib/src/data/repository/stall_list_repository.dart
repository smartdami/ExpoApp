import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:product_expo/src/data/model/stall_list_model.dart';

class StallListRepo {
  Future<StallListModel> getStallList() async {
    final String sampleJson =
        await rootBundle.loadString('lib/src/data/sample_stall_list.json');
    final Map<String, dynamic> jsonResponse = json.decode(sampleJson);

    return StallListModel.fromJson(jsonResponse);
  }
}
