import 'dart:html';

import 'dart:math';

class EdgeInfo {
  CanvasElement? northWest, north, northEast, west, east, southWest, south, southEast;
  CanvasElement? northAndWest, northAndEast, southAndWest, southAndEast;

  EdgeInfo(ImageElement src, Map json, int width, int height) {
    northWest = _extractTile(src, json['NW'], width, height);
    north     = _extractTile(src, json['N'],  width, height);
    northEast = _extractTile(src, json['NE'], width, height);
    west      = _extractTile(src, json['W'],  width, height);
    east      = _extractTile(src, json['E'],  width, height);
    southWest = _extractTile(src, json['SW'], width, height);
    south     = _extractTile(src, json['S'],  width, height);
    southEast = _extractTile(src, json['SE'], width, height);

    northAndWest = _extractTile(src, json['N+W'], width, height);
    northAndEast = _extractTile(src, json['N+E'], width, height);
    southAndWest = _extractTile(src, json['S+W'], width, height);
    southAndEast = _extractTile(src, json['S+E'], width, height);
  }
}

class TileInfo {
  late CanvasElement image;
  final List<CanvasElement> variations = [], doodads = [];
  final edges = new Map<String, EdgeInfo>();

  TileInfo(Map json, ImageElement src, int width, int height) {
    image = _extractTile(src, json, width, height);

    if (json.containsKey('variations')) {
      (json['variations'] as List).forEach((varJson) {
        variations.add(_extractTile(src, varJson, width, height));
      });
    }

    if (json.containsKey('doodads')) {
      (json['doodads'] as List).forEach((varJson) {
        doodads.add(_extractTile(src, varJson, width, height));
      });
    }

    if (json.containsKey('edges')) {
      (json['edges'] as Map).forEach((key, value) {
        edges[key] = new EdgeInfo(src, value, width, height);
      });
    }
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

class TileSet {
  final tiles = new Map<String, TileInfo>();
  late final width, height;
  late Future ready;

  TileSet(Map json) {
    width = json['width'];
    height = json['height'];

    final tileSrc = new ImageElement(src: json['src']);
    ready = tileSrc.onLoad.first.then((_) {
      (json['tiles'] as Map).forEach((key, value) {
        tiles[key] = new TileInfo(value, tileSrc, width, height);
      });
    });
  }
}

class TileMap {
  TileSet tileSet;
  late List<List<String>> typeMap;

  TileMap(this.tileSet, int rows, int cols) {
    typeMap = new List.generate(rows, (_) => List.filled(cols, 'empty', growable: false), growable: false);
  }

  int get cols => typeMap.length;
  int get rows => typeMap[0].length;

  CanvasElement getTileAt(int col, int row) {
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

    final self = tileSet.tiles[x]!;
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

    if (self.doodads.length > 0) {
      const DOODAD_CHANCE = 0.1;
      if (Random().nextDouble() < DOODAD_CHANCE) {
        var index = Random().nextInt(self.doodads.length);
        return self.doodads[index];
      }
    }

    if (self.variations.length > 0) {
      var index = Random().nextInt(self.variations.length);
      return self.variations[index];
    }
    
    return self.image;
  }

  void draw(CanvasRenderingContext2D ctx) {
    for (var row = 0; row < rows; row ++) {
      for (var col = 0; col < cols; col ++) {
        final tile = getTileAt(col, row);
        ctx.drawImage(tile, col * tileSet.width, row * tileSet.width);
      }
    }
  }
}