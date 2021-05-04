import 'dart:html';

enum Direction { north, west, south, east }

class Actor {
  final images = new Map<String, Map<Direction, List<CanvasElement>>>();
  Direction direction = Direction.west;
  String _action = 'walk';
  int frame = 0;
  static const num timeBetweenFrames = 100;
  num timeUntilNextFrame = timeBetweenFrames;

  late final int width, height;
  late Future ready;

  Actor(Map json) {
    width = json['width'] as int;
    height = json['height'] as int;

    final src = new ImageElement(src: json['src']);
    ready = src.onLoad.first.then((_) {
      int row = 0;

      (json['actions'] as List).forEach((actionJson) {
        final name = actionJson['name'] as String;
        final numFrames = actionJson['frames'] as int;

        final dirFrames = new Map<Direction, List<CanvasElement>>();

        Direction.values.forEach((dir) {
          final List<CanvasElement> frames = [];

          for (var frame = 0; frame < numFrames; frame ++) {
            frames.add(_extractFrame(src, frame, row, width, height));
          }

          dirFrames[dir] = frames;
          row ++;
        });

        images[name] = dirFrames;
      });
    });
  }

  void setAction(String action) {
    _action = action;
    frame = 0;
  }

  CanvasElement _extractFrame(ImageElement src, int col, int row, int width, int height) {
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }

  void update(num dt) {
    timeUntilNextFrame -= dt;
    if (timeUntilNextFrame < 0) {
      timeUntilNextFrame += timeBetweenFrames;

      if (++frame >= images[_action]![direction]!.length) {
        frame = 0;
      }
    }
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.drawImage(images[_action]![direction]![frame], 100, 100);
  }
}