import 'dart:collection';
import 'dart:html';

import 'game.dart';

class Arpeagy extends Game {
  final tiles = new HashMap<String, CanvasElement>();

  Arpeagy() {
    final tileSrc = new ImageElement(src: 'images/cave.png');
    tileSrc.onLoad.listen((event) {

      tiles['GROUND_1'] = extractTile(tileSrc, 0, 9);
      tiles['GROUND_2'] = extractTile(tileSrc, 1, 9);
      tiles['GROUND_3'] = extractTile(tileSrc, 0, 10);
      tiles['GROUND_4'] = extractTile(tileSrc, 1, 10);

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
    ctx.drawImage(tiles['GROUND_1']!, 0, 0);
    ctx.drawImage(tiles['GROUND_2']!, 0, 16);
  }
}

void main() {
  new Arpeagy();
}