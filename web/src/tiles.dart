import 'dart:html';
import 'dart:math';

import 'sprite.dart';

class TileMap {
  final int cols, rows;
  final TerrainTileset tileSet;
  late List<List<String>> _terrain;

  TileMap({required this.tileSet, required this.cols, required this.rows}) {
    // the control points to generate the terrain tiles (NW, NE, SW, SE corners of tile)
    // this will be 1 row and 1 col bigger than map, so that every tile has all 4 corners
    final defaultVal = tileSet.tiles.keys.first;
    _terrain = List.generate(cols + 1, (_) => List.filled(rows + 1, defaultVal));
  }

  String getTerrainAt(int col, int row) {
    //if (0 <= col && col <= cols && 0 <= row && row <= rows) {   // we have 1 more row/col of terrain points
      return _terrain[col][row];
    //}
    
    //return '';
  }

  void setTerrainAt(int col, int row, String terrain) {
    if (0 <= col && col <= cols && 0 <= row && row <= rows) {   // we have 1 more row/col of terrain points
      _terrain[col][row] = terrain;
    }
  }

  void addTerrainRectangle(int col, int row, int width, int height, String terrain) {
    for (var r = row; r < row + height; r ++) {
      for (var c = col; c < col + width; c ++) {
        setTerrainAt(c, r, terrain);
      }
    }
  }

  void addTerrainCircle(int col, int row, int radius, String terrain) {
    for (var r = row - radius; r < row + radius; r ++) {
      for (var c = col - radius; c < col + radius; c ++) {
        if (sqrt(pow(col - c, 2) + pow(row - r, 2)) < radius) {
          setTerrainAt(c, r, terrain);
        }
      }
    }
  }

  void addTerrainLine(int startCol, int startRow, int endCol, int endRow, String terrain) {
    num dc = endCol - startCol, dr = endRow - startRow;
    final dist = sqrt(pow(dc, 2) + pow(dr, 2));
    dc /= dist;
    dr /= dist;

    num c = startCol, r = startRow, total = 0;

    while (total < dist) {

      addTerrainRectangle(c.floor(), r.floor(), 2, 2, terrain);

      c += dc;
      r += dr;
      total ++;
    }
  }

  void _drawTileAt(CanvasRenderingContext2D ctx, int col, int row) {
    final nw = _terrain[col    ][row    ];
    final ne = _terrain[col + 1][row    ];
    final sw = _terrain[col    ][row + 1];
    final se = _terrain[col + 1][row + 1];

    final layers = Map<String, List<String>>();
    layers.putIfAbsent(nw, () => []).add('NW');
    layers.putIfAbsent(ne, () => []).add('NE');
    layers.putIfAbsent(sw, () => []).add('SW');
    layers.putIfAbsent(se, () => []).add('SE');

    tileSet.tiles.forEach((name, tile) {
      var pattern = layers[name]?.join('+');

      if (pattern == 'NW+NE+SW+SE') {
        final random = new Random();
        if (random.nextDouble() < 0.1) {
          pattern = 'variant${random.nextInt(3) + 1}';
        }
      }

      final image = tile[pattern];
      if (image != null) {
        ctx.drawImage(image, col * tileSet.width, row * tileSet.height);
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

  CanvasElement generateImage() {
    final image = new CanvasElement(width: cols * tileSet.width, height: rows * tileSet.height);
    draw(image.context2D);
    return image;
  }
}