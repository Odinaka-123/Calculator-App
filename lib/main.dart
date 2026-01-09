import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (_, ThemeMode mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calculator',
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.deepPurple,
            useMaterial3: true,
          ),
          home: const CalculatorScreen(),
        );
      },
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String output = "0";
  String _input = "";
  double memory = 0.0;
  final List<String> history = [];

  /* ================= LOGIC ================= */

  void _press(String text) {
    HapticFeedback.lightImpact();

    setState(() {
      switch (text) {
        case "C":
          _input = "";
          output = "0";
          break;

        case "⌫":
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
            output = _input.isEmpty ? "0" : _input;
          }
          break;

        case "=":
          final result = _calculate(_input);
          if (result != "Error") history.add("$_input = $result");
          output = result;
          _input = result == "Error" ? "" : result;
          break;

        case "MC":
          memory = 0;
          break;

        case "MR":
          _input += memory.toString();
          output = _input;
          break;

        case "M+":
          memory += double.tryParse(output) ?? 0;
          break;

        default:
          // UI symbol → math operator
          final value = text == "×" ? "*" : text;
          _input += value;
          output = _input;
      }
    });
  }

  String _calculate(String input) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(
        input.replaceAll("√", "sqrt").replaceAll("π", "3.1415926535"),
      );
      double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      return eval == eval.toInt() ? eval.toInt().toString() : eval.toString();
    } catch (_) {
      return "Error";
    }
  }

  /* ================= UI HELPERS ================= */

  Widget calcButton(String text, {Color? color, double fontSize = 18}) {
    final cs = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? cs.surfaceContainerHighest,
        foregroundColor: cs.onSurface,
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => _press(text),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  /// 🔥 Adaptive display (infinite digits, auto-shrinks, no overflow)
  Widget adaptiveDisplay(double maxFontSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.bottomRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              output,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: maxFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  /* ================= PORTRAIT ================= */

  Widget portraitLayout() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: adaptiveDisplay(42),
          ),
        ),
        Expanded(
          flex: 2,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: const EdgeInsets.all(8),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              calcButton("MC", color: cs.tertiaryContainer),
              calcButton("MR", color: cs.tertiaryContainer),
              calcButton("M+", color: cs.tertiaryContainer),
              calcButton("⌫", color: cs.errorContainer),

              calcButton("7"),
              calcButton("8"),
              calcButton("9"),
              calcButton("/", color: cs.primaryContainer),

              calcButton("4"),
              calcButton("5"),
              calcButton("6"),
              calcButton("×", color: cs.primaryContainer),

              calcButton("1"),
              calcButton("2"),
              calcButton("3"),
              calcButton("-", color: cs.primaryContainer),

              calcButton("0"),
              calcButton("C", color: cs.errorContainer),
              calcButton("=", color: Colors.green),
              calcButton("+", color: cs.primaryContainer),
            ],
          ),
        ),
      ],
    );
  }

  /* ================= LANDSCAPE ================= */

  Widget landscapeLayout() {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final bool showScientific = size.width >= 760;

    final double buttonFont = size.height < 360
        ? 12
        : size.height < 420
        ? 13
        : 14;
    final double displayFont = size.height < 360
        ? 22
        : size.height < 420
        ? 24
        : 26;

    return Row(
      children: [
        Expanded(
          flex: showScientific ? 4 : 5,
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.22,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: adaptiveDisplay(displayFont),
                ),
              ),

              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(2),
                  crossAxisCount: 4,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.6,
                  children:
                      [
                        "7",
                        "8",
                        "9",
                        "/",
                        "4",
                        "5",
                        "6",
                        "×",
                        "1",
                        "2",
                        "3",
                        "-",
                        "0",
                        "C",
                        "=",
                        "+",
                      ].map((e) {
                        return calcButton(
                          e,
                          fontSize: buttonFont,
                          color: "+-×/".contains(e)
                              ? cs.primaryContainer
                              : e == "C"
                              ? cs.errorContainer
                              : e == "="
                              ? Colors.green
                              : null,
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),

        if (showScientific)
          Expanded(
            flex: 2,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(2),
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.7,
              children: ["(", ")", "π", "√", "^", "%", "MC", "MR", "M+", "⌫"]
                  .map((e) {
                    return calcButton(
                      e,
                      fontSize: buttonFont - 1,
                      color: cs.secondaryContainer,
                    );
                  })
                  .toList(),
            ),
          ),
      ],
    );
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Theme"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ThemeMode.values.map((m) {
                    return RadioListTile(
                      title: Text(m.name),
                      value: m,
                      groupValue: themeMode.value,
                      onChanged: (v) {
                        themeMode.value = v!;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => ListView(
                padding: const EdgeInsets.all(16),
                children: history.reversed
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(e, style: const TextStyle(fontSize: 18)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (_, orientation) {
          return orientation == Orientation.portrait
              ? portraitLayout()
              : landscapeLayout();
        },
      ),
    );
  }
}
