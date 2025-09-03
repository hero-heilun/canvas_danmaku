import 'package:flutter/material.dart';
import 'models/danmaku_item.dart';
import 'models/danmaku_content_item.dart';
import 'models/danmaku_option.dart';
import 'dart:math' as math;

/// 弹幕命中测试结果
class DanmakuHitResult {
  final DanmakuItem item;
  final Rect hitRect;
  final Offset tapPosition;

  DanmakuHitResult({
    required this.item,
    required this.hitRect,
    required this.tapPosition,
  });
}

/// 弹幕命中测试器
class DanmakuHitTester {
  /// 对指定坐标进行命中测试
  List<DanmakuHitResult> hitTest(
    Offset tapPosition,
    List<DanmakuItem> scrollItems,
    List<DanmakuItem> topItems,
    List<DanmakuItem> bottomItems,
    List<DanmakuItem> specialItems,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    List<DanmakuHitResult> results = [];

    // 测试滚动弹幕
    results.addAll(_testScrollDanmaku(
      tapPosition, scrollItems, option, viewWidth, viewHeight, currentTick));

    // 测试顶部弹幕
    results.addAll(_testStaticDanmaku(
      tapPosition, topItems, option, viewWidth, viewHeight, true, currentTick));

    // 测试底部弹幕  
    results.addAll(_testStaticDanmaku(
      tapPosition, bottomItems, option, viewWidth, viewHeight, false, currentTick));

    // 测试特殊弹幕
    results.addAll(_testSpecialDanmaku(
      tapPosition, specialItems, option, viewWidth, viewHeight, currentTick));

    // 按Z轴顺序排序（后添加的在上层）
    results.sort((a, b) => b.item.creationTime.compareTo(a.item.creationTime));

    return results;
  }

  /// 测试滚动弹幕命中
  List<DanmakuHitResult> _testScrollDanmaku(
    Offset tapPosition,
    List<DanmakuItem> items,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    List<DanmakuHitResult> results = [];

    for (var item in items) {
      if (option.hideScroll || item.content.type != DanmakuItemType.scroll) {
        continue;
      }

      var rect = _calculateScrollDanmakuRect(
        item, option, viewWidth, viewHeight, currentTick);
      
      if (rect != null && rect.contains(tapPosition)) {
        results.add(DanmakuHitResult(
          item: item,
          hitRect: rect,
          tapPosition: tapPosition,
        ));
      }
    }

    return results;
  }

  /// 测试静态弹幕命中（顶部/底部）
  List<DanmakuHitResult> _testStaticDanmaku(
    Offset tapPosition,
    List<DanmakuItem> items,
    DanmakuOption option,
    double viewWidth,
    double viewHeight, // Add this
    bool isTop,
    int currentTick,
  ) {
    List<DanmakuHitResult> results = [];

    for (var item in items) {
      if ((isTop && option.hideTop) || (!isTop && option.hideBottom)) {
        continue;
      }

      var rect = _calculateStaticDanmakuRect(item, viewWidth, viewHeight, isTop);
      
      if (rect != null && rect.contains(tapPosition)) {
        results.add(DanmakuHitResult(
          item: item,
          hitRect: rect,
          tapPosition: tapPosition,
        ));
      }
    }

    return results;
  }

  /// 测试特殊弹幕命中
  List<DanmakuHitResult> _testSpecialDanmaku(
    Offset tapPosition,
    List<DanmakuItem> items,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    List<DanmakuHitResult> results = [];

    for (var item in items) {
      if (option.hideSpecial || item.content.type != DanmakuItemType.special) {
        continue;
      }

      var rect = _calculateSpecialDanmakuRect(
        item, option, viewWidth, viewHeight, currentTick);
      
      if (rect != null && rect.contains(tapPosition)) {
        results.add(DanmakuHitResult(
          item: item,
          hitRect: rect,
          tapPosition: tapPosition,
        ));
      }
    }

    return results;
  }

  /// 计算滚动弹幕当前位置
  Rect? _calculateScrollDanmakuRect(
    DanmakuItem item,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    if (item.paused) {
      return Rect.fromLTWH(
        item.xPosition,
        item.yPosition,
        item.width,
        item.height,
      );
    }
    // 检查弹幕是否还存活
    int elapsedTime = currentTick - item.creationTime;
    int durationMs = option.duration * 1000;
    
    if (elapsedTime < 0 || elapsedTime > durationMs) {
      return null; // 弹幕不在显示时间内
    }

    // 计算当前X位置
    double progress = elapsedTime / durationMs;
    double startX = viewWidth;
    double endX = -item.width;
    double currentX = startX + (endX - startX) * progress;

    return Rect.fromLTWH(
      currentX,
      item.yPosition,
      item.width,
      item.height,
    );
  }

  /// 计算静态弹幕位置（顶部/底部）
  Rect? _calculateStaticDanmakuRect(
    DanmakuItem item,
    double viewWidth,
    double viewHeight,
    bool isTop,
  ) {
    // 静态弹幕位置相对固定，居中显示
    double x = (viewWidth - item.width) / 2;
    double y = item.yPosition;

    if (!isTop) {
      y = viewHeight - item.yPosition - item.height;
    }
    
    return Rect.fromLTWH(
      x,
      y,
      item.width,
      item.height,
    );
  }

  /// 计算特殊弹幕位置
  Rect? _calculateSpecialDanmakuRect(
    DanmakuItem item,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    if (item.content is! SpecialDanmakuContentItem) {
      return null;
    }

    SpecialDanmakuContentItem specialContent = 
        item.content as SpecialDanmakuContentItem;

    // 检查特殊弹幕是否还存活
    int elapsedTime = currentTick - item.creationTime;
    if (elapsedTime < 0 || elapsedTime > specialContent.duration) {
      return null;
    }

    // 计算动画进度
    double progress = elapsedTime / specialContent.duration;
    
    // 应用缓动曲线
    double easedProgress = specialContent.easingType.transform(progress);

    // 计算位置（相对坐标转换为绝对坐标）
    double x = specialContent.translateXTween.transform(easedProgress) * viewWidth;
    double y = specialContent.translateYTween.transform(easedProgress) * viewHeight;

    return Rect.fromLTWH(
      x,
      y,
      item.width,
      item.height,
    );
  }

  /// 空间分区优化 - 根据区域快速筛选弹幕
  List<DanmakuItem> _getItemsInRegion(
    List<DanmakuItem> allItems,
    Rect region,
    DanmakuOption option,
    double viewWidth,
    double viewHeight,
    int currentTick,
  ) {
    // TODO: 实现空间分区算法来优化大量弹幕的情况
    // 当前简单实现，后续可优化
    return allItems.where((item) {
      Rect? itemRect;
      
      switch (item.content.type) {
        case DanmakuItemType.scroll:
          itemRect = _calculateScrollDanmakuRect(
            item, option, viewWidth, viewHeight, currentTick);
          break;
        case DanmakuItemType.top:
        case DanmakuItemType.bottom:
          itemRect = _calculateStaticDanmakuRect(
            item, viewWidth, viewHeight, item.content.type == DanmakuItemType.top);
          break;
        case DanmakuItemType.special:
          itemRect = _calculateSpecialDanmakuRect(
            item, option, viewWidth, viewHeight, currentTick);
          break;
      }
      
      return itemRect != null && itemRect.overlaps(region);
    }).toList();
  }
}