import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:brick_breaker/audio/audio_controller.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

//Class Ball
class Ball extends CircleComponent 
with CollisionCallbacks, HasGameReference<BrickBreaker> {
  final AudioController audioController;

  //Struktur Ball
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
    required this.audioController
  }) : super(
            radius: radius,
            anchor: Anchor.center,
            paint: Paint()
              ..color = const Color(0xff1e6091)
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final Vector2 velocity;
  final double difficultyModifier;

  //Memanggil setiap frame untuk update lokasi ball
  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  //Memulai handle logika untuk collision (ketika menabrak komponen lain)
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    //Collision playarea(dinding game)
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
            delay: 0.35,
            onComplete: () {
              game.playState = PlayState.gameOver;
              audioController.playSound('assets/sounds/gameover.mp3');
            }));
      }
    //Collision Bat
    } else if (other is Bat) {
      audioController.playSound('assets/sounds/bat.mp3');
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
      //Collision Brick
    } else if (other is Brick) {
      audioController.playSound('assets/sounds/brick.mp3');
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
