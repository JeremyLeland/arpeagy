import 'dart:html';

import 'game.dart';

class Arpeagy extends Game {

  final image = new ImageElement(src: 'images/cave.png');

  Arpeagy() {
    image.onLoad.listen((event) {
      animate();
    });
  }

  @override
  void update(dt) {
  }

  @override
  void draw(ctx) {
    ctx.drawImage(image, 0, 0);
  }
}

void main() {
  new Arpeagy();
}