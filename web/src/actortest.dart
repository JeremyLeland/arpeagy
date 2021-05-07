import 'dart:convert';
import 'dart:html';

import 'actor.dart';
import 'sprite.dart';

class ActorTest {
  final canvas = querySelector('#canvas') as CanvasElement;
  num _lastTime = 0;

  late final Actor actor;

  ActorTest() {
    HttpRequest.getString('json/human.json').then((jsonString) {
      Map json = jsonDecode(jsonString);

      final spriteSet = SpriteSet.fromCharacterJson(json);
      spriteSet.ready.then((_) {
        actor = new Actor(spriteSet);
        addUIButtonsForActor(actor);

        //draw(canvas.context2D);
        animate();
      });
    });
  }

  void addUIButtonsForActor(Actor actor) {
    final buttonDiv = querySelector('#buttons')!;

    actor.spriteSet.sprites.keys.forEach((actionName) {
      final button = new ButtonElement();
      button.text = actionName;
      button.onClick.listen((_) {
        actor.action = actionName;
        //draw(canvas.context2D);
      });
      buttonDiv.children.add(button);
    });
  }

  void animate() async {
    while (true) {
      final num now = await window.animationFrame;

      update(now - _lastTime);

      _lastTime = now;

      draw(canvas.context2D);
    }
  }

  void update(num dt) {
    actor.update(dt);
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, ctx.canvas.width!, ctx.canvas.height!);

    actor.draw(ctx);
  }
}