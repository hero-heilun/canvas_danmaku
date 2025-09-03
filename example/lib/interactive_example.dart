import 'package:flutter/material.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';

class InteractiveDanmakuExample extends StatefulWidget {
  @override
  _InteractiveDanmakuExampleState createState() => 
      _InteractiveDanmakuExampleState();
}

class _InteractiveDanmakuExampleState extends State<InteractiveDanmakuExample> {
  late DanmakuController _controller;
  String _lastInteraction = '点击弹幕试试看！';
  int _danmakuCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Danmaku Example'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 状态显示区域
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '交互状态:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(_lastInteraction),
              ],
            ),
          ),
          
          // 弹幕显示区域
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // 模拟视频播放器背景
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
                  
                  // 弹幕组件
                  DanmakuScreen(
                    createdController: (controller) {
                      _controller = controller;
                      _addSampleDanmaku();
                    },
                    option: DanmakuOption(
                      fontSize: 18,
                      duration: 8,
                      opacity: 0.9,
                    ),
                    // 启用交互配置
                    interactionConfig: DanmakuInteractionConfig(
                      enableTap: true,
                      enableLongPress: true,
                      enableDoubleTap: true,
                    ),
                    // 点击回调
                    onDanmakuTap: (event) {
                      if (event.danmaku.paused) {
                        _controller.resumeDanmaku(event.danmaku);
                        setState(() {
                          _lastInteraction = '恢复了弹幕: "${event.danmaku.content.text}"';
                        });
                      } else {
                        _controller.pauseDanmaku(event.danmaku);
                        setState(() {
                          _lastInteraction = '暂停了弹幕: "${event.danmaku.content.text}"';
                        });
                      }
                    },
                    // 长按回调
                    onDanmakuLongPress: (event) {
                      setState(() {
                        _lastInteraction = 
                            '长按了弹幕: \"${event.danmaku.content.text}\"\\n'
                            '显示菜单或更多选项';
                      });
                      
                      _showDanmakuMenu(event);
                    },
                    // 双击回调
                    onDanmakuDoubleTap: (event) {
                      setState(() {
                        _lastInteraction = 
                            '双击了弹幕: \"${event.danmaku.content.text}\"\\n'
                            '执行特殊操作';
                      });
                      
                      _likeDanmaku(event.danmaku);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // 控制按钮区域
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addRandomDanmaku,
                        child: Text('添加弹幕'),
                      ),
                      ElevatedButton(
                        onPressed: () => _controller.pause(),
                        child: Text('暂停'),
                      ),
                      ElevatedButton(
                        onPressed: () => _controller.resume(),
                        child: Text('继续'),
                      ),
                      ElevatedButton(
                        onPressed: () => _controller.clear(),
                        child: Text('清空'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _controller.setInteractionEnabled(true),
                      child: Text('启用交互'),
                    ),
                    ElevatedButton(
                      onPressed: () => _controller.setInteractionEnabled(false),
                      child: Text('禁用交互'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 添加示例弹幕
  void _addSampleDanmaku() {
    final sampleTexts = [
      '这是一条可以点击的弹幕！',
      '试试长按我看看会发生什么',
      '双击我有惊喜哦~',
      '交互式弹幕真的很棒！',
      '点我点我点我！',
    ];

    for (int i = 0; i < sampleTexts.length; i++) {
      Future.delayed(Duration(seconds: i * 2), () {
        if (mounted) {
          _controller.addDanmaku(DanmakuContentItem(
            sampleTexts[i],
            color: _getRandomColor(),
            type: DanmakuItemType.scroll,
          ));
        }
      });
    }
  }

  /// 添加随机弹幕
  void _addRandomDanmaku() {
    _danmakuCounter++;
    final randomTexts = [
      '随机弹幕 #$_danmakuCounter',
      '这是第 $_danmakuCounter 条弹幕',
      '点击我试试看！#$_danmakuCounter',
      '交互测试弹幕 $_danmakuCounter',
      'Hello World! #$_danmakuCounter',
    ];

    _controller.addDanmaku(DanmakuContentItem(
      randomTexts[_danmakuCounter % randomTexts.length],
      color: _getRandomColor(),
      type: _getRandomType(),
    ));
  }

  /// 获取随机颜色
  Color _getRandomColor() {
    final colors = [
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  /// 获取随机弹幕类型
  DanmakuItemType _getRandomType() {
    final types = [
      DanmakuItemType.scroll,
      DanmakuItemType.scroll, // 增加滚动弹幕的概率
      DanmakuItemType.top,
      DanmakuItemType.bottom,
    ];
    return types[DateTime.now().millisecond % types.length];
  }

  /// 显示弹幕信息
  void _showDanmakuInfo(DanmakuItem danmaku) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('弹幕信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('内容: ${danmaku.content.text}'),
            Text('颜色: ${danmaku.content.color}'),
            Text('类型: ${danmaku.content.type}'),
            Text('创建时间: ${danmaku.creationTime}'),
            Text('位置: (${danmaku.xPosition.toInt()}, ${danmaku.yPosition.toInt()})'),
            Text('大小: ${danmaku.width.toInt()} x ${danmaku.height.toInt()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示弹幕菜单
  void _showDanmakuMenu(DanmakuInteractionEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '弹幕操作菜单',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('复制弹幕'),
              onTap: () {
                Navigator.pop(context);
                // 这里可以实现复制到剪贴板的功能
                _copyDanmaku(event.danmaku.content.text);
              },
            ),
            ListTile(
              leading: Icon(Icons.reply),
              title: Text('回复弹幕'),
              onTap: () {
                Navigator.pop(context);
                _replyToDanmaku(event.danmaku);
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('举报弹幕'),
              onTap: () {
                Navigator.pop(context);
                _reportDanmaku(event.danmaku);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 复制弹幕
  void _copyDanmaku(String text) {
    setState(() {
      _lastInteraction = '已复制弹幕: \"$text\"';
    });
  }

  /// 回复弹幕
  void _replyToDanmaku(DanmakuItem danmaku) {
    _controller.addDanmaku(DanmakuContentItem(
      '回复: ${danmaku.content.text}',
      color: Colors.lightBlue,
      type: DanmakuItemType.scroll,
    ));
    
    setState(() {
      _lastInteraction = '已回复弹幕';
    });
  }

  /// 举报弹幕
  void _reportDanmaku(DanmakuItem danmaku) {
    setState(() {
      _lastInteraction = '已举报弹幕: \"${danmaku.content.text}\"';
    });
  }

  /// 点赞弹幕
  void _likeDanmaku(DanmakuItem danmaku) {
    // 添加一个点赞反馈弹幕
    _controller.addDanmaku(DanmakuContentItem(
      '👍',
      color: Colors.red,
      type: DanmakuItemType.top,
    ));
    
    setState(() {
      _lastInteraction = '为弹幕点赞: \"${danmaku.content.text}\"';
    });
  }
}