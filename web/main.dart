import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'tiles.dart';

class Arpeagy {
  final canvas = querySelector('#canvas') as CanvasElement;
  final gridCheckbox = querySelector('#grid') as CheckboxInputElement;

  late final TileSet tileSet;
  late final TileMap tileMap;

  String clickType = '';

  Arpeagy() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    gridCheckbox.onClick.listen((_) {
      draw(canvas.context2D);
    });

    HttpRequest.getString('json/lpcTerrain.json').then((jsonString) {
      Map cavesJson = jsonDecode(jsonString);

      tileSet = new TileSet(cavesJson);
      tileSet.ready.then((_) {
        addUIButtonsForTileSet(tileSet);

        final cols = (canvas.width! / tileSet.width).floor();
        final rows = (canvas.height! / tileSet.height).floor();
        tileMap = new TileMap(tileSet: tileSet, cols: cols, rows: rows);

        // TODO: Move/generalize this
        
        // Add some lakes
        final random = new Random();
        for (var i = 0; i < 10; i ++) {
          tileMap.addTerrainCircle(
            col: random.nextInt(tileMap.cols), row: random.nextInt(tileMap.rows),
            radius: random.nextInt(10), terrain: 'water');
        }

        draw(canvas.context2D);
      });
    });
  }

  void addUIButtonsForTileSet(TileSet tileSet) {
    final buttonDiv = querySelector('#buttons')!;

    tileSet.terrainTiles.keys.forEach((name) {
      final button = new ButtonElement();
      button.text = name;
      button.onClick.listen((_) => clickType = name);
      buttonDiv.children.add(button);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = ((event.offset.x + tileSet.width/2) / tileSet.width).floor();
      final row = ((event.offset.y + tileSet.height/2) / tileSet.height).floor();

      if (tileMap.getTerrainAt(col: col, row: row) != clickType) {
        tileMap.setTerrainAt(col: col, row: row, terrain: clickType);
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
          ctx.strokeRect(col * tileSet.width, row * tileSet.height, tileSet.width, tileSet.height);
        }
      }
    }
  }
}

void main() {
  new Arpeagy();
}