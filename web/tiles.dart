import 'dart:html';
import 'dart:math';

class TileInfo {
  static const DOODAD_CHANCE = 0.1;

  final String? northWest, north, northEast, west, east, southWest, south, southEast;
  final List<CanvasElement> base = [], doodads = [];
  final List<TileInfo> edges = [];

  TileInfo(Map json, ImageElement src, int width, int height)
    : northWest = json['northWest'],
      north     = json['north'],
      northEast = json['northEast'],
      west      = json['west'],
      east      = json['east'],
      southWest = json['southWest'],
      south     = json['south'],
      southEast = json['southEast']
  {
    if (json.containsKey('base')) {
      (json['base'] as List).forEach((baseJson) {
        base.add(_extractTile(baseJson, src, width, height));
      });
    }
    else {
      throw new FormatException();
    }

    if (json.containsKey('doodads')) {
      (json['doodads'] as List).forEach((doodadJson) {
        doodads.add(_extractTile(doodadJson, src, width, height));
      });
    }

    if (json.containsKey('edges')) {
      (json['edges'] as List).forEach((edgeJson) {
        edges.add(new TileInfo(edgeJson, src, width, height));
      });
    }
  }

  CanvasElement get image {
    if (doodads.length > 0 && Random().nextDouble() < DOODAD_CHANCE) {
      return doodads[Random().nextInt(doodads.length)];
    }

    return base[Random().nextInt(base.length)];
  }

  CanvasElement _extractTile(Map json, ImageElement src, int width, int height) {
    final int col = json['col'], row = json['row'];
    final w = width, h = height;
    final image = new CanvasElement(width: w, height: h);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * w, row * h, w, h, 0, 0, w, h);
    return image;
  }
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

  String? getTypeAt(int col, int row) {
    if (col < 0 || col >= typeMap.length || row < 0 || row >= typeMap[0].length) {
      return null;
    }

    return typeMap[col][row];
  }

  String? _getEdgeAt(int col, int row, String? center) {
    final type = getTypeAt(col, row);
    return type == center ? null : type;
  }

  CanvasElement getTileAt(int col, int row) {
    final center = getTypeAt(col, row);
    final northWest = _getEdgeAt(col - 1, row - 1, center);
    final north     = _getEdgeAt(col    , row - 1, center);
    final northEast = _getEdgeAt(col + 1, row - 1, center);
    final west      = _getEdgeAt(col - 1, row    , center);
    final east      = _getEdgeAt(col + 1, row    , center);
    final southWest = _getEdgeAt(col - 1, row + 1, center);
    final south     = _getEdgeAt(col    , row + 1, center);
    final southEast = _getEdgeAt(col + 1, row + 1, center);

    if (!tileSet.tiles.containsKey(center)) {
      throw FormatException();
    }

    final centerTile = tileSet.tiles[center]!;

    final edges = centerTile.edges.where((edge) =>
      north == edge.north &&
      west == edge.west &&
      east == edge.east &&
      south == edge.south && 
      (northWest == edge.northWest || northWest == edge.north || northWest == edge.west) &&
      (northEast == edge.northEast || northEast == edge.north || northEast == edge.east) &&
      (southWest == edge.southWest || southWest == edge.south || southWest == edge.west) &&
      (southEast == edge.southEast || southEast == edge.south || southEast == edge.east)
    );

    if (edges.length == 1) {
      return edges.first.image;
    }
    
    return centerTile.image;
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