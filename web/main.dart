import 'dart:collection';
import 'dart:html';
import 'dart:math';

import 'game.dart';

Map cavesJSON = {
  "src": "images/cave.png",
  "width": 32,
  "height": 32,
  "tiles" : {
    "ground1": {"col": 0, "row": 7},
    "ground2": {"col": 1, "row": 7},
    "ground3": {"col": 0, "row": 8},
    "ground4": {"col": 1, "row": 8},
    "ground5": {"col": 0, "row": 9},
    "ground6": {"col": 1, "row": 9},
    "ground7": {"col": 0, "row": 10},
    "ground8": {"col": 1, "row": 10}
  }
};

class Arpeagy extends Game {
  static const int TILE_WIDTH = 32, TILE_HEIGHT = 32;
  final tiles = new HashMap<String, CanvasElement>();

  Arpeagy() {
    final tileSrc = new ImageElement(src: cavesJSON['src']);
    tileSrc.onLoad.listen((event) {

      (cavesJSON['tiles'] as Map).forEach((key, value) {
        tiles[key] = extractTile(tileSrc, value['col'], value['row']);
      });

      drawOnce();
    });
  }

  CanvasElement extractTile(ImageElement src, int col, int row, {int WIDTH = TILE_WIDTH, int HEIGHT = TILE_HEIGHT}) {
    final image = new CanvasElement(width: WIDTH, height: HEIGHT);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * WIDTH, row * HEIGHT, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT);
    return image;
  }

  @override
  void update(dt) {
  }

  @override
  void draw(ctx) {
    final random = new Random();
    for (var x = 0; x < canvasWidth; x += TILE_WIDTH) {
      for (var y = 0; y < canvasHeight; y += TILE_HEIGHT) {
        final index = random.nextInt(tiles.values.length);
        ctx.drawImage(tiles.values.elementAt(index), x, y);
      }
    }
  }
}

void main() {
  new Arpeagy();
}