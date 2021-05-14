import 'dart:html';

import 'actor.dart';
import 'game.dart';
import 'sprite.dart';
import 'tiles.dart';

class Arpeagy extends Game {
  late final Actor actor;
  late final TileMap tileMap;
  late final CanvasElement levelImage;

  Arpeagy() : super(querySelector('#canvas') as CanvasElement) {

    final humanSprites = ActorSprites('json/human.json');
    final terrain = TerrainTileset('json/lpcTerrain.json');

    Future.wait([humanSprites.ready, terrain.ready]).then((_) {
      actor = new Actor(humanSprites);
      actor.spawn(100, 100);

      tileMap = new TileMap(tileSet: terrain, cols: 25, rows: 25);
      tileMap.addTerrainRectangle(0, 0, 26, 26, 'grass');
      tileMap.addTerrainCircle(10, 10, 5, 'water');
      tileMap.addTerrainLine(20, 0, 18, 10, 'path');
      tileMap.addTerrainLine(18, 10, 17, 20, 'path');

      levelImage = tileMap.generateImage();

      animate();
    });
  }

  void update(num dt) {
    if (mouse.isPressed(Mouse.LEFT_BUTTON)) {
      actor.setGoal(mouse.x, mouse.y);
    }
    actor.update(dt);
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.drawImage(levelImage, 0, 0);
    actor.draw(ctx);
  }
}

void main() {
  new Arpeagy();
}