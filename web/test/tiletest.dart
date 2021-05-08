import 'dart:convert';
import 'dart:html';

import 'package:fast_noise/fast_noise.dart';

import '../src/sprite.dart';
import '../src/tiles.dart';

class TileTest {
  final canvas = querySelector('#canvas') as CanvasElement;
  final gridCheckbox = querySelector('#grid') as CheckboxInputElement;

  late final TerrainTileset tileSet;
  late final TileMap tileMap;

  late String clickTile;

  TileTest() {
    canvas.onMouseDown.listen((e) => mouseAction(e));
    canvas.onMouseMove.listen((e) => mouseAction(e));

    gridCheckbox.onClick.listen((_) {
      draw(canvas.context2D);
    });

    tileSet = new TerrainTileset('json/lpcTerrain.json');
    tileSet.ready.then((_) {
      addUIButtonsForTileSet(tileSet);

      clickTile = tileSet.tiles.keys.first;

      final cols = (canvas.width! / tileSet.width).floor();
      final rows = (canvas.height! / tileSet.height).floor();
      tileMap = new TileMap(tileSet: tileSet, cols: cols, rows: rows);

      // TODO: Move/generalize this
      // Inspired by: https://www.redblobgames.com/maps/terrain-from-noise/
        
      
      final height = noise2(cols + 1, rows + 1,
        noiseType: NoiseType.Perlin,
        octaves: 5,
        frequency: 0.03,
        seed: new DateTime.now().millisecondsSinceEpoch);

      final moisture = noise2(cols + 1, rows + 1,
        noiseType: NoiseType.Perlin,
        octaves: 5,
        frequency: 0.03,
        seed: new DateTime.now().millisecondsSinceEpoch);


      for (var r = 0; r <= rows; r ++) {
        for (var c = 0; c <= cols; c ++) {
          final h = height[c][r], m = moisture[c][r];
          //final shade = (height[c][r] + 0.5) * 255;
          //canvas.context2D..fillStyle = 'rgb(${shade},${shade},${shade})'..fillRect(c, r, 1, 1);
          
          String tile = 'void';

          if (h < -0.3) {
            tile = m < 0 ? 'hole' : 'water';
          }
          else {
            tile = m < 0 ? 'dirt' : 'grass';
          }

          //if (val < -0.35)     tile = tileSet.terrain['water']!;
          //else if (val < -0.3) tile = tileSet.terrain['sand']!;
          //else if (val < 0.1) tile = tileSet.terrain['dirt']!;
          //else /*if (val < 0.5)*/ tile = tileSet.terrain['grass']!;
          //else                tile = tileSet.terrain['snow']!;

          tileMap.setTerrainAt(c, r, tile);
        }
      }
              
      // Fill with grass
      //tileMap.addTerrainRectangle(0, 0, cols+1, rows+1, tileSet.terrain['grass']!);
      
      // Add some lakes
      // final random = new Random();
      // for (var i = 0; i < 10; i ++) {
      //   tileMap.addTerrainCircle(
      //     random.nextInt(tileMap.cols), random.nextInt(tileMap.rows),
      //     random.nextInt(10), tileSet.terrain['water']!);
      // }

      // tileMap.addTerrainLine(4, 4, 10, 20, tileSet.terrain['path']!);

      draw(canvas.context2D);
    });
  }

  void addUIButtonsForTileSet(TerrainTileset tileSet) {
    final buttonDiv = querySelector('#buttons')!;

    tileSet.tiles.keys.forEach((name) {
      final button = new ButtonElement();
      button.text = name;
      button.onClick.listen((_) => clickTile = name);
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
  new TileTest();
}