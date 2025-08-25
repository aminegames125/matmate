import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'
//     show defaultTargetPlatform, TargetPlatform;
// import 'package:fluent_ui/fluent_ui.dart' as fluent; // Temporarily disabled for Android build
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_expressions/math_expressions.dart' as me;
// import 'package:equations/equations.dart' as eq; // Reserved for advanced solvers
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
// Removed localization imports - using Material only

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = ThemeData(brightness: Brightness.light).textTheme;
    return Consumer(
      builder: (context, ref, _) {
        final mode = ref.watch(themeModeProvider);
        return MaterialApp(
          title: 'MatMate',
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
            textTheme: GoogleFonts.interTextTheme(textTheme),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            chipTheme: const ChipThemeData(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(textTheme),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
            chipTheme: const ChipThemeData(),
          ),
          home: const MainShell(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const [HomeScreen(), HistoryScreen(), SettingsScreen()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            label: 'Solve',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_StepItem> _steps = const [];
  String? _resultLatex;
  String? _error;
  // Neural model temporarily disabled; using math engine only

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _solve() {
    setState(() {
      _error = null;
      _resultLatex = null;
      _steps = const [];
    });

    final input = _controller.text.trim();
    // Neural path disabled; proceed with deterministic engine

    if (input.isEmpty) return;

    try {
      // Matrices: det([1,2;3,4])
      if (input.startsWith('det(') && input.endsWith(')')) {
        final content = input.substring(4, input.length - 1);
        final m = _parseMatrix(content);
        final value = _determinant(m);
        setState(() {
          _resultLatex = _toLatexNumber(value);
          _steps = const [
            _StepItem(
              title: 'Matrix',
              description: 'Determinant via elimination',
            ),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
      // Matrices: inv([a,b;c,d])
      if (input.startsWith('inv(') && input.endsWith(')')) {
        final content = input.substring(4, input.length - 1);
        final m = _parseMatrix(content);
        final inv = _inverse(m);
        final asText = inv
            .map((r) => r.map((v) => _toLatexNumber(v)).join(','))
            .join(';');
        setState(() {
          _resultLatex = '[$asText]';
          _steps = const [
            _StepItem(title: 'Matrix', description: 'Inverse via Gauss-Jordan'),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
      // Stats: mean([1,2,3]) sum([...]) median([...])
      if (input.startsWith('mean(') && input.endsWith(')')) {
        final nums = _parseList(input.substring(5, input.length - 1));
        final value = nums.isEmpty
            ? 0
            : nums.reduce((a, b) => a + b) / nums.length;
        setState(() {
          _resultLatex = _toLatexNumber(value);
          _steps = const [
            _StepItem(title: 'Statistics', description: 'Mean of list'),
          ];
        });
        return;
      }
      if (input.startsWith('sum(') && input.endsWith(')')) {
        final nums = _parseList(input.substring(4, input.length - 1));
        final value = nums.fold(0.0, (a, b) => a + b);
        setState(() {
          _resultLatex = _toLatexNumber(value);
          _steps = const [
            _StepItem(title: 'Statistics', description: 'Sum of list'),
          ];
        });
        return;
      }
      if (input.startsWith('median(') && input.endsWith(')')) {
        final nums = _parseList(input.substring(7, input.length - 1))..sort();
        double value = 0;
        if (nums.isNotEmpty) {
          final mid = nums.length ~/ 2;
          value = nums.length % 2 == 1
              ? nums[mid]
              : (nums[mid - 1] + nums[mid]) / 2;
        }
        setState(() {
          _resultLatex = _toLatexNumber(value);
          _steps = const [
            _StepItem(title: 'Statistics', description: 'Median of list'),
          ];
        });
        return;
      }
      // Linear system 2x2: solve([[a,b],[c,d]],[e,f])
      if (input.startsWith('solve(') && input.endsWith(')')) {
        final inner = input.substring(6, input.length - 1);
        final parts = _splitTopLevel(inner);
        if (parts.length == 2) {
          final a = _parseMatrix(parts[0]);
          final b = _parseList(parts[1]);
          if (a.isNotEmpty && a.length == a[0].length && b.length == a.length) {
            final x = _solveLinear(a, b);
            setState(() {
              _resultLatex = '[${x.map(_toLatexNumber).join(',')}]';
              _steps = const [
                _StepItem(title: 'Linear system', description: 'Solve Ax=b'),
              ];
            });
            return;
          }
        }
      }
      // Try expression evaluation using math_expressions
      final parser = me.Parser();
      final exp = parser.parse(input);
      final context = me.ContextModel();
      final value = exp.evaluate(me.EvaluationType.REAL, context);
      final precision = ref.read(precisionProvider);
      final rounded = _roundNumeric(value, precision);
      setState(() {
        _resultLatex = _toLatexNumber(rounded);
        _steps = [
          _StepItem(title: 'Parse', description: input),
          _StepItem(title: 'Evaluate', description: 'Result = $rounded'),
        ];
      });
      ref
          .read(historyProvider.notifier)
          .add(
            _HistoryItem(
              expression: input,
              result: _resultLatex!,
              timestampMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      return;
    } catch (_) {
      // Not a plain evaluable expression; continue
    }

    // Derivative: derivative(f(x), x)
    try {
      final m = RegExp(
        r'^\s*derivative\((.*?),\s*([a-zA-Z])\s*\)\s*$',
        dotAll: true,
      ).firstMatch(input);
      if (m != null) {
        final f = m.group(1)!;
        final variable = m.group(2)!;
        final parser = me.Parser();
        final exp = parser.parse(f);
        final derived = exp.derive(variable).simplify();
        setState(() {
          _resultLatex = derived.toString();
          _steps = const [
            _StepItem(
              title: 'Differentiate',
              description: r"Apply symbolic differentiation",
            ),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
    } catch (_) {}

    // Definite integral: integrate(f(x), x, a, b)
    try {
      final m = RegExp(
        r'^\s*integrate\((.*?),\s*([a-zA-Z])\s*,\s*([+-]?[0-9]*\.?[0-9]+)\s*,\s*([+-]?[0-9]*\.?[0-9]+)\s*\)\s*$',
        dotAll: true,
      ).firstMatch(input);
      if (m != null) {
        final f = m.group(1)!;
        final variable = m.group(2)!;
        final a = double.parse(m.group(3)!);
        final b = double.parse(m.group(4)!);
        final parser = me.Parser();
        final exp = parser.parse(f);
        final ctx = me.ContextModel();
        final precision = ref.read(precisionProvider);
        final result = _integrateNumeric(exp, variable, a, b, ctx);
        final rounded = _roundNumeric(result, precision);
        setState(() {
          _resultLatex = rounded.toString();
          _steps = const [
            _StepItem(
              title: 'Integrate numerically',
              description: 'Composite Simpson rule',
            ),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
    } catch (_) {}

    // Limit: limit(f(x), x->a)
    try {
      final m = RegExp(
        r'^\s*limit\((.*?),\s*([a-zA-Z])\s*->\s*([+-]?[0-9]*\.?[0-9]+)\s*\)\s*$',
        dotAll: true,
      ).firstMatch(input);
      if (m != null) {
        final f = m.group(1)!;
        final variable = m.group(2)!;
        final a = double.parse(m.group(3)!);
        final parser = me.Parser();
        final exp = parser.parse(f);
        final ctx = me.ContextModel();
        final precision = ref.read(precisionProvider);
        final value = _limitNumeric(exp, variable, a, ctx);
        final rounded = _roundNumeric(value, precision);
        setState(() {
          _resultLatex = rounded.toString();
          _steps = const [
            _StepItem(
              title: 'Approximate two-sided limit',
              description: 'h -> 0^+',
            ),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
    } catch (_) {}

    try {
      // Solve simple quadratic equations ax^2+bx+c=0
      final normalized = input.replaceAll(' ', '').toLowerCase();
      if (normalized.contains('=0') && normalized.contains('x^2')) {
        final left = normalized.split('=')[0];
        final a = _coef(left, r'x\^2');
        final b = _coef(left, r'x(?!\^)');
        final c = _constant(left);
        final disc = b * b - 4 * a * c;
        String rootsLatex;
        if (disc >= 0) {
          final sqrtDisc = math.sqrt(disc);
          final x1 = (-b + sqrtDisc) / (2 * a);
          final x2 = (-b - sqrtDisc) / (2 * a);
          rootsLatex = 'x = ${_toLatexNumber(x1)}, ${_toLatexNumber(x2)}';
        } else {
          final sqrtDiscImag = math.sqrt(-disc);
          final real = -b / (2 * a);
          final imag = sqrtDiscImag / (2 * a);
          rootsLatex =
              'x = ${_toLatexNumber(real)} \\pm ${_toLatexNumber(imag)}i';
        }
        setState(() {
          _resultLatex = rootsLatex;
          _steps = [
            _StepItem(
              title: 'Identify coefficients',
              description: 'a=$a, b=$b, c=$c',
            ),
            const _StepItem(
              title: 'Apply quadratic formula',
              description: r'x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}',
            ),
          ];
        });
        ref
            .read(historyProvider.notifier)
            .add(
              _HistoryItem(
                expression: input,
                result: _resultLatex!,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        return;
      }
    } catch (e) {
      setState(() => _error = e.toString());
      return;
    }

    setState(
      () => _error =
          'Unsupported expression/equation. Try an expression like "2*sin(pi/3)" or a quadratic like "x^2-5x+6=0".',
    );
  }

  // Neural inference removed

  double _coef(String left, String pattern) {
    final regex = RegExp(r'([+-]?\d*\.?\d*)' + pattern);
    final match = regex.firstMatch(left);
    if (match == null) return 0;
    final g = match.group(1);
    if (g == null || g.isEmpty || g == '+' || g == '-') {
      return g == '-' ? -1 : 1;
    }
    return double.parse(g);
  }

  double _constant(String left) {
    // Remove terms with x and x^2, then sum remaining constants
    final cleaned = left
        .replaceAll(RegExp(r'[+-]?\d*\.?\d*x\^2'), '')
        .replaceAll(RegExp(r'[+-]?\d*\.?\d*x(?!\^)'), '');
    final parts = RegExp(
      r'([+-]?\d*\.?\d+)',
    ).allMatches(cleaned).map((m) => m.group(1)!).toList();
    if (parts.isEmpty) return 0;
    return parts.map(double.parse).fold(0.0, (a, b) => a + b);
  }

  String _toLatexNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  num _roundNumeric(num value, int precision) {
    final factor = math.pow(10, precision);
    return (value * factor).round() / factor;
  }

  // --- Helpers: parsing lists/matrices and linear algebra ---
  List<double> _parseList(String s) {
    final cleaned = s.replaceAll('[', '').replaceAll(']', '');
    if (cleaned.trim().isEmpty) return [];
    return cleaned.split(',').map((e) => double.parse(e.trim())).toList();
  }

  List<List<double>> _parseMatrix(String s) {
    // Format: [a,b;c,d] or [[a,b],[c,d]]
    var t = s.trim();
    if (t.startsWith('[') && t.endsWith(']')) t = t.substring(1, t.length - 1);
    if (t.contains('];[') || t.contains('],[')) {
      // [[a,b],[c,d]] style
      t = t.replaceAll('[[', '[').replaceAll(']]', ']');
    }
    final rows = t.split(';');
    return rows
        .map(
          (r) => r
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .where((x) => x.trim().isNotEmpty)
              .map((e) => double.parse(e.trim()))
              .toList(),
        )
        .toList();
  }

  List<String> _splitTopLevel(String s) {
    final res = <String>[];
    int depth = 0;
    int last = 0;
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '[' || c == '(') {
        depth++;
      } else if (c == ']' || c == ')') {
        depth--;
      } else if (c == ',' && depth == 0) {
        res.add(s.substring(last, i));
        last = i + 1;
      }
    }
    res.add(s.substring(last));
    return res.map((e) => e.trim()).toList();
  }

  double _determinant(List<List<double>> a) {
    final n = a.length;
    final m = a.map((r) => r.toList()).toList();
    double det = 1.0;
    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int r = i; r < n; r++) {
        if (m[r][i].abs() > m[pivot][i].abs()) pivot = r;
      }
      if (m[pivot][i].abs() < 1e-12) return 0.0;
      if (pivot != i) {
        final tmp = m[i];
        m[i] = m[pivot];
        m[pivot] = tmp;
        det *= -1;
      }
      det *= m[i][i];
      final piv = m[i][i];
      for (int r = i + 1; r < n; r++) {
        final f = m[r][i] / piv;
        for (int c = i; c < n; c++) {
          m[r][c] -= f * m[i][c];
        }
      }
    }
    return det;
  }

  List<List<double>> _inverse(List<List<double>> a) {
    final n = a.length;
    final m = a.map((r) => r.toList()).toList();
    final inv = List.generate(
      n,
      (i) => List.generate(n, (j) => j == i ? 1.0 : 0.0),
    );
    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int r = i; r < n; r++) {
        if (m[r][i].abs() > m[pivot][i].abs()) pivot = r;
      }
      if (m[pivot][i].abs() < 1e-12) throw Exception('Singular matrix');
      if (pivot != i) {
        final tr = m[i];
        m[i] = m[pivot];
        m[pivot] = tr;
        final ti = inv[i];
        inv[i] = inv[pivot];
        inv[pivot] = ti;
      }
      final piv = m[i][i];
      for (int c = 0; c < n; c++) {
        m[i][c] /= piv;
        inv[i][c] /= piv;
      }
      for (int r = 0; r < n; r++) {
        if (r != i) {
          final f = m[r][i];
          for (int c = 0; c < n; c++) {
            m[r][c] -= f * m[i][c];
            inv[r][c] -= f * inv[i][c];
          }
        }
      }
    }
    return inv;
  }

  List<double> _solveLinear(List<List<double>> a, List<double> b) {
    final n = a.length;
    final m = a.map((r) => r.toList()).toList();
    final rhs = b.toList();
    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int r = i; r < n; r++) {
        if (m[r][i].abs() > m[pivot][i].abs()) pivot = r;
      }
      if (pivot != i) {
        final tr = m[i];
        m[i] = m[pivot];
        m[pivot] = tr;
        final tb = rhs[i];
        rhs[i] = rhs[pivot];
        rhs[pivot] = tb;
      }
      final piv = m[i][i];
      for (int c = i; c < n; c++) {
        m[i][c] /= piv;
      }
      rhs[i] /= piv;
      for (int r = 0; r < n; r++) {
        if (r != i) {
          final f = m[r][i];
          for (int c = i; c < n; c++) {
            m[r][c] -= f * m[i][c];
          }
          rhs[r] -= f * rhs[i];
        }
      }
    }
    return rhs;
  }

  void _insertAtCursor(String text) {
    final sel = _controller.selection;
    final original = _controller.text;
    final start = sel.start >= 0 ? sel.start : original.length;
    final end = sel.end >= 0 ? sel.end : original.length;
    final newText = original.replaceRange(start, end, text);
    final newCursor = start + text.length;
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  void _backspaceAtCursor() {
    final sel = _controller.selection;
    final text = _controller.text;
    if (sel.start == -1) return;
    if (sel.start != sel.end) {
      // Delete selection
      final newText = text.replaceRange(sel.start, sel.end, '');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start),
      );
      return;
    }
    if (sel.start == 0) return;
    final start = sel.start - 1;
    final newText = text.replaceRange(start, sel.start, '');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start),
    );
  }

  void _moveCursor(int delta) {
    final text = _controller.text;
    final sel = _controller.selection;
    int pos = (sel.baseOffset >= 0 ? sel.baseOffset : text.length) + delta;
    pos = pos.clamp(0, text.length);
    _controller.selection = TextSelection.collapsed(offset: pos);
  }

  double _integrateNumeric(
    me.Expression exp,
    String variable,
    double a,
    double b,
    me.ContextModel ctx,
  ) {
    // Composite Simpson rule with n even subintervals
    const n = 200; // responsive and fast on device
    final h = (b - a) / n;
    double sum = 0;
    double f(double x) {
      ctx.bindVariable(me.Variable(variable), me.Number(x));
      return (exp.evaluate(me.EvaluationType.REAL, ctx) as num).toDouble();
    }

    for (int i = 0; i <= n; i++) {
      final x = a + i * h;
      final fx = f(x);
      if (i == 0 || i == n) {
        sum += fx;
      } else if (i.isOdd) {
        sum += 4 * fx;
      } else {
        sum += 2 * fx;
      }
    }
    return sum * h / 3;
  }

  double _limitNumeric(
    me.Expression exp,
    String variable,
    double a,
    me.ContextModel ctx,
  ) {
    double f(double x) {
      ctx.bindVariable(me.Variable(variable), me.Number(x));
      return (exp.evaluate(me.EvaluationType.REAL, ctx) as num).toDouble();
    }

    double h = 1e-3;
    final left = f(a - h);
    final right = f(a + h);
    return (left + right) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final simplePref = ref.watch(simpleModeProvider);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final simple = simplePref || !isLandscape;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MatMate'),
        actions: [
          if (!simple)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
            ),
          if (!simple)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Guide',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GuideScreen())),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isLandscape && !simplePref)
                        Card(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.screen_rotation_alt_outlined),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Advanced mode requires landscape orientation. Running in Simple Mode.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: 'Enter expression or equation',
                                  hintText: 'e.g. 2*sin(pi/3) or x^2-5x+6=0',
                                  prefixIcon: const Icon(Icons.functions),
                                  suffixIcon: FilledButton.icon(
                                    onPressed: _solve,
                                    icon: const Icon(Icons.calculate_outlined),
                                    label: const Text('Solve'),
                                  ),
                                ),
                                onSubmitted: (_) => _solve(),
                                textInputAction: TextInputAction.done,
                              ),
                              if (!simple) ...[
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ActionChip(
                                        label: const Text('Trig & log'),
                                        onPressed: () {
                                          _controller.text =
                                              '2*sin(pi/3)+ln(e)';
                                          _solve();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      ActionChip(
                                        label: const Text('Quadratic'),
                                        onPressed: () {
                                          _controller.text = 'x^2-5x+6=0';
                                          _solve();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              _CalculatorKeypad(
                                onText: (t) => _insertAtCursor(t),
                                onSolve: _solve,
                                onBackspace: _backspaceAtCursor,
                                onMoveLeft: () => _moveCursor(-1),
                                onMoveRight: () => _moveCursor(1),
                                simple: simple,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!)),
                              ],
                            ),
                          ),
                        ),
                      if (_resultLatex != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Result',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Math.tex(
                                    _resultLatex!,
                                    textStyle: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_steps.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _steps.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final step = _steps[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.15),
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(step.title),
                                subtitle: step.description.startsWith(r'\\')
                                    ? Math.tex(step.description)
                                    : Text(step.description),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem {
  final String title;
  final String description;
  const _StepItem({required this.title, required this.description});
}

class _CalculatorKeypad extends StatelessWidget {
  final void Function(String) onText;
  final VoidCallback onSolve;
  final VoidCallback onBackspace;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final bool simple;
  const _CalculatorKeypad({
    required this.onText,
    required this.onSolve,
    required this.onBackspace,
    required this.onMoveLeft,
    required this.onMoveRight,
    this.simple = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget key(String label, {String? insert, IconData? icon, Color? color}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => onText(insert ?? label),
            child: icon != null ? Icon(icon) : Text(label),
          ),
        ),
      );
    }

    if (simple) {
      return Column(
        children: [
          Row(
            children: [
              key('7'),
              key('8'),
              key('9'),
              key('÷', insert: '/'),
              key(
                '⌫',
                icon: Icons.backspace_outlined,
                color: scheme.errorContainer,
              ),
            ],
          ),
          Row(
            children: [
              key('4'),
              key('5'),
              key('6'),
              key('×', insert: '*'),
              key('('),
            ],
          ),
          Row(
            children: [
              key('1'),
              key('2'),
              key('3'),
              key('−', insert: '-'),
              key(')'),
            ],
          ),
          Row(
            children: [
              key('0'),
              key('.'),
              key('+'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: FilledButton(
                    onPressed: onSolve,
                    child: const Text('='),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: FilledButton.tonal(
                    onPressed: onMoveLeft,
                    child: const Icon(Icons.chevron_left),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: FilledButton.tonal(
                    onPressed: onMoveRight,
                    child: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            key('7'),
            key('8'),
            key('9'),
            key('÷', insert: '/'),
            key(
              '⌫',
              icon: Icons.backspace_outlined,
              color: scheme.errorContainer,
            ),
          ],
        ),
        Row(
          children: [
            key('4'),
            key('5'),
            key('6'),
            key('×', insert: '*'),
            key('('),
          ],
        ),
        Row(
          children: [
            key('1'),
            key('2'),
            key('3'),
            key('−', insert: '-'),
            key(')'),
          ],
        ),
        Row(
          children: [
            key('0'),
            key('.'),
            key('^'),
            key('+'),
            key(
              '= ',
              insert: '',
              icon: Icons.play_arrow_rounded,
              color: scheme.primaryContainer,
            ),
          ],
        ),
        Row(
          children: [
            key('π', insert: 'pi'),
            key('e'),
            key('√', insert: 'sqrt('),
            key('sin', insert: 'sin('),
            key('cos', insert: 'cos('),
          ],
        ),
        Row(
          children: [
            key('ln', insert: 'ln('),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: FilledButton.tonal(
                  onPressed: onMoveLeft,
                  child: const Icon(Icons.chevron_left),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: FilledButton.tonal(
                  onPressed: onMoveRight,
                  child: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: FilledButton(
                  onPressed: onBackspace,
                  child: const Icon(Icons.backspace_outlined),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: FilledButton(
                  onPressed: onSolve,
                  child: const Text('Solve'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Settings: Theme & Precision
final themeModeProvider =
    StateNotifierProvider<_ThemeModeController, ThemeMode>((ref) {
      return _ThemeModeController()..load();
    });

class _ThemeModeController extends StateNotifier<ThemeMode> {
  _ThemeModeController() : super(ThemeMode.system);
  static const _key = 'settings_theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == null) return;
    state = _fromString(v);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(mode));
  }

  ThemeMode _fromString(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final precisionProvider = StateNotifierProvider<_PrecisionController, int>((
  ref,
) {
  return _PrecisionController()..load();
});

class _PrecisionController extends StateNotifier<int> {
  _PrecisionController() : super(4);
  static const _key = 'settings_precision';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_key) ?? 4;
  }

  Future<void> set(int v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, v);
  }
}

final simpleModeProvider = StateNotifierProvider<_SimpleModeController, bool>((
  ref,
) {
  return _SimpleModeController()..load();
});

class _SimpleModeController extends StateNotifier<bool> {
  _SimpleModeController() : super(false);
  static const _key = 'settings_simple_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> set(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}

// History
class _HistoryItem {
  final String expression;
  final String result;
  final int timestampMs;
  const _HistoryItem({
    required this.expression,
    required this.result,
    required this.timestampMs,
  });
}

// Removed locale provider - using English only

final historyProvider =
    StateNotifierProvider<_HistoryController, List<_HistoryItem>>((ref) {
      return _HistoryController()..load();
    });

class _HistoryController extends StateNotifier<List<_HistoryItem>> {
  _HistoryController() : super(const []);
  static const _key = 'history_items';
  static const _max = 50;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    state = list.map((s) => _decode(s)).whereType<_HistoryItem>().toList()
      ..sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
  }

  Future<void> add(_HistoryItem item) async {
    final updated = [item, ...state];
    if (updated.length > _max) {
      updated.removeRange(_max, updated.length);
    }
    state = updated;
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.map(_encode).toList());
  }

  String _encode(_HistoryItem i) =>
      '${i.timestampMs}|${i.expression.replaceAll('|', '%7C')}|${i.result.replaceAll('|', '%7C')}';
  _HistoryItem? _decode(String s) {
    final parts = s.split('|');
    if (parts.length < 3) return null;
    return _HistoryItem(
      timestampMs: int.tryParse(parts[0]) ?? 0,
      expression: parts[1].replaceAll('%7C', '|'),
      result: parts[2].replaceAll('%7C', '|'),
    );
  }
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear',
            onPressed: items.isEmpty
                ? null
                : () => ref.read(historyProvider.notifier).clear(),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final it = items[i];
                final dt = DateTime.fromMillisecondsSinceEpoch(it.timestampMs);
                return ListTile(
                  title: Text(it.expression),
                  subtitle: Text('= ${it.result}\n${dt.toLocal()}'),
                  isThreeLine: true,
                  onTap: () => Navigator.pop(context, it.expression),
                );
              },
            ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final precision = ref.watch(precisionProvider);
    final simple = ref.watch(simpleModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Simple mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: simple,
                onChanged: (v) => ref.read(simpleModeProvider.notifier).set(v),
              ),
            ],
          ),
          // Removed language settings - using English only
          const SizedBox(height: 24),
          Text(
            'Precision ($precision decimals)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: precision.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$precision',
            onChanged: (v) =>
                ref.read(precisionProvider.notifier).set(v.round()),
          ),
          const SizedBox(height: 24),
          Text('Simple Mode', style: Theme.of(context).textTheme.titleMedium),
          Switch(
            value: ref.watch(simpleModeProvider),
            onChanged: (v) => ref.read(simpleModeProvider.notifier).set(v),
          ),
        ],
      ),
    );
  }
}

// Removed language label function - using English only

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatMate Guide'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to MatMate!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Basic Arithmetic',
              ['2 + 3 * 4', 'sqrt(16)', '2^3', 'sin(pi/2)', 'log(100)'],
              'Basic math operations, functions, and constants.',
            ),
            _buildSection(
              context,
              'Equations',
              ['x^2 + 5x + 6 = 0', '2x + 3 = 7', 'x^3 - 8 = 0'],
              'Solve linear, quadratic, and polynomial equations.',
            ),
            _buildSection(context, 'Calculus', [
              'd/dx(x^2)',
              'integral(x^2, 0, 1)',
              'limit(1/x, x, 0)',
            ], 'Derivatives, definite integrals, and limits.'),
            _buildSection(
              context,
              'Matrices',
              [
                'det([1,2;3,4])',
                'inv([2,1;1,2])',
                'solve([[1,2],[3,4]], [5,6])',
              ],
              'Matrix operations: determinant, inverse, linear systems.',
            ),
            _buildSection(context, 'Statistics', [
              'mean([1,2,3,4,5])',
              'median([1,3,5,7,9])',
              'sum([1,2,3,4,5])',
            ], 'Statistical functions on lists of numbers.'),
            _buildSection(context, 'Functions', [
              'f(x) = x^2 + 2x + 1',
              'f(3)',
              'f(g(x)) = x^2',
            ], 'Define and evaluate functions.'),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('• Use parentheses for grouping: (2+3)*4'),
                    const Text('• Functions: sin, cos, tan, log, sqrt, exp'),
                    const Text('• Constants: pi, e'),
                    const Text('• Matrix format: [a,b;c,d] or [[a,b],[c,d]]'),
                    const Text('• Lists: [1,2,3,4,5]'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> examples,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            ...examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $example',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
