import 'dart:collection';
import 'dart:html';
import 'dart:math';


Map cavesJSON = {
  "src": "images/cave.png",
  "width": 32,
  "height": 32,
  "tiles" : {
    "empty": {"col": 2, "row": 4},
    "empty_floor_SE": {"col" : 6, "row": 5},
    "empty_floor_S": {"col" : 7, "row": 5},
    "empty_floor_SW": {"col" : 8, "row": 5},
    "empty_floor_E": {"col" : 6, "row": 6},
    "empty_floor_W": {"col" : 8, "row": 6},
    "empty_floor_NE": {"col" : 6, "row": 7},
    "empty_floor_N": {"col" : 7, "row": 7},
    "empty_floor_NW": {"col" : 8, "row": 7},
    "empty_floor_S+E": {"col" : 6, "row": 8},
    "empty_floor_S+W": {"col" : 7, "row": 8},
    "empty_floor_N+E": {"col" : 6, "row": 9},
    "empty_floor_N+W": {"col" : 7, "row": 9},
    "floor1": {"col": 0, "row": 7},
    "floor2": {"col": 1, "row": 7},
    "floor3": {"col": 0, "row": 8},
    "floor4": {"col": 1, "row": 8},
    "floor5": {"col": 0, "row": 9},
    "floor6": {"col": 1, "row": 9},
    "floor7": {"col": 0, "row": 10},
    "floor8": {"col": 1, "row": 10}
  }
};

enum Cave { empty, floor }

class Arpeagy {
  static const int TILE_WIDTH = 32, TILE_HEIGHT = 32;
  static const ROWS = 25, COLS = 25;
  final tiles = new HashMap<String, CanvasElement>();

  final CanvasElement canvas = querySelector('#canvas') as CanvasElement;

  final typeMap = new List.generate(ROWS, (_) => List.filled(COLS, Cave.empty, growable: false), growable: false);

  Arpeagy() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    final tileSrc = new ImageElement(src: cavesJSON['src']);
    tileSrc.onLoad.listen((event) {

      (cavesJSON['tiles'] as Map).forEach((key, value) {
        tiles[key] = extractTile(tileSrc, value['col'], value['row']);
      });

      draw(canvas.context2D);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = (event.offset.x / TILE_WIDTH).floor();
      final row = (event.offset.y / TILE_HEIGHT).floor();

      typeMap[col][row] = Cave.floor;

      draw(canvas.context2D);
    }
  }

  CanvasElement extractTile(ImageElement src, int col, int row) {
    final w = TILE_WIDTH, h = TILE_HEIGHT;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }

  CanvasElement getTileAt(List<List<Cave>> typeMap, int col, int row) {
    final hasLeft = col > 0, hasRight = col < typeMap.length - 1;
    final hasUp = row > 0, hasDown = row < typeMap[0].length - 1;

    final nw = hasUp && hasLeft    ? typeMap[col-1][row-1] : Cave.empty;
    final n  = hasUp               ? typeMap[col  ][row-1] : Cave.empty;
    final ne = hasUp && hasRight   ? typeMap[col+1][row-1] : Cave.empty;
    final w  = hasLeft             ? typeMap[col-1][row  ] : Cave.empty;
    final x  = typeMap[col][row];
    final e  = hasRight            ? typeMap[col+1][row  ] : Cave.empty;
    final sw = hasDown && hasLeft  ? typeMap[col-1][row+1] : Cave.empty;
    final s  = hasDown             ? typeMap[col  ][row+1] : Cave.empty;
    final se = hasDown && hasRight ? typeMap[col+1][row+1] : Cave.empty;


    if (x == Cave.floor) {
      return tiles['floor5']!;
    }
    else if (x == Cave.empty) {
      if (n == Cave.floor && w == Cave.floor)   return tiles['empty_floor_N+W']!;
      if (n == Cave.floor && e == Cave.floor)   return tiles['empty_floor_N+E']!;
      if (s == Cave.floor && w == Cave.floor)   return tiles['empty_floor_S+W']!;
      if (s == Cave.floor && e == Cave.floor)   return tiles['empty_floor_S+E']!;
      if (n  == Cave.floor)   return tiles['empty_floor_N']!;
      if (w  == Cave.floor)   return tiles['empty_floor_W']!;
      if (e  == Cave.floor)   return tiles['empty_floor_E']!;
      if (s  == Cave.floor)   return tiles['empty_floor_S']!;
      if (nw == Cave.floor)   return tiles['empty_floor_NW']!;
      if (ne == Cave.floor)   return tiles['empty_floor_NE']!;
      if (sw == Cave.floor)   return tiles['empty_floor_SW']!;
      if (se == Cave.floor)   return tiles['empty_floor_SE']!;
    }

    return tiles['empty']!;
  }

  void draw(CanvasRenderingContext2D ctx) {
    for (var row = 0; row < ROWS; row ++) {
      for (var col = 0; col < COLS; col ++) {
        final tile = getTileAt(typeMap, col, row);
        ctx.drawImage(tile, col * TILE_WIDTH, row * TILE_HEIGHT);
      }
    }
  }
}

void main() {
  new Arpeagy();
}