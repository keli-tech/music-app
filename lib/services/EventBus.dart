//EventBus.dart
import 'package:event_bus/event_bus.dart';

//初始化Bus
EventBus eventBus = EventBus();

enum MusicPlayAction { play, stop, next, last, hide, show }

/**
 * 下面是定义全局监听的事件类
 * 后面根据需要依次在下面累加
 */

//商品详情中全局监听的事件（点击购物车）
class ProductDetailEvent {
  String string;

  ProductDetailEvent(this.string);
}

//商品详情中全局监听的事件（点击购物车）
class MusicPlayEvent {
  MusicPlayAction musicPlayAction;

  MusicPlayEvent(this.musicPlayAction);
}
