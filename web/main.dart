import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'tiles.dart';

class Arpeagy {
  final canvas = querySelector('#canvas') as CanvasElement;
  final gridCheckbox = querySelector('#grid') as CheckboxInputElement;

  late final TileSet tileSet;
  late final TileMap tileMap;

  late Tile clickTile;

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

        clickTile = tileSet.terrain.values.first;

        final cols = (canvas.width! / tileSet.width).floor();
        final rows = (canvas.height! / tileSet.height).floor();
        tileMap = new TileMap(tileSet: tileSet, cols: cols, rows: rows);

        // TODO: Move/generalize this
        
        // Fill with grass
        tileMap.addTerrainRectangle(0, 0, cols+1, rows+1, tileSet.terrain['grass']!);
        
        // Add some lakes
        final random = new Random();
        for (var i = 0; i < 10; i ++) {
          tileMap.addTerrainCircle(
            random.nextInt(tileMap.cols), random.nextInt(tileMap.rows),
            random.nextInt(10), tileSet.terrain['water']!);
        }

        tileMap.addTerrainLine(4, 4, 10, 20, tileSet.terrain['path']!);

        draw(canvas.context2D);
      });
    });
  }

  void addUIButtonsForTileSet(TileSet tileSet) {
    final buttonDiv = querySelector('#buttons')!;

    tileSet.terrain.keys.forEach((name) {
      final button = new ButtonElement();
      button.text = name;
      button.onClick.listen((_) => clickTile = tileSet.terrain[name]!);
      buttonDiv.children.add(button);
    });
  }

  void mouseAction(MouseEvent event) {
    if (event.buttons == 1) {
      final col = ((event.offset.x + tileSet.width/2) / tileSet.width).floor();
      final row = ((event.offset.y + tileSet.height/2) / tileSet.height).floor();

      if (tileMap.getTerrainAt(col, row) != clickTile) {
        tileMap.setTerrainAt(col, row, clickTile);
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