part of 'stall_list_bloc.dart';

class StallListEvent {}

class LoadStallListEvent extends StallListEvent {}

class StallListScrollEvent extends StallListEvent {
  StallListScrollEvent();
}

class StallListBackNavigationEvent extends StallListEvent {

}
class StallListSearchEvent extends StallListEvent {
  final String searchText;

  StallListSearchEvent({required this.searchText});
}

class ShowHideSearchOptionEvent extends StallListEvent {}

class StallListDetailedEvent extends StallListEvent {
  final String stallId;
  final int stallListIndex;

  StallListDetailedEvent({required this.stallId, required this.stallListIndex});
}

class StallListDetailLoadingEvent extends StallListEvent {
  final String stallId;
  final int stallListIndex;

  StallListDetailLoadingEvent(
      {required this.stallId, required this.stallListIndex});
}

class UploadImagesVideosEvent extends StallListEvent {
  final FilePickerResult filePickerResult;
  final StallList stallList;
  UploadImagesVideosEvent({
    required this.stallList,
    required this.filePickerResult,
  });
}

class StartFileSelectingEvent extends StallListEvent {
  final int tag;

  StartFileSelectingEvent({required this.tag});
}

class FetchImagesVideosEvent extends StallListEvent {
  final String stallId;
  final String stallDirPath;
  FetchImagesVideosEvent({required this.stallId, required this.stallDirPath});
}

class MediaExpandedViewEvent extends StallListEvent {
  final int fullViewTag;
  final String? mediaPath;
  MediaExpandedViewEvent({required this.fullViewTag, this.mediaPath});
}

class VideoControlsEvent extends StallListEvent {
  final int videoControlTag;
  VideoControlsEvent({required this.videoControlTag});
}

class VideoTimerChangeEvent extends StallListEvent {}

class InitializeVideoPlayerEvent extends StallListEvent {
  final bool isInitialized;
  InitializeVideoPlayerEvent({required this.isInitialized});
}

class ChangeThumbnailEvent extends StallListEvent {
  final int currentIndex;

  ChangeThumbnailEvent(this.currentIndex);
}
