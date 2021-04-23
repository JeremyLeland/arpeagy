import 'dart:collection';
import 'dart:html';
import 'dart:math';

abstract class Game {
  late CanvasRenderingContext2D _ctx;
  num _lastTime = 0;
  bool _running = true;

  Keyboard keyboard = new Keyboard();
  Mouse mouse = new Mouse();

  Game() {
    final canvas = new CanvasElement(width: window.innerWidth, height: window.innerHeight);
    canvas.style.display = 'block';
    canvas.onContextMenu.listen((e) => e.preventDefault());   // suppress right click context menu
    document.body!.children.add(canvas);

    _ctx = canvas.context2D;
    window.onResize.listen((event) {
      _ctx.canvas.width =  window.innerWidth;
      _ctx.canvas.height = window.innerHeight;
    });
  }

  void setCursor(String cursor) => _ctx.canvas.style.cursor = cursor;
  int get canvasWidth => _ctx.canvas.width ?? 0;
  int get canvasHeight => _ctx.canvas.height ?? 0;

  void animate() async {
    const MAX_DT = 20;

    while (_running) {
      final num now = await window.animationFrame;

      // Do multiple updates for long delays (so we don't miss things)
      for (num dt = now - _lastTime; dt > 0; dt -= MAX_DT) {
        update(min(dt, MAX_DT));
      }

      _lastTime = now;

      _ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      draw(_ctx);
    }
  }

  void drawOnce() {
    _ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    draw(_ctx);
  }

  void update(num dt);
  void draw(CanvasRenderingContext2D ctx);
}

class Keyboard {
  final _keys = new HashSet<int>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      _keys.add(event.keyCode);
    });
    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.contains(keyCode);
}

class Mouse {
  static const int LEFT_BUTTON = 0, MIDDLE_BUTTON = 1, RIGHT_BUTTON = 2;

  num _x = 0, _y = 0;
  final _buttons = new HashSet<int>();
  
  Mouse() {
    window.onMouseDown.listen((MouseEvent event) {
      _buttons.add(event.button);
    });
    window.onMouseUp.listen((MouseEvent event) {
      _buttons.remove(event.button);
    });
    window.onMouseMove.listen((event) {
      _x = event.offset.x;
      _y = event.offset.y;
    });
  }

  num get x => _x;
  num get y => _y;
  bool isPressed(int button) => _buttons.contains(button);
}

class TimedEvent {
   num timeLeft;
   Function function;

   TimedEvent({required this.timeLeft, required this.function});

   void update(num dt) {
      timeLeft -= dt;

      if (timeLeft < 0) {
         function();
      }
   }
}