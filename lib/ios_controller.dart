// ignore_for_file: camel_case_types

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class iOSScanController {
  iOSScanController.init(int id)
      : channel = MethodChannel('terra_flutter_rt_$id');

  final MethodChannel channel;
}

typedef iOSScanControllerCreatedCallback = void Function(
    iOSScanController controller);

class iOSScanView extends StatelessWidget {
  const iOSScanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return const Expanded(child: UiKitView(viewType: 'terra_flutter_rt'));

      default:
        return Container();
    }
  }
}
