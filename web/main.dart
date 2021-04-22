import 'game.dart';

class Arpeagy extends Game {
  Arpeagy() {
    animate();
  }

  @override
  void update(dt) {
  }

  @override
  void draw(ctx) {
    ctx.fillStyle = 'red';
    ctx.fillText('Arpeagy', 100, 100);
  }
}

void main() {
  new Arpeagy();
}