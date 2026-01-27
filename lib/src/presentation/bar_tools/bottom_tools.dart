// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:vs_story_designer/src/domain/sevices/save_as_image.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/item_type.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/text_animation_type.dart';
import 'package:vs_story_designer/src/presentation/widgets/animated_onTap_button.dart';

// import 'package:vs_story_designer/src/presentation/widgets/tool_button.dart';

class BottomTools extends StatefulWidget {
  final GlobalKey contentKey;
  final Function(String imageUri) onDone;
  final Widget? onDoneButtonStyle;
  final Function? renderWidget;

  /// editor background color
  final Color? editorBackgroundColor;
  const BottomTools(
      {super.key,
      required this.contentKey,
      required this.onDone,
      this.renderWidget,
      this.onDoneButtonStyle,
      this.editorBackgroundColor});

  @override
  State<BottomTools> createState() => _BottomToolsState();
}

class _BottomToolsState extends State<BottomTools> {
  bool _createVideo = false;
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;

    return Consumer4<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier,
        PaintingNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier,
          paintingNotifier, __) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .7)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Container(
              //   // width: _size.width / 3,
              //   // height: _size.width / 3,
              //   padding: const EdgeInsets.only(left: 15),
              //   child: SizedBox(
              //     child: _preViewContainer(
              //       /// if [model.imagePath] is null/empty return preview image
              //       child: controlNotifier.mediaPath.isEmpty
              //           ? ClipRRect(
              //               borderRadius: BorderRadius.circular(8),
              //               child: GestureDetector(
              //                 onTap: () {
              //                   /// scroll to gridView page
              //                   if (controlNotifier.mediaPath.isEmpty) {
              //                     scrollNotifier.pageController.animateToPage(1,
              //                         duration:
              //                             const Duration(milliseconds: 300),
              //                         curve: Curves.ease);
              //                   }
              //                 },
              //                 child: const CoverThumbnail(
              //                   thumbnailQuality: 150,
              //                 ),
              //               ))

              //           /// return clear [imagePath] provider
              //           : GestureDetector(
              //               onTap: () {
              //                 /// clear image url variable
              //                 controlNotifier.mediaPath = '';
              //                 itemNotifier.draggableWidget.removeAt(0);
              //               },
              //               child: Container(
              //                 height: 45,
              //                 width: 45,
              //                 color: Colors.transparent,
              //                 child: Transform.scale(
              //                   scale: 0.7,
              //                   child: const Icon(
              //                     Icons.delete,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //     ),
              //   ),
              // ),
              AnimatedOnTapButton(
                  onTap: () async {
                    String pngUri;
                    if (paintingNotifier.lines.isNotEmpty ||
                        itemNotifier.draggableWidget.isNotEmpty) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                    color: Colors.white,
                                    child: Container(
                                        padding: const EdgeInsets.all(50),
                                        child:
                                            const CircularProgressIndicator())),
                              ],
                            );
                          });

                      for (var element in itemNotifier.draggableWidget) {
                        if (element.type == ItemType.gif ||
                            element.type == ItemType.video ||
                            element.animationType != TextAnimationType.none) {
                          setState(() {
                            _createVideo = true;
                          });
                        }
                      }
                      if (_createVideo) {
                        debugPrint('creating video');
                        if (widget.renderWidget != null) {
                          await widget.renderWidget!();
                        }
                      } else {
                        debugPrint('creating image');
                        await takePicture(
                                contentKey: widget.contentKey,
                                context: context,
                                saveToGallery: false,
                                fileName: controlNotifier.folderName)
                            .then((bytes) {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (bytes != null) {
                            pngUri = bytes;
                            widget.onDone(pngUri);
                          } else {
                            // ignore: avoid_print
                            print("error");
                          }
                        });
                      }
                      if (_createVideo) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Design something to save image');
                    }
                    setState(() {
                      _createVideo = false;
                    });
                  },
                  child: widget.onDoneButtonStyle ??
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                        child: const Icon(Icons.send, size: 28),
                      ))

              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: Container(
              //     width: _size.width / 4,
              //     alignment: Alignment.centerRight,
              //     padding: const EdgeInsets.only(right: 0),
              //     child: Transform.scale(
              //       scale: 0.9,
              //       child: StatefulBuilder(
              //         builder: (_, setState) {
              //         },
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _preViewContainer({child}) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.4, color: Colors.white)),
      child: child,
    );
  }
}
