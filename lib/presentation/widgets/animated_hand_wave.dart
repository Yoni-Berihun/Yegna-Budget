import 'package:flutter/material.dart';

class AnimatedHandWave extends StatefulWidget {
  final double size;
  const AnimatedHandWave({super.key, this.size = 24});

  @override
  State<AnimatedHandWave> createState() => _AnimatedHandWaveState();
}

class _AnimatedHandWaveState extends State<AnimatedHandWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.15,
      end: 0.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Text('👋', style: TextStyle(fontSize: widget.size)),
          ),
        );
      },
    );
  }
}
