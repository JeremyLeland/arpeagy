import 'dart:html';
import 'dart:math';

import 'sprite.dart';


class Actor {
  num x = 0, y = 0;
  num angle = 0;

  String _action = 'walk';

  final SpriteSet spriteSet;
  
  int frame = 0;
  static const num timeBetweenFrames = 100;
  num timeUntilNextFrame = timeBetweenFrames;

  Actor(this.spriteSet);

  void spawn(num x, num y) {
    this.x = x;
    this.y = y;
    frame = 0;
  }

  void aimToward(num x, num y) {
    angle = atan2(y - this.y, x - this.x);
    //print('Angle = ${angle}');
  }

  String get direction {
    if (angle < (-3/4) * pi)  return 'west';
    if (angle < (-1/4) * pi)  return 'north';
    if (angle < ( 1/4) * pi)  return 'east';
    if (angle < ( 3/4) * pi)  return 'south';

    return 'west';
  }

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
    ctx.drawImage(sprite.frames[frame], x - spriteSet.centerX, y - spriteSet.centerY);
  }
}