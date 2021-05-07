import 'dart:html';

import 'sprite.dart';


class Actor {
  String direction = 'west';
  String _action = 'walk';

  final SpriteSet spriteSet;
  
  int frame = 0;
  static const num timeBetweenFrames = 100;
  num timeUntilNextFrame = timeBetweenFrames;

  Actor(this.spriteSet);

  String get action => _action;
  void set action(String action) {
    _action = action;
    frame = 0;
  }  

  void update(num dt) {
    timeUntilNextFrame -= dt;
    if (timeUntilNextFrame < 0) {
      timeUntilNextFrame += timeBetweenFrames;

      if (++frame >= spriteSet.getSprite(action: action, direction: direction).frames.length) {
        frame = 0;
      }
    }
  }

  void draw(CanvasRenderingContext2D ctx) {
    final sprite = spriteSet.getSprite(action: action, direction: direction);
    ctx.drawImage(sprite.frames[frame], 100, 100);
  }
}