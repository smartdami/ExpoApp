import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_expo/src/data/app_constants.dart';

import 'package:product_expo/src/data/model/stall_list_model.dart';
import 'package:product_expo/src/screen_util/screen_util.dart';

import 'package:product_expo/src/ui/widgets/common_text_widget.dart';
import 'package:product_expo/src/ui/widgets/dottoed_border.dart';
import 'package:video_player/video_player.dart';

import '../../bloc/stall_list_bloc/stall_list_bloc.dart';
import '../../screen_util/app_widget_size.dart';

class StallDetailedScreen extends StatefulWidget {
  final StallList stallList;
  final int stallIndex;
  const StallDetailedScreen(
      {super.key, required this.stallList, required this.stallIndex});

  @override
  State<StallDetailedScreen> createState() => _StallDetailedScreenState();
}

class _StallDetailedScreenState extends State<StallDetailedScreen> {
  late StallListBloc _stallListBloc;
  late StreamSubscription sListener;
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  //tag==0 attachfile view tag==1 imageview tag==2 videoview
  int fullViewTag = 0;
  String? mediaFilePath;

  //Video
  VideoPlayerController? _videoPlayerController;

  bool isPlaying = false;
  @override
  void initState() {
    _setStatusBarColor();
    _stallListBloc = BlocProvider.of<StallListBloc>(context);
    _stallListBloc.isLoading = true;
    _stallListBloc.add(StallListDetailLoadingEvent(
        stallId: widget.stallList.stallId!, stallListIndex: widget.stallIndex));
    sListener = _stallListBloc.stream.listen(_stallListListener);
    _stallListBloc.isDocUploading = false;
    super.initState();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }

    sListener.cancel();
    super.dispose();
  }

  Future<void> _stallListListener(StallListState state) async {
    if (state is PhotosVideosUploadedState) {
      await FilePicker.platform.clearTemporaryFiles();
    } else if (state is MediaExpandedViewState) {
      _mediaExpandedViewFunction(state);
    } else if (state is VideoPlayerControlsState) {
      _videoPlayerControlState(state);
    } else if (state is InitializeVideoPlayerState) {
      if (state.isInitialized) {
        fullViewTag = 2;
      }
    } else if (state is ChangeThumbnailState) {
      _currentIndex = state.currentIndex;
    }
  }

  void _videoPlayerControlState(VideoPlayerControlsState state) {
    //   tag 0 = play or pause tag 1 = rewind 1  tag=2 forward
    if (state.videoControlTag == 0) {
      final Duration currentPosition = _videoPlayerController!.value.position;
      final Duration newPosition =
          currentPosition - const Duration(seconds: 10);
      _videoPlayerController!.seekTo(newPosition);
    } else if (state.videoControlTag == 1) {
      isPlaying = !isPlaying;
      isPlaying
          ? _videoPlayerController!.play()
          : _videoPlayerController!.pause();
    } else if (state.videoControlTag == 2) {
      final Duration currentPosition = _videoPlayerController!.value.position;
      final Duration newPosition =
          currentPosition + const Duration(seconds: 10);
      _videoPlayerController!.seekTo(newPosition);
    }
  }

  void _mediaExpandedViewFunction(MediaExpandedViewState state) {
    fullViewTag = state.fullViewTag;
    mediaFilePath = state.mediaPath;
    if (fullViewTag == 0 && _videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
  }

  var platform = MethodChannel(AppConstants.sharefileMethodChannel);

  Future<void> _shareFile(File file) async {
    try {
      Uint8List fileBytes = await file.readAsBytes();
      String fileName = file.path.split('/').last;
      await platform.invokeMethod(
          'shareFile', {'fileName': fileName, 'fileBytes': fileBytes});
      // ignore: empty_catches
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StallListBloc, StallListState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            return _systemNavigationHandler();
          },
          child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Stack(
                children: [
                  SizedBox(
                      width: AppWidgetSize.screenWidth(context),
                      height: AppWidgetSize.screenHeight(context),
                      child: fullViewTag == 0
                          ? _stallDetailedView(context)
                          : fullViewTag == 1 //image Full View
                              ? _imageFullView(context)
                              : _videoPlayerView(context)),
                  _stallListBloc.isLoading
                      ? _loaderWidget(context)
                      : Container()
                ],
              )),
        );
      },
    );
  }

  bool _systemNavigationHandler() {
    if (_stallListBloc.isDocUploading || _stallListBloc.isLoading) {
      Navigator.pop(context);
    }
    if (fullViewTag != 0) {
      _stallListBloc.add(MediaExpandedViewEvent(fullViewTag: 0));
      return false;
    }
    return true;
  }

  Widget _stallDetailedView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _thumbnailWidget(context),
          _stallTextWidget(context,
              textString: widget.stallList.stallName!, tag: 0),
          _stallTextWidget(context,
              textString: widget.stallList.category!, tag: 1),
          _stallTextWidget(context,
              textString:
                  "${widget.stallList.stallMediaCount!} ${AppConstants.files}",
              tag: 2),
          _stallListBloc.isDocUploading
              ? _mediaUplodingLoader(context)
              : _attachFilesWidget(context)
        ],
      ),
    );
  }

  Widget _mediaUplodingLoader(BuildContext context) {
    return Container(
      margin: REdgeInsets.fromLTRB(
          AppWidgetSize.dimen_32,
          AppWidgetSize.dimen_64,
          AppWidgetSize.dimen_32,
          AppWidgetSize.dimen_64),
      padding: REdgeInsets.only(
          top: AppWidgetSize.dimen_16, bottom: AppWidgetSize.dimen_16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_14.r),
          color: Theme.of(context).colorScheme.secondary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: AppWidgetSize.dimen_24.h,
            width: AppWidgetSize.dimen_24.h,
            child: _loaderWidget(context,
                strokeWidth: AppWidgetSize.dimen_3,
                indicatorcolor: Theme.of(context).colorScheme.primary),
          ),
          _attachingFileTextWidget(context)
        ],
      ),
    );
  }

  Widget _attachingFileTextWidget(BuildContext context) {
    return CommonTextWidget(
      textString: AppConstants.attachingFile,
      fontColor: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w400,
      fontSize: AppWidgetSize.dimen_16.sp,
      leftPadding: AppWidgetSize.dimen_20,
    );
  }

  Widget _loaderWidget(BuildContext context,
      {Color? indicatorcolor, double? strokeWidth}) {
    return Center(
      child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 3,
          color: indicatorcolor ??
              Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }

  Widget _thumbnailWidget(BuildContext context) {
    return widget.stallList.mediaFiles!.isNotEmpty
        ? Stack(
            children: [
              SizedBox(
                  width: AppWidgetSize.screenWidth(context),
                  height: AppWidgetSize.screenHeight(context) * 0.6,
                  child: CarouselSlider(
                      items: widget.stallList.mediaFiles!
                          .map((element) => (element.fileType!
                                      .contains(AppConstants.mp4) ||
                                  element.fileType!.contains(AppConstants.mov))
                              ? _videoThumbnailWidget(element, context)
                              : _imageThumbnailWidget(element, context))
                          .toList(),
                      options: _carouselOptions(context))),
              _backWidget(context),
              // _shareWidget(context),
              _thumbnailScrollIndicationWidget(),
            ],
          )
        : _nodataThumbnail(context);
  }

  Widget _nodataThumbnail(BuildContext context) {
    return Container(
      height: AppWidgetSize.screenHeight(context) * 0.6,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(AppConstants.noDataImage),
        fit: BoxFit.fill,
      )),
    );
  }

  GestureDetector _imageThumbnailWidget(
      MediaFiles element, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _stallListBloc.add(MediaExpandedViewEvent(
            fullViewTag: 1, mediaPath: element.filePath!));
      },
      child: Stack(
        children: [
          Container(
            height: AppWidgetSize.screenHeight(context) * 0.6,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(element.filePath!)),
                fit: BoxFit.fill,
              ),
            ),
          ),
          _shareWidget(context, element),
        ],
      ),
    );
  }

  Future<void> _initializeVideoPlayer(
      BuildContext context, String mediaFile) async {
    _videoPlayerController =
        VideoPlayerController.contentUri(Uri.parse(mediaFile))
          ..initialize().then((_) {
            _stallListBloc.add(InitializeVideoPlayerEvent(isInitialized: true));
          });

    _videoPlayerController!.addListener(() {
      setState(() {});
    });
  }

  Widget _imageFullView(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: AppWidgetSize.screenHeight(context),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(mediaFilePath!)),
              fit: BoxFit.fill,
            ),
          ),
        ),
        _closeVideoWidget(context)
      ],
    );
  }

  Stack _videoPlayerView(BuildContext context) {
    return Stack(
      children: [
        _videoScreeningWidget(context),
        _closeVideoWidget(context),
        _videoSliderWidget(context),
        _videoControllsWidget(context),
      ],
    );
  }

  Widget _backWidget(BuildContext context) {
    return Positioned(
        top: double.parse(kToolbarHeight.toString()),
        left: AppWidgetSize.dimen_32.w,
        child: GestureDetector(
          onTap: () {
            if (!_stallListBloc.isDocUploading && !_stallListBloc.isLoading) {
              Navigator.pop(context);
            }
          },
          child: Container(
              width: AppWidgetSize.dimen_32.w,
              height: AppWidgetSize.dimen_32.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppWidgetSize.dimen_28.r)),
                  color: Theme.of(context).colorScheme.primary),
              padding: REdgeInsets.all(AppWidgetSize.dimen_3),
              child: Icon(Icons.arrow_back_ios_new,
                  size: AppWidgetSize.dimen_24.w)),
        ));
  }

  Widget _shareWidget(BuildContext context, MediaFiles element) {
    return Positioned(
        top: double.parse(kToolbarHeight.toString()),
        right: AppWidgetSize.dimen_32.w,
        child: GestureDetector(
          onTap: () {
            _shareFile(File(element.filePath!));
          },
          child: Container(
              width: AppWidgetSize.dimen_32.w,
              height: AppWidgetSize.dimen_32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppWidgetSize.dimen_28.r)),
                  color: Theme.of(context).colorScheme.primary),
              padding: REdgeInsets.all(AppWidgetSize.dimen_3),
              child: Icon(Icons.ios_share, size: AppWidgetSize.dimen_24.w)),
        ));
  }

  Widget _thumbnailScrollIndicationWidget() {
    return Positioned(
      bottom: AppWidgetSize.dimen_10,
      left: AppWidgetSize.dimen_20,
      right: AppWidgetSize.dimen_20,
      child: Center(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.stallList.mediaFiles!.map((image) {
              int index = widget.stallList.mediaFiles!.indexOf(image);
              return Container(
                alignment: Alignment.center,
                width: AppWidgetSize.dimen_18.w,
                height: 1.5,
                margin: REdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: _currentIndex == index
                      ? const Color.fromRGBO(255, 255, 255, 0.9)
                      : const Color.fromRGBO(255, 255, 255, 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  CarouselOptions _carouselOptions(BuildContext context) {
    return CarouselOptions(
      height: AppWidgetSize.screenHeight(context) * 0.6,
      viewportFraction: 1,
      initialPage: 0,
      enableInfiniteScroll: true,
      reverse: false,
      autoPlay: false,
      autoPlayInterval: const Duration(seconds: 5),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: false,
      onPageChanged: (index, reason) {
        _stallListBloc.add(ChangeThumbnailEvent(index));
        _scrollController.animateTo(
          index * (AppWidgetSize.dimen_24 + 4),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _stallTextWidget(BuildContext context,
      {required String textString, required int tag}) {
    return CommonTextWidget(
        textString: textString,
        fontWeight: tag == 0 ? FontWeight.w600 : FontWeight.w400,
        fontSize:
            tag == 0 ? AppWidgetSize.dimen_28.sp : AppWidgetSize.dimen_16.sp,
        fontColor: tag == 0
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.secondaryContainer,
        topPadding: tag == 0 ? AppWidgetSize.dimen_20 : AppWidgetSize.dimen_8,
        leftPadding: AppWidgetSize.dimen_24);
  }

  Widget _attachFilesWidget(BuildContext context) {
    return Container(
      width: AppWidgetSize.screenWidth(context),
      margin: REdgeInsets.fromLTRB(
          AppWidgetSize.dimen_16,
          AppWidgetSize.dimen_64,
          AppWidgetSize.dimen_16,
          AppWidgetSize.dimen_64),
      child: GestureDetector(
        onTap: () async {
          _pickMedia();
          await Future.delayed(const Duration(seconds: 1));
          _stallListBloc.add(StartFileSelectingEvent(tag: 0));
        },
        child: CustomDottedBorder(
            color: Theme.of(context).colorScheme.secondary,
            radius: Radius.circular(AppWidgetSize.dimen_8.r),
            child: Padding(
              padding: REdgeInsets.only(
                  top: AppWidgetSize.dimen_16, bottom: AppWidgetSize.dimen_16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_to_photos_outlined,
                    size: AppWidgetSize.dimen_24.w,
                  ),
                  _attachFileText(context)
                ],
              ),
            )),
      ),
    );
  }

  Widget _attachFileText(BuildContext context) {
    return CommonTextWidget(
      textString: AppConstants.attachFile,
      topPadding: AppWidgetSize.dimen_8,
      fontWeight: FontWeight.w500,
      fontSize: AppWidgetSize.dimen_14.sp,
      linespace: 0.37.sp,
    );
  }

  Future<void> _pickMedia() async {
    await FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        AppConstants.jpg,
        AppConstants.png,
        AppConstants.mp4,
        AppConstants.mov
      ],
      allowMultiple: true,
      allowCompression: false,
      // withData: true,
    )
        .then((value) {
      if (value != null) {
        _stallListBloc.add(UploadImagesVideosEvent(
            stallList: widget.stallList, filePickerResult: value));
      } else {
        _stallListBloc.add(StartFileSelectingEvent(tag: 1));
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _videoControllsWidget(BuildContext context) {
    return Positioned(
      bottom: AppWidgetSize.screenHeight(context) * 0.1,
      left: AppWidgetSize.screenWidth(context) * 0.15,
      right: AppWidgetSize.screenWidth(context) * 0.15,
      child: Row(
        children: [
          _commonControllsWidget(context, 0),
          _commonControllsWidget(context, 1),
          _commonControllsWidget(context, 2)
        ],
      ),
    );
  }

  Expanded _commonControllsWidget(BuildContext context, int controlTag) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            _stallListBloc.add(VideoControlsEvent(videoControlTag: controlTag));
          },
          child: Icon(
            controlTag == 0
                ? Icons.replay_10
                : controlTag == 1
                    ? isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle
                    : Icons.forward_10,
            color: controlTag != 1
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
            size: controlTag != 1
                ? AppWidgetSize.dimen_40.w
                : AppWidgetSize.dimen_72.w,
          )),
    );
  }

  Positioned _videoSliderWidget(BuildContext context) {
    return Positioned(
        bottom: AppWidgetSize.screenHeight(context) * 0.20,
        left: AppWidgetSize.screenWidth(context) * 0.08,
        right: AppWidgetSize.screenWidth(context) * 0.08,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            height: AppWidgetSize.dimen_10.w,
            child: VideoProgressIndicator(
              _videoPlayerController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.onSecondaryContainer,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                bufferedColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _commonTimerText(context,
                timerTextDuration: _videoPlayerController!.value.position),
            _commonTimerText(context,
                timerTextDuration: _videoPlayerController!.value.duration),
          ]),
        ]));
  }

  CommonTextWidget _commonTimerText(BuildContext context,
      {required Duration timerTextDuration}) {
    return CommonTextWidget(
      textString: _formatDuration(timerTextDuration),
      fontColor: Theme.of(context).colorScheme.primary,
      fontSize: AppWidgetSize.dimen_12.sp,
      fontWeight: FontWeight.w400,
      linespace: 0.37.sp,
    );
  }

  Widget _videoScreeningWidget(BuildContext context) {
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoPlayerController!.value.size.width,
          height: _videoPlayerController!.value.size.height,
          child: VideoPlayer(_videoPlayerController!),
        ),
      ),
    );
  }

  Widget _closeVideoWidget(BuildContext context) {
    return Positioned(
      right: AppWidgetSize.dimen_32.w,
      top: double.parse((AppWidgetSize.safeAreaPadding(context).top +
              AppWidgetSize.dimen_32.h)
          .toString()),
      child: GestureDetector(
        onTap: () {
          _stallListBloc.add(MediaExpandedViewEvent(fullViewTag: 0));
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(AppWidgetSize.dimen_28.r)),
                color: Theme.of(context).colorScheme.primary),
            padding: REdgeInsets.all(AppWidgetSize.dimen_3),
            child: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSecondary,
              size: AppWidgetSize.dimen_24.w,
            )),
      ),
    );
  }

  GestureDetector _videoThumbnailWidget(
      MediaFiles element, BuildContext context) {
    return GestureDetector(
      onTap: () {
        isPlaying = false;
        _stallListBloc.add(InitializeVideoPlayerEvent(isInitialized: false));
        _initializeVideoPlayer(context, element.filePath!);
      },
      child: Stack(
        children: [
          SizedBox(
              width: AppWidgetSize.screenWidth(context),
              height: AppWidgetSize.screenHeight(context) * 0.6,
              child: element.videoThumbnail!),
          Positioned(
            left: AppWidgetSize.dimen_10,
            bottom: AppWidgetSize.dimen_52,
            child: Container(
              width: AppWidgetSize.dimen_40.w,
              height: AppWidgetSize.dimen_40.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppWidgetSize.dimen_40.r)),
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.9)),
              child: Icon(
                Icons.play_arrow,
                size: AppWidgetSize.dimen_32.w,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          _shareWidget(context, element),
        ],
      ),
    );
  }
}
