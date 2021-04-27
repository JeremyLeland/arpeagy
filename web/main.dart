import 'dart:html';
import 'dart:math';


Map cavesJSON = {
  "src": "images/cave.png",
  "width": 32,
  "height": 32,
  "tiles" : {
    "empty": {
      "col": 2, "row": 4,
      "edges": {
        "floor": {
          "SE": {"col" : 6, "row": 5},
          "S": {"col" : 7, "row": 5},
          "SW": {"col" : 8, "row": 5},
          "E": {"col" : 6, "row": 6},
          "W": {"col" : 8, "row": 6},
          "NE": {"col" : 6, "row": 7},
          "N": {"col" : 7, "row": 7},
          "NW": {"col" : 8, "row": 7},
          "S+E": {"col" : 6, "row": 8},
          "S+W": {"col" : 7, "row": 8},
          "N+E": {"col" : 6, "row": 9},
          "N+W": {"col" : 7, "row": 9},
        }
      }
    },
    "water": {
      "col": 2, "row": 3,
      "edges": {
        "floor": {
          "SE": {"col" : 0, "row": 0},
          "S": {"col" : 1, "row": 0},
          "SW": {"col" : 2, "row": 0},
          "E": {"col" : 0, "row": 1},
          "W": {"col" : 2, "row": 1},
          "NE": {"col" : 0, "row": 2},
          "N": {"col" : 1, "row": 2},
          "NW": {"col" : 2, "row": 2},
          "S+E": {"col" : 0, "row": 3},
          "S+W": {"col" : 1, "row": 3},
          "N+E": {"col" : 0, "row": 4},
          "N+W": {"col" : 1, "row": 4},
        }
      }
    },
    "floor1": {"col": 0, "row": 7},
    "floor2": {"col": 1, "row": 7},
    "floor3": {"col": 0, "row": 8},
    "floor4": {"col": 1, "row": 8},
    "floor": {"col": 0, "row": 9},
    "floor6": {"col": 1, "row": 9},
    "floor7": {"col": 0, "row": 10},
    "floor8": {"col": 1, "row": 10}
  }
};

class EdgeInfo {
  CanvasElement? northWest, north, northEast, west, east, southWest, south, southEast;
  CanvasElement? northAndWest, northAndEast, southAndWest, southAndEast;
}

class TileInfo {
  late CanvasElement image;
  final edges = new Map<String, EdgeInfo>();

  TileInfo(Map json, ImageElement src, int width, int height) {
    image = _extractTile(src, json, width, height);

    if (json.containsKey('edges')) {
      (json['edges'] as Map).forEach((key, value) {
        final edgeInfo = new EdgeInfo();
        edgeInfo.northWest = _extractTile(src, value['NW'], width, height);
        edgeInfo.north     = _extractTile(src, value['N'],  width, height);
        edgeInfo.northEast = _extractTile(src, value['NE'], width, height);
        edgeInfo.west      = _extractTile(src, value['W'],  width, height);
        edgeInfo.east      = _extractTile(src, value['E'],  width, height);
        edgeInfo.southWest = _extractTile(src, value['SW'], width, height);
        edgeInfo.south     = _extractTile(src, value['S'],  width, height);
        edgeInfo.southEast = _extractTile(src, value['SE'], width, height);

        edgeInfo.northAndWest = _extractTile(src, value['N+W'], width, height);
        edgeInfo.northAndEast = _extractTile(src, value['N+E'], width, height);
        edgeInfo.southAndWest = _extractTile(src, value['S+W'], width, height);
        edgeInfo.southAndEast = _extractTile(src, value['S+E'], width, height);

        edges[key] = edgeInfo;
      });
    }
  }

  CanvasElement _extractTile(ImageElement src, Map json, int width, int height) {
    final col = json['col'], row = json['row'];
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }
}


class Arpeagy {
  static const int TILE_WIDTH = 32, TILE_HEIGHT = 32;
  static const ROWS = 25, COLS = 25;
  final tiles = new Map<String, TileInfo>();

  final canvas = querySelector('#canvas') as CanvasElement;
  final emptyButton = querySelector('#empty') as ButtonElement;
  final waterButton = querySelector('#water') as ButtonElement;
  final floorButton = querySelector('#floor') as ButtonElement;

  final typeMap = new List.generate(ROWS, (_) => List.filled(COLS, 'empty', growable: false), growable: false);
  var clickType = 'floor';

  Arpeagy() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    emptyButton.onClick.listen((_) => clickType = 'empty');
    waterButton.onClick.listen((_) => clickType = 'water');
    floorButton.onClick.listen((_) => clickType = 'floor');

    final tileSrc = new ImageElement(src: cavesJSON['src']);
    tileSrc.onLoad.listen((event) {

      (cavesJSON['tiles'] as Map).forEach((key, value) {
        tiles[key] = new TileInfo(value, tileSrc, TILE_WIDTH, TILE_HEIGHT);
      });

      draw(canvas.context2D);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = (event.offset.x / TILE_WIDTH).floor();
      final row = (event.offset.y / TILE_HEIGHT).floor();

      typeMap[col][row] = clickType;

      draw(canvas.context2D);
    }
  }

  

  CanvasElement getTileAt(List<List<String>> typeMap, int col, int row) {
    final hasLeft = col > 0, hasRight = col < typeMap.length - 1;
    final hasUp = row > 0, hasDown = row < typeMap[0].length - 1;

    final nw = hasUp && hasLeft    ? typeMap[col-1][row-1] : '';
    final n  = hasUp               ? typeMap[col  ][row-1] : '';
    final ne = hasUp && hasRight   ? typeMap[col+1][row-1] : '';
    final w  = hasLeft             ? typeMap[col-1][row  ] : '';
    final x  = typeMap[col][row];
    final e  = hasRight            ? typeMap[col+1][row  ] : '';
    final sw = hasDown && hasLeft  ? typeMap[col-1][row+1] : '';
    final s  = hasDown             ? typeMap[col  ][row+1] : '';
    final se = hasDown && hasRight ? typeMap[col+1][row+1] : '';

    final self = tiles[x]!;
    final adj = {nw, n, ne, w, e, sw, s, se}.where((t) => t != '' && t != x);

    if (adj.length == 1) {
      final other = adj.first;

      if (self.edges.containsKey(other)) {
        final edge = self.edges[other]!;

        if (n == other && w == other)   return edge.northAndWest ?? self.image;
        if (n == other && e == other)   return edge.northAndEast ?? self.image;
        if (s == other && w == other)   return edge.southAndWest ?? self.image;
        if (s == other && e == other)   return edge.southAndEast ?? self.image;
        if (n  == other)   return edge.north ?? self.image;
        if (w  == other)   return edge.west ?? self.image;
        if (e  == other)   return edge.east ?? self.image;
        if (s  == other)   return edge.south ?? self.image;
        if (nw == other)   return edge.northWest ?? self.image;
        if (ne == other)   return edge.northEast ?? self.image;
        if (sw == other)   return edge.southWest ?? self.image;
        if (se == other)   return edge.southEast ?? self.image;
      }
    }
    
    return self.image;
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, ctx.canvas.width!, ctx.canvas.height!);

    for (var row = 0; row < ROWS; row ++) {
      for (var col = 0; col < COLS; col ++) {
        final tile = getTileAt(typeMap, col, row);
        ctx.drawImage(tile, col * TILE_WIDTH, row * TILE_HEIGHT);

        ctx.strokeStyle = 'rgba(100, 100, 100, 0.5)';
        ctx.strokeRect(col * TILE_WIDTH, row * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
      }
    }
  }
}

void main() {
  new Arpeagy();
}