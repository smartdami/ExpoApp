import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_expo/src/data/app_constants.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../data/model/stall_list_model.dart';
import '../../data/repository/stall_list_repository.dart';

part 'stall_list_event.dart';
part 'stall_list_state.dart';

class StallListBloc extends Bloc<StallListEvent, StallListState> {
  bool isLoading = true;
  bool isDocUploading = false;
  bool isNavLoading = false;
  String appDirPath = "";
  StallListModel? stallListModel;
  List<StallList>? searchList = [];

  StallListBloc() : super(StallListInitial()) {
    on<StallListEvent>((event, emit) async {
      if (event is LoadStallListEvent) {
        await _loadStallListEvent(emit);
      } else if (event is VideoTimerChangeEvent) {
        emit(VideoTimerChangeState());
      } else if (event is StallListDetailedEvent) {
        await _stallDetailsEvent(emit,
            isLoadThumbnail: false,
            stallId: event.stallId,
            stallListIndex: event.stallListIndex);
      } else if (event is StallListDetailLoadingEvent) {
        await _stallDetailsEvent(emit,
            isLoadThumbnail: true,
            stallId: event.stallId,
            stallListIndex: event.stallListIndex);
      } else if (event is UploadImagesVideosEvent) {
        await _uploadPhotosVideosEvent(event, emit);
      } else if (event is StallListScrollEvent) {
        emit(StallListScrollState());
      } else if (event is ShowHideSearchOptionEvent) {
        emit(ShowHideSearchOptionState());
      } else if (event is MediaExpandedViewEvent) {
        emit(MediaExpandedViewState(
            fullViewTag: event.fullViewTag, mediaPath: event.mediaPath));
      } else if (event is VideoControlsEvent) {
        emit(VideoPlayerControlsState(videoControlTag: event.videoControlTag));
      } else if (event is InitializeVideoPlayerEvent) {
        _videoPlayerInitialization(event, emit);
      } else if (event is ChangeThumbnailEvent) {
        emit(ChangeThumbnailState(event.currentIndex));
      } else if (event is StallListSearchEvent) {
        _searchStallEvent(event, emit);
      } else if (event is StartFileSelectingEvent) {
        _fileSelectionLoader(event, emit);
      } else if (event is StallListBackNavigationEvent) {
        emit(StallListBackNavigationState());
      }
    });
  }

  void _searchStallEvent(
      StallListSearchEvent event, Emitter<StallListState> emit) {
    searchList = [];
    if (event.searchText.isEmpty) {
      for (int i = 0; i < stallListModel!.stallList!.length; i++) {
        searchList!
            .add(StallList.fromJson(stallListModel!.stallList![i].toJson()));
      }
    } else {
      for (int i = 0; i < stallListModel!.stallList!.length; i++) {
        if (stallListModel!.stallList![i].stallName!
            .toLowerCase()
            .contains(event.searchText.toLowerCase())) {
          searchList!
              .add(StallList.fromJson(stallListModel!.stallList![i].toJson()));
        }
      }
    }
    emit(UiRefreshState());
  }

  Future<void> _stallDetailsEvent(Emitter<StallListState> emit,
      {required bool isLoadThumbnail,
      required String stallId,
      required int stallListIndex}) async {
    isLoadThumbnail ? isLoading = true : isNavLoading = true;
    emit(UiRefreshState());

    int stallIndex = stallListModel!.stallList!
        .indexWhere((element) => element.stallId == stallId);

    await _checkDirectory(stallListModel!.stallList![stallIndex].stallDirPath!);
    Directory dir =
        Directory(stallListModel!.stallList![stallIndex].stallDirPath!);

    if (!isLoadThumbnail) {
      stallListModel!.stallList![stallIndex].mediaFiles = [];
      searchList![stallListIndex].mediaFiles = [];

      // Count of images/videos
      int filesCount = await dir.list().length;
      searchList![stallListIndex].stallMediaCount = filesCount.toString();
    }
    if (isLoadThumbnail) {
      // Count of images/videos
      List<String> filePath =
          await dir.list().map((element) => element.path).toList();
      searchList![stallListIndex].stallMediaCount = filePath.length.toString();
      stallListModel!.stallList![stallIndex].stallMediaCount =
          filePath.length.toString();
      //Thumbnail Creation
      for (int j = 0; j < filePath.length; j++) {
        Image? thumbnailImage;
        if (filePath[j].contains(AppConstants.mp4) ||
            filePath[j].contains(AppConstants.mov)) {
          thumbnailImage = await _getVideoThumbnail(filePath[j]);
        }

        MediaFiles mediaFiles = MediaFiles.fromJson({
          AppConstants.fileType: filePath[j].split('.').last,
          AppConstants.filePath: filePath[j],
          AppConstants.videoThumbnail:
              (filePath[j].contains(AppConstants.mp4) ||
                      filePath[j].contains(AppConstants.mov))
                  ? thumbnailImage!
                  : null
        });
        stallListModel!.stallList![stallIndex].mediaFiles!.add(mediaFiles);

        searchList![stallListIndex].mediaFiles!.add(mediaFiles);
      }
    }

    isLoadThumbnail ? isLoading = false : isNavLoading = false;
    emit(isLoadThumbnail
        ? UiRefreshState()
        : StallListDetailedState(selectedStallIndex: stallListIndex));
  }

  void _videoPlayerInitialization(
      InitializeVideoPlayerEvent event, Emitter<StallListState> emit) {
    if (!event.isInitialized) {
      isLoading = true;
      emit(InitializeVideoPlayerState(isInitialized: event.isInitialized));
    } else {
      isLoading = false;
      emit(InitializeVideoPlayerState(isInitialized: event.isInitialized));
    }
  }

  Future<void> _loadStallListEvent(Emitter<StallListState> emit) async {
    emit(UiRefreshState());
    await _getApplicationDirectoryPath();
    stallListModel = await StallListRepo().getStallList();
    searchList = [];
    for (int i = 0; i < stallListModel!.stallList!.length; i++) {
      final String actualDirPath =
          '$appDirPath/${AppConstants.expoDocuments}/${stallListModel!.stallList![i].stallId}';

      // Directory creation of Each Stall
      await _checkDirectory(actualDirPath);
      Directory dir = Directory(actualDirPath);

      // Count of images/videos
      int filesCount = await dir.list().length;

      stallListModel!.stallList![i].stallDirPath = actualDirPath;
      stallListModel!.stallList![i].stallMediaCount = filesCount.toString();
      searchList!
          .add(StallList.fromJson(stallListModel!.stallList![i].toJson()));
    }
    isLoading = false;
    emit(UiRefreshState());
  }

  Future<void> _checkDirectory(String actualDirPath) async {
    Directory dir = Directory(actualDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> _getApplicationDirectoryPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDirPath = appDocDir.path;
  }

  Future<Image> _getVideoThumbnail(String filePath) async {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.PNG,
      timeMs: 2000,
      maxWidth: 1080,
      quality: 0,
    );
    return Image.memory(
      thumbnailData!,
      fit: BoxFit.fill,
    );
  }

  Future<void> _uploadPhotosVideosEvent(
      UploadImagesVideosEvent event, Emitter<StallListState> emit) async {
    // Index of Document Upload Stall
    int indexOfSearchStallList = searchList!
        .indexWhere((element) => element.stallId == event.stallList.stallId);

    int indexOfStallListModel = stallListModel!.stallList!
        .indexWhere((element) => element.stallId == event.stallList.stallId);

    // Check if the directory exists
    await _checkDirectory(searchList![indexOfSearchStallList].stallDirPath!);

    // Write File to App Storage
    for (int i = 0; i < event.filePickerResult.paths.length; i++) {
      String fileName = event.filePickerResult.names[i]!;
      final String actualFilePath =
          '${searchList![indexOfSearchStallList].stallDirPath}/$fileName';

      // Write the file
      File x = await File(actualFilePath).writeAsBytes(
          await File(event.filePickerResult.paths[i]!).readAsBytes());
      Image? thumbnailImage;
      if (x.path.contains(AppConstants.mp4) ||
          x.path.contains(AppConstants.mov)) {
        thumbnailImage = await _getVideoThumbnail(x.path);
      }
      MediaFiles mediaFiles = MediaFiles.fromJson({
        AppConstants.fileType: x.path.split('.').last,
        AppConstants.filePath: x.path,
        AppConstants.videoThumbnail: (x.path.contains(AppConstants.mp4) ||
                x.path.contains(AppConstants.mov))
            ? thumbnailImage
            : null
      });
      stallListModel!.stallList![indexOfStallListModel].mediaFiles!
          .add(mediaFiles);
      searchList![indexOfSearchStallList].mediaFiles!.add(mediaFiles);
    }
    // Count of images/videos
    Directory dir =
        Directory(searchList![indexOfSearchStallList].stallDirPath!);
    int filesCount = await dir.list().length;
    stallListModel!.stallList![indexOfStallListModel].stallMediaCount =
        filesCount.toString();
    searchList![indexOfSearchStallList].stallMediaCount = filesCount.toString();

    isDocUploading = false;
    emit(PhotosVideosUploadedState());
  }

  void _fileSelectionLoader(
      StartFileSelectingEvent event, Emitter<StallListState> emit) {
    if (event.tag == 0) {
      isDocUploading = true;
    } else {
      isDocUploading = false;
    }

    emit(UiRefreshState());
  }
}
