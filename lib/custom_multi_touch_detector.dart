import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

typedef OnUpdate(DragUpdateDetails details);
typedef OnUpdateDraw(DragUpdateDetails details);
typedef OnUpdateDrawEnd(DragEndDetails details);

class CustomMultiTouchDetector extends StatelessWidget {
  final Widget child;
  final OnUpdate onUpdate;
  final OnUpdateDraw onUpdateDraw;
  final OnUpdateDrawEnd onUpdateDrawEnd;

  CustomMultiTouchDetector(
      {this.child,
      this.onUpdate,
  this.onUpdateDraw,
      this.onUpdateDrawEnd,}
      );

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomVerticalMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                CustomVerticalMultiDragGestureRecognizer>(
          () => CustomVerticalMultiDragGestureRecognizer(),
          (CustomVerticalMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset position) {
              return CustomDrag(
                  events: instance.events,
                  onUpdate: onUpdate,
                   onUpdateDraw: onUpdateDraw,
                onUpdateDrawEnd:onUpdateDrawEnd,
              );
            };
          },
        ),
        // CustomPanGestureRecognizer:
        //     GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
        //   () => CustomPanGestureRecognizer(
        //       onPanDown: onPanDown,
        //       onPanUpdate: onPanUpdate,
        //       onPanEnd: onPanEnd),
        //   (CustomPanGestureRecognizer instance) {},
        // ),
      },
      child: child,
    );
  }
}

class CustomDrag extends Drag {
  final List<PointerDownEvent> events;

  final OnUpdate onUpdate;
  final OnUpdateDraw onUpdateDraw;
  final OnUpdateDrawEnd onUpdateDrawEnd;

  CustomDrag({this.onUpdateDrawEnd, this.events, this.onUpdate, this.onUpdateDraw});

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    final delta = details.delta;
    if(events.length == 1) {
      // print('1 finger local ${details.localPosition}, global ${details.globalPosition}');
      onUpdateDraw?.call(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: Offset(0, delta.dy),
        primaryDelta: details.primaryDelta,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
      ));
    } else if (delta.dy.abs() > 0 && events.length == 2) {
      // print('2 finger local ${details.localPosition}, global ${details.globalPosition}');
      onUpdate?.call(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: Offset(0, delta.dy),
        primaryDelta: details.primaryDelta,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
      ));
    }
  }

  @override
  void end(DragEndDetails details) {
    onUpdateDrawEnd?.call(details);
    // if(events.length == 1) {
    //   // onUpdateDraw?.call(DragUpdateDetails(
    //   //   sourceTimeStamp: details.sourceTimeStamp,
    //   //   delta: Offset(0, delta.dy),
    //   //   primaryDelta: details.primaryDelta,
    //   //   globalPosition: details.globalPosition,
    //   //   localPosition: details.localPosition,
    //   // ));
    // }
    super.end(details);
  }
}

class CustomVerticalMultiDragGestureRecognizer
    extends MultiDragGestureRecognizer<_CustomVerticalPointerState> {
  final List<PointerDownEvent> events = [];

  @override
  createNewPointerState(PointerDownEvent event) {
    events.add(event);
    return _CustomVerticalPointerState(event.position, onDisposeState: () {
      events.remove(event);
    });
  }

  @override
  String get debugDescription => 'custom vertical multidrag';
}

typedef OnDisposeState();

class _CustomVerticalPointerState extends MultiDragPointerState {
  final OnDisposeState onDisposeState;

  _CustomVerticalPointerState(Offset initialPosition, {this.onDisposeState})
      : super(initialPosition, PointerDeviceKind.touch);

  @override
  void checkForResolutionAfterMove() {
    if (pendingDelta.dy.abs() > kTouchSlop) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }

  @override
  void dispose() {
    onDisposeState?.call();
    super.dispose();
  }
}