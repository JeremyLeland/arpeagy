import 'dart:convert';
import 'dart:html';

class ActorSprites {
  late final int width, height;
  late final int centerX, centerY;

  late final _numFramesForAction = new Map<String, int>();

  final _sprites = new Map<String, Map<String, Map<String, List<CanvasElement>>>>();
  late Future ready;

  ActorSprites(String pathToJson) {
    ready = HttpRequest.getString(pathToJson).then((jsonString) {
      Map json = jsonDecode(jsonString);

      width = json['width'] as int;
      height = json['height'] as int;
      centerX = json['centerX'] as int;
      centerY = json['centerY'] as int;

      final srcImages = new Map<String, ImageElement>();
      final List<Future> srcReady = [];

      (json['src'] as Map).forEach((key, path) {
        final src = new ImageElement(src: path);
        srcReady.add(src.onLoad.first);
        srcImages[key] = src;
      });

      return Future.wait(srcReady).then((_) {
        srcImages.forEach((layer, src) { 
          int row = 0;

          final actionDirFrames = new Map<String, Map<String, List<CanvasElement>>>();

          (json['template'] as List).forEach((actionJson) {
            final action = actionJson['action'] as String;
            final dirs = actionJson['directions'] as List;
            final numFrames = actionJson['frames'] as int;

            _numFramesForAction[action] = numFrames;

            final dirFrames = new Map<String, List<CanvasElement>>();
            dirs.forEach((dir) {
              final List<CanvasElement> frames = [];

              for (var frame = 0; frame < numFrames; frame ++) {
                frames.add(Sprite.extractImage(src, frame, row, width, height));
              }

              dirFrames[dir] = frames;
              row ++;
            });

            actionDirFrames[action] = dirFrames;
          });

          _sprites[layer] = actionDirFrames;
        });
      });
    });
  }

  int numFramesForAction(String action) => _numFramesForAction[action]!;

  CanvasElement getImage({required String layer, required String action, required String direction, required int frame}) {
    final lay = _sprites[layer] ?? _sprites.values.first;
    final act = lay[action] ?? lay.values.first;
    final dir = act[direction] ?? act.values.first;
    return dir[frame];
  }
}



class Sprite {
  static CanvasElement extractImage(ImageElement src, int col, int row, int width, int height) {
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }
}
