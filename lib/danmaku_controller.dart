import 'package:flutter/material.dart';
import 'models/danmaku_option.dart';
import '/models/danmaku_content_item.dart';
import 'models/danmaku_item.dart';
import 'danmaku_interaction.dart';

class DanmakuController {
  final Function(DanmakuContentItem) onAddDanmaku;
  final Function(DanmakuOption) onUpdateOption;
  final Function onPause;
  final Function onResume;
  final Function onClear;
  
  // 交互相关属性
  DanmakuInteractionManager? _interactionManager;
  
  DanmakuController({
    required this.onAddDanmaku,
    required this.onUpdateOption,
    required this.onPause,
    required this.onResume,
    required this.onClear,
  });

  bool _running = true;

  /// 是否运行中
  /// 可以调用pause()暂停弹幕
  bool get running => _running;
  set running(e) {
    _running = e;
  }

  DanmakuOption _option = DanmakuOption();
  DanmakuOption get option => _option;
  set option(e) {
    _option = e;
  }

  /// 暂停弹幕
  void pause() {
    onPause.call();
  }

  /// 继续弹幕
  void resume() {
    onResume.call();
  }

  /// 清空弹幕
  void clear() {
    onClear.call();
  }

  /// 添加弹幕
  void addDanmaku(DanmakuContentItem item) {
    onAddDanmaku.call(item);
  }

  /// 更新弹幕配置
  void updateOption(DanmakuOption option) {
    onUpdateOption.call(option);
  }
  
  /// 设置交互管理器（内部使用）
  void setInteractionManager(DanmakuInteractionManager manager) {
    _interactionManager = manager;
  }
  
  /// 启用/禁用交互
  void setInteractionEnabled(bool enabled) {
    _interactionManager?.interactionEnabled = enabled;
  }
  
  /// 检查交互是否启用
  bool get isInteractionEnabled => 
      _interactionManager?.interactionEnabled ?? false;
  
  /// 设置弹幕点击回调
  void setOnDanmakuTap(DanmakuTapCallback? callback) {
    if (_interactionManager != null) {
      _interactionManager!.onTap = callback;
    }
  }
  
  /// 设置弹幕长按回调
  void setOnDanmakuLongPress(DanmakuLongPressCallback? callback) {
    if (_interactionManager != null) {
      _interactionManager!.onLongPress = callback;
    }
  }
  
  /// 设置弹幕双击回调
  void setOnDanmakuDoubleTap(DanmakuDoubleTapCallback? callback) {
    if (_interactionManager != null) {
      _interactionManager!.onDoubleTap = callback;
    }
  }
  
  /// 获取指定位置的弹幕（用于调试或预览）
  List<DanmakuItem> getDanmakuAt(Offset position) {
    return _interactionManager?.getDanmakuAt(position) ?? [];
  }
}
