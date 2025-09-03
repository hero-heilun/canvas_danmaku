import 'package:flutter/material.dart';
import 'models/danmaku_item.dart';
import 'models/danmaku_content_item.dart';
import 'danmaku_hit_tester.dart';

/// 弹幕交互事件类型
enum DanmakuInteractionType {
  tap,      // 点击
  longPress, // 长按
  doubleTap, // 双击
}

/// 弹幕交互事件
class DanmakuInteractionEvent {
  final DanmakuInteractionType type;
  final DanmakuItem danmaku;
  final Offset position;
  final Rect hitRect;

  DanmakuInteractionEvent({
    required this.type,
    required this.danmaku,
    required this.position,
    required this.hitRect,
  });
}

/// 弹幕交互回调定义
typedef DanmakuTapCallback = void Function(DanmakuInteractionEvent event);
typedef DanmakuLongPressCallback = void Function(DanmakuInteractionEvent event);
typedef DanmakuDoubleTapCallback = void Function(DanmakuInteractionEvent event);

/// 弹幕交互管理器
class DanmakuInteractionManager {
  final DanmakuHitTester _hitTester = DanmakuHitTester();
  
  // 交互回调
  DanmakuTapCallback? onTap;
  DanmakuLongPressCallback? onLongPress;
  DanmakuDoubleTapCallback? onDoubleTap;
  
  // 是否启用交互
  bool _interactionEnabled = true;
  bool get interactionEnabled => _interactionEnabled;
  set interactionEnabled(bool value) => _interactionEnabled = value;

  // 弹幕数据引用
  List<DanmakuItem>? _scrollItems;
  List<DanmakuItem>? _topItems;
  List<DanmakuItem>? _bottomItems;
  List<DanmakuItem>? _specialItems;
  
  // 视图参数
  double _viewWidth = 0;
  double _viewHeight = 0;
  
  // 弹幕配置
  dynamic _option;
  
  // 当前时间获取函数
  int Function()? _getCurrentTick;

  /// 更新弹幕数据引用
  void updateDanmakuData({
    required List<DanmakuItem> scrollItems,
    required List<DanmakuItem> topItems,
    required List<DanmakuItem> bottomItems,
    required List<DanmakuItem> specialItems,
    required double viewWidth,
    required double viewHeight,
    required dynamic option,
    required int Function() getCurrentTick,
  }) {
    _scrollItems = scrollItems;
    _topItems = topItems;
    _bottomItems = bottomItems;
    _specialItems = specialItems;
    _viewWidth = viewWidth;
    _viewHeight = viewHeight;
    _option = option;
    _getCurrentTick = getCurrentTick;
  }

  /// 处理点击事件
  void handleTap(Offset position) {
    if (!_interactionEnabled || onTap == null) return;
    
    final results = _performHitTest(position);
    if (results.isNotEmpty) {
      // 选择最上层的弹幕（最后添加的）
      final hitResult = results.first;
      final event = DanmakuInteractionEvent(
        type: DanmakuInteractionType.tap,
        danmaku: hitResult.item,
        position: position,
        hitRect: hitResult.hitRect,
      );
      onTap!(event);
    }
  }

  /// 处理长按事件
  void handleLongPress(Offset position) {
    if (!_interactionEnabled || onLongPress == null) return;
    
    final results = _performHitTest(position);
    if (results.isNotEmpty) {
      final hitResult = results.first;
      final event = DanmakuInteractionEvent(
        type: DanmakuInteractionType.longPress,
        danmaku: hitResult.item,
        position: position,
        hitRect: hitResult.hitRect,
      );
      onLongPress!(event);
    }
  }

  /// 处理双击事件
  void handleDoubleTap(Offset position) {
    if (!_interactionEnabled || onDoubleTap == null) return;
    
    final results = _performHitTest(position);
    if (results.isNotEmpty) {
      final hitResult = results.first;
      final event = DanmakuInteractionEvent(
        type: DanmakuInteractionType.doubleTap,
        danmaku: hitResult.item,
        position: position,
        hitRect: hitResult.hitRect,
      );
      onDoubleTap!(event);
    }
  }

  /// 执行命中测试
  List<DanmakuHitResult> _performHitTest(Offset position) {
    if (_scrollItems == null || 
        _topItems == null || 
        _bottomItems == null || 
        _specialItems == null ||
        _option == null ||
        _getCurrentTick == null) {
      return [];
    }

    return _hitTester.hitTest(
      position,
      _scrollItems!,
      _topItems!,
      _bottomItems!,
      _specialItems!,
      _option,
      _viewWidth,
      _viewHeight,
      _getCurrentTick!(),
    );
  }

  /// 获取指定位置的弹幕信息（用于预览等场景）
  List<DanmakuItem> getDanmakuAt(Offset position) {
    final results = _performHitTest(position);
    return results.map((r) => r.item).toList();
  }

  /// 清理资源
  void dispose() {
    onTap = null;
    onLongPress = null;
    onDoubleTap = null;
    _scrollItems = null;
    _topItems = null;
    _bottomItems = null;
    _specialItems = null;
  }
}

/// 弹幕交互配置
class DanmakuInteractionConfig {
  /// 是否启用点击
  final bool enableTap;
  
  /// 是否启用长按
  final bool enableLongPress;
  
  /// 是否启用双击
  final bool enableDoubleTap;
  
  /// 长按触发延迟（毫秒）
  final int longPressDelay;
  
  /// 双击触发间隔（毫秒）
  final int doubleTapInterval;
  
  /// 是否在无弹幕时也响应事件
  final bool respondToEmptyArea;

  const DanmakuInteractionConfig({
    this.enableTap = true,
    this.enableLongPress = false,
    this.enableDoubleTap = false,
    this.longPressDelay = 500,
    this.doubleTapInterval = 300,
    this.respondToEmptyArea = false,
  });
}