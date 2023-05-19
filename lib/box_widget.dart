import 'package:flutter/material.dart';
import 'package:yolov7_flutter/recognition.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  final Recognition result;
  final Image image;
  final Function(Recognition recognitions)? resultsCallback;

  const BoxWidget(
      {Key? key,
      required this.result,
      required this.image,
      this.resultsCallback})
      : super(key: key);

  // @override
  @override
  Widget build(BuildContext context) {
    if (resultsCallback != null) {
      resultsCallback!(result);
    }
    //print("$result");
    // Color for bounding box
    Color color = Colors.primaries[
        (result.label.length + result.label.codeUnitAt(0) + result.id) %
            Colors.primaries.length];

    //result.renderLocation?

//result.label.toLowerCase() == "person" ?  &&
    //(result.score.clamp(0.65, 1) == result.score)

    return Positioned(
      left: result.renderLocation.left,
      top: result.renderLocation.top,
      width: result.renderLocation.width,
      height: result.renderLocation.height,
      child: Container(
        width: result.renderLocation.width,
        height: result.renderLocation.height,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.label),
                  Text(" " + result.score.toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
