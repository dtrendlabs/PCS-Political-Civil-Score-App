import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(const PCSApp());
}

class PCSApp extends StatelessWidget {
  const PCSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCS - Hello Guys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.kalamTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const HelloGuysScreen(),
    );
  }
}

class HelloGuysScreen extends StatefulWidget {
  const HelloGuysScreen({super.key});

  @override
  State<HelloGuysScreen> createState() => _HelloGuysScreenState();
}

class _HelloGuysScreenState extends State<HelloGuysScreen>
    with TickerProviderStateMixin {
  bool _showGreeting = false;
  late AnimationController _pulseController;
  late AnimationController _greetingController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _greetingScaleAnimation;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOut),
    );

    _greetingSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.elasticOut),
    );

    _greetingScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.elasticOut),
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update(_particleController.value);
          }
        });
      });
  }

  void _onHelloGuysTapped() {
    setState(() {
      _showGreeting = !_showGreeting;
    });

    if (_showGreeting) {
      _greetingController.forward(from: 0);
      _spawnParticles();
      _particleController.forward(from: 0);
    } else {
      _greetingController.reverse();
      _particles.clear();
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        x: 0.5,
        y: 0.45,
        vx: (_random.nextDouble() - 0.5) * 0.8,
        vy: (_random.nextDouble() - 0.5) * 0.8,
        size: _random.nextDouble() * 8 + 3,
        color: [
          const Color(0xFF6C63FF),
          const Color(0xFFFF6584),
          const Color(0xFF43E97B),
          const Color(0xFFFA709A),
          const Color(0xFFFEE140),
        ][_random.nextInt(5)],
      ));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _greetingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
              ),
            ),
          ),

          // Animated Background Circles
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.fromRGBO(108, 99, 255, 0.15 * _pulseAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -size.width * 0.25,
            left: -size.width * 0.15,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.fromRGBO(255, 101, 132, 0.12 * _pulseAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Particles
          ...(_particles.map((p) => Positioned(
                left: p.x * size.width,
                top: p.y * size.height,
                child: Opacity(
                  opacity: (1 - _particleController.value).clamp(0.0, 1.0),
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.color,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(
                            p.color.r.toInt(),
                            p.color.g.toInt(),
                            p.color.b.toInt(),
                            0.6,
                          ),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ))),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Title
                    Text(
                      '🇮🇳',
                      style: TextStyle(fontSize: isSmallScreen ? 40 : 56),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'नमस्ते दोस्तों',
                      style: GoogleFonts.kalam(
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Color.fromRGBO(108, 99, 255, 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PCS - पॉलिटिकल सिविल स्कोर',
                      style: GoogleFonts.kalam(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white54,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // Hello Guys Button with Glassmorphism
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _onHelloGuysTapped,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(108, 99, 255, 0.4 * _pulseAnimation.value),
                                  blurRadius: 30 * _pulseAnimation.value,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(255, 101, 132, 0.2 * _pulseAnimation.value),
                                  blurRadius: 40 * _pulseAnimation.value,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 36 : 48,
                                    vertical: isSmallScreen ? 18 : 22,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromRGBO(255, 255, 255, 0.15),
                                        Color.fromRGBO(255, 255, 255, 0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _showGreeting
                                            ? Icons.waving_hand
                                            : Icons.touch_app_rounded,
                                        color: const Color(0xFFFEE140),
                                        size: isSmallScreen ? 26 : 30,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _showGreeting
                                            ? '👋 हैलो गाइज़!'
                                            : '🙏 यहाँ दबाएँ',
                                        style: GoogleFonts.kalam(
                                          fontSize: isSmallScreen ? 20 : 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.05),

                    // Greeting Message
                    AnimatedBuilder(
                      animation: _greetingController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _greetingFadeAnimation,
                          child: SlideTransition(
                            position: _greetingSlideAnimation,
                            child: ScaleTransition(
                              scale: _greetingScaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(108, 99, 255, 0.2),
                                  Color.fromRGBO(255, 101, 132, 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: const Color.fromRGBO(108, 99, 255, 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🎉',
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 44 : 56),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'हैलो गाइज़!',
                                  style: GoogleFonts.kalam(
                                    fontSize: isSmallScreen ? 28 : 34,
                                    fontWeight: FontWeight.w700,
                                    foreground: Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          Color(0xFF43E97B),
                                          Color(0xFF38F9D7),
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 250, 50),
                                      ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'आपका स्वागत है PCS ऐप में!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.kalam(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'राजनीतिक नागरिक स्कोर',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.kalam(
                                    fontSize: isSmallScreen ? 13 : 15,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom tagline
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Text(
              'भारत के लिए बनाया गया 🇮🇳',
              textAlign: TextAlign.center,
              style: GoogleFonts.kalam(
                fontSize: 13,
                color: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });

  void update(double t) {
    x += vx * 0.02;
    y += vy * 0.02;
    vy += 0.005;
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
