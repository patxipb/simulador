#!/usr/bin/env bash
set -e

PROJECT_NAME="simulador"
ORG="com.patxipb"

# Comprueba Flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter no está instalado o no está en PATH."
  exit 1
fi

# Habilitar desktop windows (global)
flutter config --enable-windows-desktop || true

# Crear proyecto Flutter (si ya existe la carpeta, aborta)
if [ -d "$PROJECT_NAME" ]; then
  echo "La carpeta $PROJECT_NAME ya existe. Elimina o renombra antes de ejecutar."
  exit 1
fi

flutter create --org "$ORG" "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Sobrescribir archivos con el contenido proporcionado
# .gitignore
cat > .gitignore <<'EOF'
# Flutter/Dart/Pub related
.dart_tool/
.packages
.pub-cache/
.pub/
build/
.flutter-plugins
.flutter-plugins-dependencies
.flutter-versions

# IntelliJ / Android Studio
*.iml
.idea/
*.ipr
*.iws

# VS Code
.vscode/

# macOS
.DS_Store

# Windows
Thumbs.db

# Others
**/generated_plugin_registrant.dart
EOF

# pubspec.yaml (sobrescribe)
cat > pubspec.yaml <<'EOF'
name: simulador
description: Simulador (migración de figuras) - POC Flutter
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/audio/
EOF

# Crear estructura de directorios
mkdir -p lib/screens lib/widgets lib/services assets/images assets/audio .github/workflows

# lib/main.dart
cat > lib/main.dart <<'EOF'
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ejercicio1_screen.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.instance.init();
  runApp(const SimuladorApp());
}

class SimuladorApp extends StatelessWidget {
  const SimuladorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/ejercicio1': (context) => const Ejercicio1Screen(),
      },
    );
  }
}
EOF

# lib/screens/home_screen.dart
cat > lib/screens/home_screen.dart <<'EOF'
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador - Home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Ejercicios de valoración',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/ejercicio1'),
              child: const Text('Ejercicio 1 (POC)'),
            ),
            const SizedBox(height: 8),
            const Text('(Resto de ejercicios se implementarán igual en pantallas separadas.)'),
          ],
        ),
      ),
    );
  }
}
EOF

# lib/screens/ejercicio1_screen.dart
cat > lib/screens/ejercicio1_screen.dart <<'EOF'
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/figura_widget.dart';
import '../services/utils.dart';

class Ejercicio1Screen extends StatefulWidget {
  const Ejercicio1Screen({super.key});

  @override
  State<Ejercicio1Screen> createState() => _Ejercicio1ScreenState();
}

class _Ejercicio1ScreenState extends State<Ejercicio1Screen> {
  final _formKey = GlobalKey<FormState>();

  int exposiciones = 10;
  int tiempoEspera = 2000;
  int tiempoExposicion = 2000;

  bool running = false;
  bool showFigura = false;
  Color figuraColor = Colors.red;

  int contadorRojos = 0;

  @override
  void dispose() {
    running = false;
    super.dispose();
  }

  Future<void> startEjercicio() async {
    setState(() {
      running = true;
      contadorRojos = 0;
    });

    while (running && contadorRojos < exposiciones) {
      await generarPausa(tiempoEspera);

      try {
        await AudioService.instance.play();
      } catch (_) {}

      final color = calculaColor();
      if (color == Colors.red) contadorRojos++;

      setState(() {
        figuraColor = color;
        showFigura = true;
      });

      await generarPausa(tiempoExposicion);

      try {
        await AudioService.instance.stop();
      } catch (_) {}

      setState(() {
        showFigura = false;
      });
    }

    await generarPausa(5000);
    if (mounted) {
      try { await AudioService.instance.stop(); } catch (_) {}
      setState(() {
        running = false;
        showFigura = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Fin del ejercicio'),
            content: const Text('El ejercicio ha finalizado.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejercicio 1')),
      body: Stack(
        children: [
          Container(color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: running ? const SizedBox.shrink() : buildForm(),
          ),
          if (showFigura)
            Center(
              child: FiguraWidget(
                color: figuraColor,
                size: calculaTamanio().toDouble(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: exposiciones.toString(),
            decoration: const InputDecoration(labelText: 'Exposiciones (número de círculos rojos)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => exposiciones = int.tryParse(v ?? '') ?? 10,
          ),
          TextFormField(
            initialValue: tiempoEspera.toString(),
            decoration: const InputDecoration(labelText: 'Tiempo de espera (ms)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => tiempoEspera = int.tryParse(v ?? '') ?? 2000,
          ),
          TextFormField(
            initialValue: tiempoExposicion.toString(),
            decoration: const InputDecoration(labelText: 'Tiempo de exposición (ms)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => tiempoExposicion = int.tryParse(v ?? '') ?? 2000,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _formKey.currentState?.save();
              startEjercicio();
            },
            child: const Text('Iniciar'),
          )
        ],
      ),
    );
  }
}
EOF

# lib/widgets/figura_widget.dart
cat > lib/widgets/figura_widget.dart <<'EOF'
import 'package:flutter/material.dart';

class FiguraWidget extends StatelessWidget {
  final Color color;
  final double size;

  const FiguraWidget({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
EOF

# lib/services/audio_service.dart
cat > lib/services/audio_service.dart <<'EOF'
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioPlayer? _player;
  static final AudioService instance = AudioService._internal();

  AudioService._internal();

  Future<void> init() async {
    _player ??= AudioPlayer();
    await _player?.setVolume(0.5);
  }

  Future<void> play() async {
    try {
      if (_player == null) await init();
      await _player!.stop();
      // Intenta reproducir audio desde assets/audio/disparo.mp3
      await _player!.play(AssetSource('audio/disparo.mp3'));
    } catch (e) {
      // Si hay error (asset no presente), lo ignoramos para evitar crash en POC
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> setVolume(double v) async {
    await _player?.setVolume(v);
  }
}
EOF

# lib/services/utils.dart
cat > lib/services/utils.dart <<'EOF'
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

final _random = Random();

Future<void> generarPausa(int tiempoMs) async {
  if (tiempoMs <= 4950) {
    await Future.delayed(Duration(milliseconds: tiempoMs));
    return;
  }

  const ciclo = 4950;
  int restante = tiempoMs;
  while (restante > ciclo) {
    await Future.delayed(const Duration(milliseconds: ciclo));
    restante -= ciclo;
  }
  if (restante > 0) {
    await Future.delayed(Duration(milliseconds: restante));
  }
}

Color calculaColor() {
  return _random.nextBool() ? Colors.red : Colors.green;
}

// devuelve tamaño en px para la figura
int calculaTamanio() {
  final opciones = [60, 80, 100];
  return opciones[_random.nextInt(opciones.length)];
}
EOF

# .github workflow
cat > .github/workflows/flutter-ci.yml <<'EOF'
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Flutter analyze
        run: flutter analyze

  build-android:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Build APK
        run: flutter build apk --release
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-windows:
    runs-on: windows-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Build windows
        run: flutter build windows --release
      - name: Upload windows artifacts
        uses: actions/upload-artifact@v4
        with:
          name: windows-exe
          path: build/windows/runner/Release/
EOF

# README.md
cat > README.md <<'EOF'
# Simulador (POC Flutter)

POC que migra la app de patxipb/figuras a Flutter. Incluye pantalla Home y Ejercicio 1 funcional.

Cómo usar:
1. Instala Flutter y configura Android + Windows (si quieres desktop).
2. Ejecuta:
   flutter pub get

3. Ejecuta en Android:
   flutter run -d <device-id>  (o flutter run -d android)

4. Ejecuta en Windows:
   flutter run -d windows

5. Build release:
   flutter build apk
   flutter build windows

Copia assets desde el repo original patxipb/figuras:
- assets/images/ ← imagenes
- assets/audio/ ← sonido (opcional, ejemplo: disparo.mp3)

Notas:
- El servicio de audio usa audioplayers; si no pones el archivo de audio, la reproducción se ignorará sin colapsar el POC.
- Para Windows Desktop necesitas Visual Studio con "Desktop development with C++".
EOF

# Instalar paquetes y crear zip
flutter pub get

cd ..
zip -r "${PROJECT_NAME}.zip" "${PROJECT_NAME}"

echo "Hecho: ${PROJECT_NAME}.zip creado en $(pwd)"
