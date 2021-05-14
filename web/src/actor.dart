import 'dart:html';
import 'dart:math';

import 'sprite.dart';

enum Direction { north, east, south, west }
enum Action { cast, thrust, walk, slash, shoot, hurt }

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value);
}

class Actor {
  num x = 0, y = 0, angle = 0, speed = 0.1;
  num _goalX = 0, _goalY = 0;

  final layers = ['body', 'hair', 'feet', 'legs', 'chest'];
  Action _action = Action.walk;

  final ActorSprites spriteSet;
  
  int frame = 0;
  static const num timeBetweenFrames = 100;
  num timeUntilNextFrame = timeBetweenFrames;

  Actor(this.spriteSet);

  void spawn(num x, num y) {
    this.x = _goalX = x;
    this.y = _goalY = y;
    frame = 0;
  }

  void aimToward(num x, num y) => angle = atan2(y - this.y, x - this.x);
  num distanceFromPoint(num x, num y) => sqrt(pow(x - this.x, 2) + pow(y - this.y, 2));
  void setGoal(num x, num y) {
    _goalX = x;
    _goalY = y;
    aimToward(_goalX, _goalY);
  }

  Direction get direction {
    if (angle < (-3/4) * pi)  return Direction.west;
    if (angle < (-1/4) * pi)  return Direction.north;
    if (angle < ( 1/4) * pi)  return Direction.east;
    if (angle < ( 3/4) * pi)  return Direction.south;

    return Direction.west;
  }

  Action get action => _action;
  void set action(Action action) {
    _action = action;
    frame = 0;
  }

  void _updatePosition(num dt) {
    x += cos(angle) * speed * dt;
    y += sin(angle) * speed * dt;
  }

  void _updateFrame(num dt) {
    timeUntilNextFrame -= dt;
    if (timeUntilNextFrame < 0) {
      timeUntilNextFrame += timeBetweenFrames;

      if (++frame >= spriteSet.sprites['body']![action]![direction]!.length) {
        frame = 1;  // frame 0 is idle
      }
    }
  }

  void update(num dt) {
    final dist = speed * dt;
    if (distanceFromPoint(_goalX, _goalY) < dist) {
      x = _goalX;
      y = _goalY;
      frame = 0;
    }
    else {
      _updatePosition(dt);
      _updateFrame(dt);
    }
  }

  void draw(CanvasRenderingContext2D ctx) {
    layers.forEach((layer) {
      final sprite = spriteSet.sprites[layer]![action]![direction]![frame];
      ctx.drawImage(sprite, x - spriteSet.centerX, y - spriteSet.centerY);
    });
  }
}