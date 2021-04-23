import 'dart:collection';
import 'dart:html';
import 'dart:math';


Map cavesJSON = {
  "src": "images/cave.png",
  "width": 32,
  "height": 32,
  "tiles" : {
    "empty": {"col": 2, "row": 4},
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

class Arpeagy {
  static const int TILE_WIDTH = 32, TILE_HEIGHT = 32;
  static const ROWS = 25, COLS = 25;
  final tiles = new HashMap<String, CanvasElement>();

  final tileMap = new List.generate(ROWS, (_) => List.filled(COLS, 'empty', growable: false), growable: false);

  Arpeagy() {
    final canvas = querySelector('#canvas') as CanvasElement;
    final ctx = canvas.context2D;

    final tileSrc = new ImageElement(src: cavesJSON['src']);
    tileSrc.onLoad.listen((event) {

      (cavesJSON['tiles'] as Map).forEach((key, value) {
        tiles[key] = extractTile(tileSrc, value['col'], value['row']);
      });

      final random = new Random();
      for (var row = 0; row < ROWS; row ++) {
        for (var col = 0; col < COLS; col ++) {
          final index = random.nextInt(tiles.keys.length);
          tileMap[row][col] = tiles.keys.elementAt(index);
        }
      }

      draw(ctx);
    });
  }

  CanvasElement extractTile(ImageElement src, int col, int row) {
    final w = TILE_WIDTH, h = TILE_HEIGHT;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }

  void draw(CanvasRenderingContext2D ctx) {
    for (var row = 0; row < ROWS; row ++) {
      for (var col = 0; col < COLS; col ++) {
        final key = tileMap[row][col];
        ctx.drawImage(tiles[key]!, col * TILE_WIDTH, row * TILE_HEIGHT);
      }
    }
  }
}

void main() {
  new Arpeagy();
}