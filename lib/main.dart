import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SnakeGameApp());

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  // Constants
  static const int rowCount = 20;
  static const int colCount = 20;
  static const Duration tickDuration = Duration(milliseconds: 300);

  // Snake and food
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Point<int> direction = const Point(0, -1); // Start moving up

  Timer? _timer;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    _timer?.cancel();
    snake = [const Point(10, 10)];
    food = generateFood();
    direction = const Point(0, -1);
    gameOver = false;
    _timer = Timer.periodic(tickDuration, (_) => updateGame());
  }

  Point<int> generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(random.nextInt(colCount), random.nextInt(rowCount));
    } while (snake.contains(newFood));
    return newFood;
  }

  void updateGame() {
    setState(() {
      final newHead = snake.first + direction;

      // Check collision
      if (newHead.x < 0 ||
          newHead.y < 0 ||
          newHead.x >= colCount ||
          newHead.y >= rowCount ||
          snake.contains(newHead)) {
        gameOver = true;
        _timer?.cancel();
        return;
      }

      snake.insert(0, newHead);

      // Check if food is eaten
      if (newHead == food) {
        food = generateFood();
      } else {
        snake.removeLast(); // Move without growing
      }
    });
  }

  void changeDirection(Point<int> newDir) {
    if ((newDir + direction) != const Point(0, 0)) {
      direction = newDir;
    }
  }

  Widget buildGridCell(int x, int y) {
    final point = Point(x, y);
    Color color;
    if (snake.first == point) {
      color = Colors.green.shade700;
    } else if (snake.contains(point)) {
      color = Colors.green;
    } else if (food == point) {
      color = Colors.red;
    } else {
      color = Colors.grey.shade300;
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("🐍 Snake Game (Flutter)"),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: AspectRatio(
              aspectRatio: colCount / rowCount,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rowCount * colCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                ),
                itemBuilder: (context, index) {
                  final x = index % colCount;
                  final y = index ~/ colCount;
                  return buildGridCell(x, y);
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: gameOver ? buildGameOverScreen() : buildControls(),
          ),
        ],
      ),
    );
  }

  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Up
          IconButton(
            icon: const Icon(Icons.arrow_drop_up, size: 40),
            onPressed: () => changeDirection(const Point(0, -1)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left
              IconButton(
                icon: const Icon(Icons.arrow_left, size: 40),
                onPressed: () => changeDirection(const Point(-1, 0)),
              ),
              const SizedBox(width: 50),
              // Right
              IconButton(
                icon: const Icon(Icons.arrow_right, size: 40),
                onPressed: () => changeDirection(const Point(1, 0)),
              ),
            ],
          ),
          // Down
          IconButton(
            icon: const Icon(Icons.arrow_drop_down, size: 40),
            onPressed: () => changeDirection(const Point(0, 1)),
          ),
        ],
      ),
    );
  }

  Widget buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "💀 Game Over!",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: startGame, child: const Text("Restart")),
        ],
      ),
    );
  }
}
