import 'dart:convert';
import 'dart:html';

import 'tiles.dart';

class Arpeagy {
  static const int MAP_COLS = 25, MAP_ROWS = 25;
  final canvas = querySelector('#canvas') as CanvasElement;
  final gridCheckbox = querySelector('#grid') as CheckboxInputElement;

  late final TileSet caveTiles;
  late final TileMap tileMap;

  String clickType = 'floor';

  Arpeagy() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    gridCheckbox.onClick.listen((_) {
      draw(canvas.context2D);
    });

    HttpRequest.getString('json/caveTiles.json').then((jsonString) {
      Map cavesJson = jsonDecode(jsonString);

      caveTiles = new TileSet(cavesJson);
      caveTiles.ready.then((_) {
        addUIButtonsForTileSet(caveTiles);

        tileMap = new TileMap(caveTiles, MAP_ROWS, MAP_COLS);
        draw(canvas.context2D);
      });
    });
  }

  void addUIButtonsForTileSet(TileSet tileSet) {
    final buttonDiv = querySelector('#buttons')!;

    tileSet.tiles.keys.forEach((tileType) {
      final button = new ButtonElement();
      button.text = tileType;
      button.onClick.listen((_) => clickType = tileType);
      buttonDiv.children.add(button);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = (event.offset.x / caveTiles.width).floor();
      final row = (event.offset.y / caveTiles.height).floor();

      if (tileMap.typeMap[col][row] != clickType) {
        tileMap.typeMap[col][row] = clickType;
        draw(canvas.context2D);
      }
    }
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, ctx.canvas.width!, ctx.canvas.height!);

    tileMap.draw(ctx);

    if (gridCheckbox.checked!) {
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