import 'package:flutter/material.dart';

class StallListModel {
  List<StallList>? stallList;

  StallListModel({this.stallList});

  StallListModel.fromJson(Map<String, dynamic> json) {
    if (json['stallList'] != null) {
      stallList = <StallList>[];
      json['stallList'].forEach((v) {
        stallList!.add(StallList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stallList != null) {
      data['stallList'] = stallList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StallList {
  String? stallName;
  String? stallId;
  String? stallImage;
  String? eventDate;
  String? category;
  String? stallDirPath;
  String? stallMediaCount;
  List<MediaFiles>? mediaFiles;
  StallList(
      {this.stallName,
      this.stallId,
      this.stallImage,
      this.eventDate,
      this.category,
      this.stallDirPath,
      this.stallMediaCount,
      this.mediaFiles});

  StallList.fromJson(Map<String, dynamic> json) {
    stallName = json['stallName'];
    stallId = json['stallId'];
    stallImage = json['stallImage'];
    eventDate = json['eventDate'];
    category = json['category'];
    stallMediaCount = json['stallMediaCount'];
    mediaFiles = json.containsKey("mediaFiles") ? json['mediaFiles'] ?? [] : [];
    stallDirPath = json['stallDirPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stallName'] = stallName;
    data['stallId'] = stallId;
    data['stallImage'] = stallImage;
    data['eventDate'] = eventDate;
    data['category'] = category;
    data['stallMediaCount'] = stallMediaCount;
    data['stallDirPath'] = stallDirPath;
    data['mediaFiles'] = mediaFiles;
    return data;
  }
}

class MediaFiles {
  String? fileType;

  String? filePath;
  Widget? videoThumbnail;

  MediaFiles({this.fileType, this.filePath, this.videoThumbnail});

  MediaFiles.fromJson(Map<String, dynamic> json) {
    fileType = json['fileType'];
    filePath = json["filePath"];
    videoThumbnail = json['videoThumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileType'] = fileType;
    data["filePath"] = filePath;
    data['videoThumbnail'] = videoThumbnail;
    return data;
  }
}
