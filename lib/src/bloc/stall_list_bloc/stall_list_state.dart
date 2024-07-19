part of 'stall_list_bloc.dart';

class StallListState {}

class StallListInitial extends StallListState {}

class StallListScrollState extends StallListState {}

class ShowHideSearchOptionState extends StallListState {}

class StallListDetailedState extends StallListState {
  final int selectedStallIndex;

  StallListDetailedState({required this.selectedStallIndex});
}

class UiRefreshState extends StallListState {}

class StallListBackNavigationState extends StallListState {}

class PhotosVideosUploadedState extends StallListState {}

class MediaExpandedViewState extends StallListState {
  final int fullViewTag;
  final String? mediaPath;
  MediaExpandedViewState({required this.fullViewTag, this.mediaPath});
}

// VideoPlayer Events

class VideoPlayerControlsState extends StallListState {
  final int videoControlTag;
  VideoPlayerControlsState({required this.videoControlTag});
}

class VideoTimerChangeState extends StallListState {
  // Define your state properties

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTimerChangeState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class InitializeVideoPlayerState extends StallListState {
  final bool isInitialized;

  InitializeVideoPlayerState({required this.isInitialized});
}

class ChangeThumbnailState extends StallListState {
  final int currentIndex;

  ChangeThumbnailState(this.currentIndex);
}
