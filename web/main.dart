import 'dart:collection';
import 'dart:developer';
import 'dart:html';

import 'game.dart';

Map cavesJSON = {
  "src": "images/cave.png",
  "width": 32,
  "height": 32,
  "tiles" : {
    "ground1": {"col": 0, "row": 9},
    "ground2": {"col": 1, "row": 9},
    "ground3": {"col": 0, "row": 10},
    "ground4": {"col": 1, "row": 10}
  }
};

class Arpeagy extends Game {
  final tiles = new HashMap<String, CanvasElement>();

  Arpeagy() {
    final tileSrc = new ImageElement(src: cavesJSON['src']);
    tileSrc.onLoad.listen((event) {

      (cavesJSON['tiles'] as Map).forEach((key, value) {
        tiles[key] = extractTile(tileSrc, value['col'], value['row']);
      });

      animate();
    });
  }

  CanvasElement extractTile(ImageElement src, int col, int row, {int WIDTH = 32, int HEIGHT = 32}) {
    final image = new CanvasElement(width: WIDTH, height: HEIGHT);
    final ctx = image.context2D;
    ctx.drawImageScaledFromSource(src, col * WIDTH, row * HEIGHT, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT);
    return image;
  }

  @override
  void update(dt) {
  }

  @override
  void draw(ctx) {
    ctx.drawImage(tiles['ground1']!, 0, 0);
    ctx.drawImage(tiles['ground2']!, 0, 16);
  }
}

void main() {
  new Arpeagy();
}