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
  late List<List<String>> _terrainPoints;

  TileMap({required this.tileSet, required this.cols, required this.rows}) {
    // the control points to generate the terrain tiles (NW, NE, SW, SE corners of tile)
    // this will be 1 row and 1 col bigger than map, so that every tile has all 4 corners
    _terrainPoints = new List.generate(cols + 1, 
      (_) => List.filled(rows + 1, '', growable: false), growable: false);
  }

  String getTerrainAt({required int col, required int row}) {
    if (0 <= col && col <= cols && 0 <= row && row <= rows) {   // we have 1 more row/col of terrain points
      return _terrainPoints[col][row];
    }
    
    return '';
  }

  void setTerrainAt({required int col, required int row, required String terrain}) {
    if (0 <= col && col <= cols && 0 <= row && row <= rows) {   // we have 1 more row/col of terrain points
      _terrainPoints[col][row] = terrain;
    }
  }

  void addTerrainRectangle({required int col, required int row, required int width, required int height, required String terrain}) {
    for (var r = row; r < row + height; r ++) {
      for (var c = col; c < col + width; c ++) {
        setTerrainAt(col: c, row: r, terrain: terrain);
      }
    }
  }

  void addTerrainCircle({required int col, required int row, required int radius, required String terrain}) {
    for (var r = row - radius; r < row + radius; r ++) {
      for (var c = col - radius; c < col + radius; c ++) {
        if (sqrt(pow(col - c, 2) + pow(row - r, 2)) < radius) {
          setTerrainAt(col: c, row: r, terrain: terrain);
        }
      }
    }
  }

  void addTerrainLine({required int startCol, required int startRow, required int endCol, required int endRow, required String terrain}) {
    num dc = endCol - startCol, dr = endRow - startRow;
    final dist = sqrt(pow(dc, 2) + pow(dr, 2));
    dc /= dist;
    dr /= dist;

    num c = startCol, r = startRow, total = 0;

    while (total < dist) {

      addTerrainRectangle(col: c.floor(), row: r.floor(), width: 2, height: 2, terrain: terrain);

      c += dc;
      r += dr;
      total ++;
    } 

    
  }

  void _drawTileAt(CanvasRenderingContext2D ctx, int col, int row) {
    final nw = _terrainPoints[col    ][row    ];
    final ne = _terrainPoints[col + 1][row    ];
    final sw = _terrainPoints[col    ][row + 1];
    final se = _terrainPoints[col + 1][row + 1];

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