import 'dart:html';

import 'tiles.dart';


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
    "floor": {
      "col": 0, "row": 9,
      "variations": [
        {"col": 0, "row": 9},
        {"col": 1, "row": 9},
        {"col": 0, "row": 10},
        {"col": 1, "row": 10},
      ],
      "doodads": [
        {"col": 0, "row": 7},
        {"col": 1, "row": 7},
        {"col": 0, "row": 8},
        {"col": 1, "row": 8},
      ]
    }
  }
};

class Arpeagy {
  static const int MAP_COLS = 25, MAP_ROWS = 25;
  final canvas = querySelector('#canvas') as CanvasElement;

  late final TileSet caveTiles;
  late final TileMap tileMap;

  String clickType = 'floor';
  bool isDrawGrid = false;

  Arpeagy() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    ['empty', 'water', 'floor'].forEach((tileType) {
      final button = querySelector('#${tileType}') as ButtonElement;
      button.onClick.listen((_) => clickType = tileType);
    });

    final gridCheckbox = querySelector('#grid') as CheckboxInputElement;
    gridCheckbox.onClick.listen((_) {
      isDrawGrid = gridCheckbox.checked!;
      draw(canvas.context2D);
    });

    caveTiles = new TileSet(cavesJSON);
    caveTiles.ready.then((_) {
      tileMap = new TileMap(caveTiles, MAP_ROWS, MAP_COLS);
      draw(canvas.context2D);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = (event.offset.x / caveTiles.width).floor();
      final row = (event.offset.y / caveTiles.height).floor();

      tileMap.typeMap[col][row] = clickType;

      draw(canvas.context2D);
    }
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, ctx.canvas.width!, ctx.canvas.height!);

    tileMap.draw(ctx);

    if (isDrawGrid) {
      ctx.strokeStyle = 'rgba(100, 100, 100, 0.5)';
      for (var row = 0; row < tileMap.rows; row ++) {
        for (var col = 0; col < tileMap.cols; col ++) {
          ctx.strokeRect(col * caveTiles.width, row * caveTiles.height, caveTiles.width, caveTiles.height);
        }
      }
    }
  }
}

void main() {
  new Arpeagy();
}