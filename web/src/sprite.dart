import 'dart:html';

class Sprite {
  final int width, height;
  final List<CanvasElement> frames = [];

  Sprite(this.width, this.height);
}

class SpriteSet {
  final sprites = new Map<String, Map<String, Sprite>>();
  late final int width, height;
  late final int centerX, centerY;
  late Future ready;

  SpriteSet(this.width, this.height, this.centerX, this.centerY);

  static SpriteSet fromCharacterJson(Map json) {
    final w = json['width'] as int, h = json['height'] as int;
    final cx = json['centerX'] as int, cy = json['centerY'] as int;
    final spriteSet = new SpriteSet(w, h, cx, cy);

    final src = new ImageElement(src: json['src']);
    spriteSet.ready = src.onLoad.first.then((_) {
      int row = 0;

      (json['template'] as List).forEach((actionJson) {
        final name = actionJson['name'] as String;
        final dirs = actionJson['directions'] as List;
        final numFrames = actionJson['frames'] as int;

        final dirFrames = new Map<String, Sprite>();

        dirs.forEach((dir) {
          final sprite = new Sprite(spriteSet.width, spriteSet.height);

          for (var frame = 0; frame < numFrames; frame ++) {
            sprite.frames.add(_extractImage(src, frame, row, sprite.width, sprite.height));
          }

          dirFrames[dir] = sprite;
          row ++;
        });

        spriteSet.sprites[name] = dirFrames;
      });  
    });

    return spriteSet;
  }

  Sprite getSprite({required String action, required String direction}) {
    final act = sprites[action] ?? sprites.values.first;
    final dir = act[direction] ?? act.values.first;
    return dir;
  }

  static CanvasElement _extractImage(ImageElement src, int col, int row, int width, int height) {
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }
}