import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_expo/src/bloc/stall_list_bloc/stall_list_bloc.dart';
import 'package:product_expo/src/router/screen_routes.dart';
import 'package:product_expo/src/screen_util/app_widget_size.dart';
import 'package:product_expo/src/screen_util/screen_util.dart';
import 'package:product_expo/src/ui/widgets/common_card_widget.dart';

import 'package:product_expo/src/ui/widgets/common_text_widget.dart';

class StallListScreen extends StatefulWidget {
  const StallListScreen({super.key});

  @override
  State<StallListScreen> createState() => _StallListScreenState();
}

class _StallListScreenState extends State<StallListScreen> {
  List<String> screenConst = ["Stalls", "StallDetails", "stallIndex"];

  late StallListBloc _stallListBloc;
  late StreamSubscription sListener;
  late ScrollController _scrollController;
  late final TextEditingController _textEditingController =
      TextEditingController();
  bool _isScrolled = false;
  bool isSearchbarNeeded = false;
  @override
  void initState() {
    super.initState();
    _setStatusBarColor();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _stallListBloc = BlocProvider.of<StallListBloc>(context);
    sListener = _stallListBloc.stream.listen(_stallListListener);
    _stallListBloc.add(LoadStallListEvent());
  }

  void _scrollListener() {
    if (_scrollController.offset > AppWidgetSize.dimen_40.h && !_isScrolled) {
      _stallListBloc.add(StallListScrollEvent());
    } else if (_scrollController.offset <= AppWidgetSize.dimen_40.h &&
        _isScrolled) {
      _stallListBloc.add(StallListScrollEvent());
    }
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFFFFF),
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    sListener.cancel();
  }

  Future<void> _stallListListener(StallListState state) async {
    if (state is StallListScrollState) {
      _stallListScrollStateChanges();
    } else if (state is ShowHideSearchOptionState) {
      _showHideSearchOption();
    } else if (state is StallListDetailedState) {
      await Navigator.pushNamed(context, ScreenRoutes.stallDetailedScreen,
          arguments: {
            screenConst[1]:
                _stallListBloc.searchList![state.selectedStallIndex],
            screenConst[2]: state.selectedStallIndex,
          }).then((value) {
        _stallListBloc.add(StallListBackNavigationEvent());
      });
      _setStatusBarColor();
    } else if (state is StallListBackNavigationState) {
      _textEditingController.text = "";
      isSearchbarNeeded = false;
      _stallListBloc
          .add(StallListSearchEvent(searchText: _textEditingController.text));
      _scrollController.jumpTo(40);
    }
  }

  void _stallListScrollStateChanges() {
    _isScrolled = !_isScrolled;

    if (_isScrolled) {
      if (_textEditingController.text.isNotEmpty) {
        isSearchbarNeeded = true;
      } else {
        isSearchbarNeeded = false;
      }
    } else {
      isSearchbarNeeded = false;
    }
  }

  void _showHideSearchOption() {
    isSearchbarNeeded = !isSearchbarNeeded;
    if (!isSearchbarNeeded) {
      _textEditingController.text = "";
      _stallListBloc
          .add(StallListSearchEvent(searchText: _textEditingController.text));
      _scrollController.jumpTo(40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StallListBloc, StallListState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: _buildSliverAppBar(context)),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(top: AppWidgetSize.dimen_20),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _silverAppbar(context),
              _bodyWidget(context),
            ],
          ),
          _stallListBloc.isNavLoading
              ? Positioned(
                  top: AppWidgetSize.screenHeight(context) * 0.2,
                  left: AppWidgetSize.screenWidth(context) * 0.2,
                  right: AppWidgetSize.screenWidth(context) * 0.2,
                  child: _loaderWidget(context))
              : Container()
        ],
      ),
    );
  }

  SliverAppBar _silverAppbar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      shadowColor: Colors.transparent,
      toolbarHeight: isSearchbarNeeded
          ? kToolbarHeight + AppWidgetSize.dimen_72.h
          : kTextTabBarHeight + AppWidgetSize.dimen_15.h,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: REdgeInsets.fromLTRB(
            AppWidgetSize.dimen_18,
            AppWidgetSize.dimen_0,
            AppWidgetSize.dimen_18,
            AppWidgetSize.dimen_8),
        title: _isScrolled
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _stallsLabelWidget(context),
                      const Spacer(),
                      _searchIcon(),
                    ],
                  ),
                  if (isSearchbarNeeded)
                    Padding(
                      padding: REdgeInsets.only(top: AppWidgetSize.dimen_16),
                      child: _searchField(context),
                    )
                ],
              )
            : _searchField(context),
      ),
    );
  }

  GestureDetector _searchIcon() {
    return GestureDetector(
        onTap: () {
          _stallListBloc.add(ShowHideSearchOptionEvent());
        },
        child: Icon(isSearchbarNeeded ? Icons.close : Icons.search));
  }

  Container _searchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_32),
          border: Border.all(
              width: AppWidgetSize.dimen_1, color: const Color(0xFFF3F3F3))),
      child: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondaryContainer,
            size: AppWidgetSize.dimen_26,
          ),
        ),
        onChanged: (value) =>
            _stallListBloc.add(StallListSearchEvent(searchText: value)),
      ),
    );
  }

  SliverList _bodyWidget(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: AppWidgetSize.expoAppPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSearchbarNeeded) _stallsLabelWidget(context),
              _stallListBloc.isLoading
                  ? _loaderWidget(context)
                  : _stallsCardWidget(context),
            ],
          ),
        )
      ]),
    );
  }

  Widget _stallsLabelWidget(BuildContext context) {
    return CommonTextWidget(
      textString: screenConst[0],
      fontColor: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.w600,
      fontSize: AppWidgetSize.dimen_32.sp,
    );
  }

  Widget _stallsCardWidget(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _stallListBloc.searchList!.length,
      itemBuilder: (context, index) => Padding(
        padding: REdgeInsets.only(top: AppWidgetSize.dimen_18),
        child: GestureDetector(
          onTap: () async {
            _stallListBloc.add(StallListDetailedEvent(
                stallListIndex: index,
                stallId: _stallListBloc.searchList![index].stallId!));
          },
          child: CommonCardWidget(
            topleftBorderRadias: AppWidgetSize.dimen_14,
            topRightBorderRadias: AppWidgetSize.dimen_14,
            bottomLeftBorderRadias: AppWidgetSize.dimen_14,
            bottomRightBorderRadias: AppWidgetSize.dimen_14,
            cardColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stallImageWidget(context, index),
                _stallDetailsWidget(context, index)
              ],
            ),
          ),
        ),
      ),
    );
  }

  _stallImageWidget(BuildContext context, int index) {
    return Container(
      height: AppWidgetSize.dimen_178.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppWidgetSize.dimen_14.r),
            topRight: Radius.circular(AppWidgetSize.dimen_14.r),
          ),
          image: DecorationImage(
            image: AssetImage(_stallListBloc.searchList![index].stallImage!),
            fit: BoxFit.cover,
          )),
    );
  }

  Widget _stallDetailsWidget(BuildContext context, int index) {
    return Container(
      padding: REdgeInsets.fromLTRB(
          AppWidgetSize.dimen_18,
          AppWidgetSize.dimen_16,
          AppWidgetSize.dimen_24,
          AppWidgetSize.dimen_26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stallTextWidget(context,
                  tag: 0,
                  textString: _stallListBloc.searchList![index].eventDate!),
              _stallTextWidget(context,
                  tag: 1,
                  textString: _stallListBloc.searchList![index].stallName!),
              _stallTextWidget(context,
                  tag: 2,
                  textString: _stallListBloc.searchList![index].category!),
              _stallTextWidget(context,
                  tag: 3,
                  textString:
                      '${_stallListBloc.searchList![index].stallMediaCount!} Files'),
            ],
          ),
          _addImagesVideosIcon(context)
        ],
      ),
    );
  }

  Widget _stallTextWidget(BuildContext context,
      {required String textString, required int tag}) {
    return CommonTextWidget(
      textString: textString,
      fontWeight: tag == 0
          ? FontWeight.w500
          : tag == 1
              ? FontWeight.w600
              : FontWeight.w400,
      fontSize:
          tag != 1 ? AppWidgetSize.dimen_16.sp : AppWidgetSize.dimen_18.sp,
      fontColor: tag != 1
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.onSecondary,
      topPadding: AppWidgetSize.dimen_6,
    );
  }

  Widget _addImagesVideosIcon(BuildContext context) {
    return Expanded(
        child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: AppWidgetSize.dimen_52.w,
              height: AppWidgetSize.dimen_52.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppWidgetSize.dimen_32.r)),
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.9)),
              child: Icon(
                Icons.add,
                size: AppWidgetSize.dimen_32.w,
                color: Theme.of(context).primaryColor,
              ),
            )));
  }

  Widget _loaderWidget(BuildContext context) {
    return SizedBox(
      height: AppWidgetSize.screenHeight(context) * 0.6,
      child: Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}
