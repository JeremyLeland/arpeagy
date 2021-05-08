import 'dart:convert';
import 'dart:html';

class ActorSprites {
  late final int width, height;
  late final int centerX, centerY;
  final sprites = new Map<String, Map<String, List<CanvasElement>>>();
  late Future ready;

  ActorSprites(String pathToJson) {
    ready = HttpRequest.getString(pathToJson).then((jsonString) {
      Map json = jsonDecode(jsonString);

      width = json['width'] as int;
      height = json['height'] as int;
      centerX = json['centerX'] as int;
      centerY = json['centerY'] as int;

      final src = new ImageElement(src: json['src']);
      return src.onLoad.first.then((_) {
        int row = 0;

        (json['template'] as List).forEach((actionJson) {
          final name = actionJson['name'] as String;
          final dirs = actionJson['directions'] as List;
          final numFrames = actionJson['frames'] as int;

          final dirFrames = new Map<String, List<CanvasElement>>();

          dirs.forEach((dir) {
            final List<CanvasElement> frames = [];

            for (var frame = 0; frame < numFrames; frame ++) {
              frames.add(_extractImage(src, frame, row, width, height));
            }

            dirFrames[dir] = frames;
            row ++;
          });

          sprites[name] = dirFrames;
        });
      });
    });
  }

  CanvasElement getImage({required String action, required String direction, required int frame}) {
    final act = sprites[action] ?? sprites.values.first;
    final dir = act[direction] ?? act.values.first;
    return dir[frame];
  }
}

class TerrainTileset {
  late final int width, height;
  final tiles = new Map<String, Map<String, CanvasElement>>();
  late Future ready;

  TerrainTileset(String pathToJson) {
    ready = HttpRequest.getString(pathToJson).then((jsonString) {
      Map json = jsonDecode(jsonString);

      width = json['width'] as int;
      height = json['height'] as int;

      final tileSrc = new ImageElement(src: json['src']);
      return tileSrc.onLoad.first.then((_) {
        final templateJson = json['template'] as List;

        (json['terrainTypes'] as List).forEach((terrainJson) {
          final name = terrainJson['name'] as String;
          final startCol = terrainJson['col'] as int;
          final startRow = terrainJson['row'] as int;

          int row = startRow;
          final dirs = Map<String, CanvasElement>();

          templateJson.forEach((dirRow) {
            int col = startCol;
            
            (dirRow as List).forEach((dir) {
              dirs[dir] = _extractImage(tileSrc, col, row, width, height);
              col ++;
            });

            row ++;
          });

          tiles[name] = dirs;
        });
      });
    });
  }

  CanvasElement getImage({required String terrain, required String orientation}) {
    final ter = tiles[terrain] ?? tiles.values.first;
    final or = ter[orientation] ?? ter.values.first;
    return or;
  }
}

CanvasElement _extractImage(ImageElement src, int col, int row, int width, int height) {
  final w = width, h = height;
  final image = new CanvasElement(width: w, height: h);
  final ctx = image.context2D;
  ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
  return image;
}