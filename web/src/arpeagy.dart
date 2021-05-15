import 'dart:html';

import 'actor.dart';
import 'game.dart';
import 'sprite.dart';
import 'terrain.dart';
import 'tiles.dart';

class Arpeagy extends Game {
  late final Actor human, spider;
  late final TileMap tileMap;
  late final CanvasElement levelImage;

  Arpeagy() : super(querySelector('#canvas') as CanvasElement) {
    final humanSprites = ActorSprites('json/human.json');
    final spiderSprites = ActorSprites('json/spider.json');
    final terrain = TerrainInfo('json/lpcTerrain.json');

    Future.wait([humanSprites.ready, spiderSprites.ready, terrain.ready]).then((_) {
      human = new Actor(speed: 0.1, spriteSet: humanSprites);
      human.layers.addAll(['hair', 'feet', 'legs', 'chest']);
      human.spawn(100, 100);

      spider = new Actor(speed: 0.08, spriteSet: spiderSprites);
      spider.spawn(200, 200);

      tileMap = new TileMap(terrainInfo: terrain, cols: 25, rows: 25);
      tileMap.addTerrainRectangle(0, 0, 26, 26, terrain.terrainTypes['grass']!);
      tileMap.addTerrainCircle(10, 10, 5, terrain.terrainTypes['water']!);
      tileMap.addTerrainLine(20, 0, 18, 10, terrain.terrainTypes['path']!);
      tileMap.addTerrainLine(18, 10, 17, 20, terrain.terrainTypes['path']!);

      levelImage = tileMap.generateImage();

      animate();
    });
  }

  void update(num dt) {
    if (mouse.isPressed(Mouse.LEFT_BUTTON)) {
      human.setGoal(mouse.x, mouse.y);
    }

    spider.setGoal(human.x + 64, human.y);

    human.update(dt);
    spider.update(dt);
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.drawImage(levelImage, 0, 0);
    human.draw(ctx);
    spider.draw(ctx);
  }
}

void main() {
  new Arpeagy();
}