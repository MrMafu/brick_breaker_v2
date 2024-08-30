import 'dart:async';

import 'package:flame/collisions.dart'; // Add this import
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

//Class PlayArea
class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  //Struktur
  PlayArea()
      : super(
          paint: Paint()..color = const Color(0xfff2e8cf),
          children: [RectangleHitbox()], // Add this parameter
        );

  //Method yang dipanggil ketika PlayArea ditambahkan ke game
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
