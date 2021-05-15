
import 'dart:convert';
import 'dart:html';

import 'sprite.dart';

class Terrain {
  bool isPassable;
  String name;

  Terrain(this.isPassable, this.name);
}

class TerrainInfo {
  late final int width, height;

  final terrainTypes = Map<String, Terrain>();

  final tiles = new Map<Terrain, Map<String, CanvasElement>>();
  late Future ready;

  TerrainInfo(String pathToJson) {
    ready = HttpRequest.getString(pathToJson).then((jsonString) {
      Map json = jsonDecode(jsonString);

      width = json['width'] as int;
      height = json['height'] as int;

      final tileSrc = new ImageElement(src: json['src']);
      return tileSrc.onLoad.first.then((_) {
        final templateJson = json['template'] as List;

        (json['terrainTypes'] as Map).forEach((name, terrainJson) {
          final isPassable = terrainJson['isPassable'] as bool;

          final terrain = new Terrain(isPassable, name);
          terrainTypes[name] = terrain;

          final startCol = terrainJson['col'] as int;
          final startRow = terrainJson['row'] as int;

          int row = startRow;
          final dirs = Map<String, CanvasElement>();

          templateJson.forEach((dirRow) {
            int col = startCol;
            
            (dirRow as List).forEach((dir) {
              dirs[dir] = Sprite.extractImage(tileSrc, col, row, width, height);
              col ++;
            });

            row ++;
          });
          
          tiles[terrain] = dirs;
        });
      });
    });
  }

  CanvasElement getImage({required Terrain terrain, required String orientation}) {
    final ter = tiles[terrain] ?? tiles.values.first;
    final or = ter[orientation] ?? ter.values.first;
    return or;
  }
}