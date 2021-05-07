import 'dart:convert';
import 'dart:html';

import 'actor.dart';
import 'game.dart';
import 'sprite.dart';

class ActorTest extends Game {
  late final Actor actor;

  ActorTest() : super(querySelector('#canvas') as CanvasElement) {
    HttpRequest.getString('json/human.json').then((jsonString) {
      Map json = jsonDecode(jsonString);

      final spriteSet = SpriteSet.fromCharacterJson(json);
      spriteSet.ready.then((_) {
        actor = new Actor(spriteSet);
        actor.spawn(100, 100);

        addUIButtonsForActor(actor);

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

  void update(num dt) {
    actor.aimToward(mouse.x, mouse.y);

    actor.update(dt);
  }

  void draw(CanvasRenderingContext2D ctx) {

    ctx..beginPath()
       ..moveTo( 90, 90)..lineTo(110, 110)
       ..moveTo(110, 90)..lineTo( 90, 110)
       ..strokeStyle = 'red'..stroke();

    actor.draw(ctx);
  }
}