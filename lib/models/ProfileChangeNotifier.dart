import 'package:flutter/foundation.dart';

import '../common/Global.dart';
import 'Profile.dart';

// 通知
class ProfileChangeNotifier extends ChangeNotifier {
  Profile get cnprofile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}
