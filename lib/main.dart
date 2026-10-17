
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() => runApp(const QiblaApp());

class QiblaApp extends StatelessWidget {
  const QiblaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CompassPage(),
    );
  }
}

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  Position? position;
  String message = 'اضغط لتحديد موقعك';
  double? bearing;
  double? distance;

  static const double shrineLat = 32.6160;
  static const double shrineLon = 44.0320;

  Future<void> findDirection() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => message = 'فعّل خدمة الموقع GPS');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => message = 'اسمح للتطبيق باستخدام الموقع');
        return;
      }

      final p = await Geolocator.getCurrentPosition();

      final b = Geolocator.bearingBetween(
        p.latitude, p.longitude, shrineLat, shrineLon,
      );

      final d = Geolocator.distanceBetween(
        p.latitude, p.longitude, shrineLat, shrineLon,
      ) / 1000;

      setState(() {
        position = p;
        bearing = (b + 360) % 360;
        distance = d;
        message = 'تم تحديد موقعك';
      });
    } catch (e) {
      setState(() => message = 'تعذر تحديد الموقع');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('قبلة مرقد الإمام الحسين'),
        centerTitle: true,
        backgroundColor: const Color(0xFF17171D),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque,
                  size: 55, color: Color(0xFFFFD36A)),
              const SizedBox(height: 12),
              const Text('يا حسين',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFFFFD36A),
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 28),
              StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  final heading = snapshot.data?.heading;
                  final angle = bearing;

                  if (heading == null || angle == null) {
                    return const Icon(Icons.explore,
                        size: 180, color: Color(0xFFFFD36A));
                  }

                  final rotation = (angle - heading) * math.pi / 180;
                  return Transform.rotate(
                    angle: rotation,
                    child: const Icon(Icons.navigation,
                        size: 180, color: Color(0xFFFFD36A)),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(message, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              if (bearing != null)
                Text('الاتجاه: ${bearing!.toStringAsFixed(1)}°'),
              if (distance != null)
                Text('المسافة: ${distance!.toStringAsFixed(1)} كم'),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: findDirection,
                icon: const Icon(Icons.my_location),
                label: const Text('تحديد الاتجاه'),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'وجّه الهاتف بعيداً عن المعادن لمعايرة البوصلة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}