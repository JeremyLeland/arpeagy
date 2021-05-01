import 'dart:html';

import 'dart:math';


final _random = new Random();

class TerrainTile {
  final _images = new Map<String, CanvasElement>();

  TerrainTile(Map templateJson, ImageElement src, int startCol, int startRow, int width, int height) {
    templateJson.forEach((pattern, tileJson) {
      final col = startCol + tileJson['col'] as int;
      final row = startRow + tileJson['row'] as int;
      _images[pattern] = _extractTile(src, col, row, width, height);
    });
  }

  CanvasElement _extractTile(ImageElement src, int col, int row, int width, int height) {
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }

  CanvasElement? getImage(String? pattern) {
    if (pattern == 'NW+NE+SW+SE' && _random.nextDouble() < 0.1) {
      return _images['variants${_random.nextInt(3) + 1}'];
    }

    return _images[pattern];
  }
}

class TileSet {
  final terrainTiles = new Map<String, TerrainTile>();
  late final int width, height;
  late Future ready;

  TileSet(Map json) {
    width = json['width'] as int;
    height = json['height'] as int;

    final tileSrc = new ImageElement(src: json['src']);
    ready = tileSrc.onLoad.first.then((_) {
      final templateJson = json['template'] as Map;

      (json['terrainTypes'] as List).forEach((terrainJson) {
        final name = terrainJson['name'] as String;
        final startCol = terrainJson['col'] as int;
        final startRow = terrainJson['row'] as int;
        terrainTiles[name] = new TerrainTile(templateJson, tileSrc, startCol, startRow, width, height);
      });
    });
  }
}

class TileMap {
  final int cols, rows;
  final TileSet tileSet;
  late List<List<String>> terrainPoints;

  TileMap({required this.tileSet, required this.cols, required this.rows}) {
    // the control points to generate the terrain tiles (NW, NE, SW, SE corners of tile)
    // this will be 1 row and 1 col bigger than map, so that every tile has all 4 corners
    final defaultTile = tileSet.terrainTiles.keys.last;
    terrainPoints = new List.generate(cols + 1, 
      (_) => List.filled(rows + 1, defaultTile, growable: false), growable: false);
  }

  void _drawTileAt(CanvasRenderingContext2D ctx, int col, int row) {
    final nw = terrainPoints[col    ][row    ];
    final ne = terrainPoints[col + 1][row    ];
    final sw = terrainPoints[col    ][row + 1];
    final se = terrainPoints[col + 1][row + 1];

    final layers = Map<String, List<String>>();
    layers.putIfAbsent(nw, () => []).add('NW');
    layers.putIfAbsent(ne, () => []).add('NE');
    layers.putIfAbsent(sw, () => []).add('SW');
    layers.putIfAbsent(se, () => []).add('SE');

    tileSet.terrainTiles.forEach((terrain, tile) {
      final pattern = layers[terrain]?.join('+');
      final image = tile.getImage(pattern);
      if (image != null) {
        ctx.drawImage(image, col * tileSet.width, row * tileSet.width);
      }
    });
  }

  void draw(CanvasRenderingContext2D ctx) {
    for (var row = 0; row < rows; row ++) {
      for (var col = 0; col < cols; col ++) {
        _drawTileAt(ctx, col, row);
      }
    }
  }
}