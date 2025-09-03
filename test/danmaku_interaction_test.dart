import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';

void main() {
  group('DanmakuHitTester Tests', () {
    late DanmakuHitTester hitTester;
    late DanmakuOption option;
    late List<DanmakuItem> scrollItems;
    late List<DanmakuItem> topItems;
    late List<DanmakuItem> bottomItems;
    late List<DanmakuItem> specialItems;

    setUp(() {
      hitTester = DanmakuHitTester();
      option = DanmakuOption();
      scrollItems = [];
      topItems = [];
      bottomItems = [];
      specialItems = [];
    });

    test('hitTest should return empty list when no danmaku items', () {
      final results = hitTester.hitTest(
        Offset(100, 100),
        scrollItems,
        topItems,
        bottomItems,
        specialItems,
        option,
        800.0,
        600.0,
        1000,
      );

      expect(results, isEmpty);
    });

    test('hitTest should detect scroll danmaku correctly', () {
      // 创建一个滚动弹幕
      final danmaku = DanmakuItem(
        content: DanmakuContentItem('测试弹幕'),
        creationTime: 0,
        width: 100,
        height: 20,
        xPosition: 400,
        yPosition: 100,
      );
      scrollItems.add(danmaku);

      // 测试命中
      final results = hitTester.hitTest(
        Offset(450, 110), // 在弹幕范围内
        scrollItems,
        topItems,
        bottomItems,
        specialItems,
        option,
        800.0,
        600.0,
        500, // 弹幕运行到一半的时间
      );

      expect(results, isNotEmpty);
      expect(results.first.item, equals(danmaku));
    });

    test('hitTest should not detect danmaku when outside bounds', () {
      final danmaku = DanmakuItem(
        content: DanmakuContentItem('测试弹幕'),
        creationTime: 0,
        width: 100,
        height: 20,
        xPosition: 400,
        yPosition: 100,
      );
      scrollItems.add(danmaku);

      // 测试未命中
      final results = hitTester.hitTest(
        Offset(200, 50), // 在弹幕范围外
        scrollItems,
        topItems,
        bottomItems,
        specialItems,
        option,
        800.0,
        600.0,
        500,
      );

      expect(results, isEmpty);
    });
  });

  group('DanmakuInteractionManager Tests', () {
    late DanmakuInteractionManager interactionManager;

    setUp(() {
      interactionManager = DanmakuInteractionManager();
    });

    tearDown(() {
      interactionManager.dispose();
    });

    test('should be enabled by default', () {
      expect(interactionManager.interactionEnabled, isTrue);
    });

    test('should be able to disable interaction', () {
      interactionManager.interactionEnabled = false;
      expect(interactionManager.interactionEnabled, isFalse);
    });

    test('should handle tap callback correctly', () {
      bool callbackCalled = false;
      DanmakuInteractionEvent? receivedEvent;

      interactionManager.onTap = (event) {
        callbackCalled = true;
        receivedEvent = event;
      };

      // 模拟设置弹幕数据
      interactionManager.updateDanmakuData(
        scrollItems: [
          DanmakuItem(
            content: DanmakuContentItem('测试'),
            creationTime: 0,
            width: 100,
            height: 20,
            xPosition: 400,
            yPosition: 100,
          )
        ],
        topItems: [],
        bottomItems: [],
        specialItems: [],
        viewWidth: 800,
        viewHeight: 600,
        option: DanmakuOption(),
        getCurrentTick: () => 500,
      );

      interactionManager.handleTap(Offset(450, 110));

      expect(callbackCalled, isTrue);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.type, equals(DanmakuInteractionType.tap));
    });
  });

  group('DanmakuController Interaction Tests', () {
    test('should support interaction callbacks', () {
      final controller = DanmakuController(
        onAddDanmaku: (_) {},
        onUpdateOption: (_) {},
        onPause: () {},
        onResume: () {},
        onClear: () {},
      );

      // 创建交互管理器并设置给控制器
      final interactionManager = DanmakuInteractionManager();
      controller.setInteractionManager(interactionManager);

      expect(controller.isInteractionEnabled, isTrue);

      controller.setInteractionEnabled(false);
      expect(controller.isInteractionEnabled, isFalse);

      controller.setInteractionEnabled(true);
      expect(controller.isInteractionEnabled, isTrue);

      interactionManager.dispose();
    });
  });

  group('DanmakuInteractionConfig Tests', () {
    test('should have correct default values', () {
      const config = DanmakuInteractionConfig();

      expect(config.enableTap, isTrue);
      expect(config.enableLongPress, isFalse);
      expect(config.enableDoubleTap, isFalse);
      expect(config.longPressDelay, equals(500));
      expect(config.doubleTapInterval, equals(300));
      expect(config.respondToEmptyArea, isFalse);
    });

    test('should support custom configuration', () {
      const config = DanmakuInteractionConfig(
        enableTap: false,
        enableLongPress: true,
        enableDoubleTap: true,
        longPressDelay: 1000,
        doubleTapInterval: 500,
        respondToEmptyArea: true,
      );

      expect(config.enableTap, isFalse);
      expect(config.enableLongPress, isTrue);
      expect(config.enableDoubleTap, isTrue);
      expect(config.longPressDelay, equals(1000));
      expect(config.doubleTapInterval, equals(500));
      expect(config.respondToEmptyArea, isTrue);
    });
  });
}