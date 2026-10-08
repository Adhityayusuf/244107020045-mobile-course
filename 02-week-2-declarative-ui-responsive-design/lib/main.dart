import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Breakpoint lebar: < 700 -> 1 kolom, >= 700 -> 2 kolom.
const double kWideBreakpoint = 700;

void main() {
  var initialDark = false;
  var initialPage = 'overview';
  var initialVariant = '';
  if (kIsWeb) {
    try {
      final params = Uri.base.queryParameters;
      if (params['theme'] == 'dark') {
        initialDark = true;
      }
      if (params['page'] == 'warmup') {
        initialPage = 'warmup';
      }
      initialVariant = params['variant'] ?? '';
    } catch (_) {
      // Uri.base tidak tersedia di test / non-web: pakai default.
    }
  }
  runApp(
    AcademicOverviewApp(
      initialDark: initialDark,
      initialPage: initialPage,
      initialVariant: initialVariant,
    ),
  );
}

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({
    super.key,
    this.initialDark = false,
    this.initialPage = 'overview',
    this.initialVariant = '',
  });

  final bool initialDark;
  final String initialPage;
  final String initialVariant;

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  late bool isDark;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    isDark = widget.initialDark;
    currentIndex = widget.initialPage == 'warmup' ? 1 : 0;
  }

  void _onThemeChanged(bool value) {
    setState(() => isDark = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview — TI-2H',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: currentIndex == 0
            ? AcademicOverviewPage(
                isDark: isDark,
                onThemeChanged: _onThemeChanged,
              )
            : WarmupPage(variant: widget.initialVariant),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() => currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Warm-up',
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: 'Pengaturan tema',
            value: isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
            toggled: isDark,
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 4),
                CupertinoSwitch(
                  value: isDark,
                  onChanged: onThemeChanged,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            Text(
              'Academic Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const AcademicLayout(),
          ],
        ),
      ),
    );
  }
}

class AcademicLayout extends StatelessWidget {
  const AcademicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kWideBreakpoint) {
          return const Column(
            children: [
              AcademicCard(
                title: 'Assignments',
                value: '8',
                icon: Icons.assignment_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'Attendance',
                value: '92%',
                icon: Icons.event_available_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'GPA',
                value: '3.75',
                icon: Icons.school_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'Current Week',
                value: '02',
                icon: Icons.calendar_month_outlined,
              ),
            ],
          );
        }
        return const Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AcademicCard(
                    title: 'Assignments',
                    value: '8',
                    icon: Icons.assignment_outlined,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AcademicCard(
                    title: 'Attendance',
                    value: '92%',
                    icon: Icons.event_available_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AcademicCard(
                    title: 'GPA',
                    value: '3.75',
                    icon: Icons.school_outlined,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AcademicCard(
                    title: 'Current Week',
                    value: '02',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Profil M.Adhitya Yusuf Al-Ayyubi, TI-2H, NIM 244107020045',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'M.Adhitya Yusuf Al-Ayyubi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('NIM 244107020045'),
                  Text('Kelas TI-2H — Teknik Informatika'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicCard extends StatelessWidget {
  const AcademicCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 110),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WarmupPage extends StatelessWidget {
  const WarmupPage({super.key, this.variant = ''});

  /// Varian eksperimen warm-up (khusus dokumentasi screenshot):
  /// '' (normal), 'no-expanded', 'mainaxis'.
  final String variant;

  @override
  Widget build(BuildContext context) {
    final Widget card;
    switch (variant) {
      case 'no-expanded':
        card = const ProfileCardNoExpanded();
      case 'mainaxis':
        card = const SizedBox(
          height: 600,
          child: ProfileCardMainAxis(),
        );
      default:
        card = const ProfileCard();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Warm-up Profile Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(child: card),
      ),
    );
  }
}

/// Varian TANPA Expanded (eksperimen 1): teks panjang menabrak dan
/// memicu overflow karena Row tidak tahu cara membagi ruang.
class ProfileCardNoExpanded extends StatelessWidget {
  const ProfileCardNoExpanded({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sengaja satu baris panjang tanpa Expanded -> overflow.
                  Text(
                    'M.Adhitya Yusuf Al-Ayyubi TI-2H 244107020045',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('TI-2H — 244107020045'),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          InfoRow(label: 'NIM', value: '244107020045'),
          InfoRow(label: 'Kelas', value: 'TI-2H'),
        ],
      ),
    );
  }
}

/// Varian mainAxisSize.max (eksperimen 2): kartu meregang setinggi
/// ruang yang tersedia, terlihat kosong di bawah.
class ProfileCardMainAxis extends StatelessWidget {
  const ProfileCardMainAxis({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M.Adhitya Yusuf Al-Ayyubi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('TI-2H — 244107020045'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          InfoRow(label: 'NIM', value: '244107020045'),
          InfoRow(label: 'Kelas', value: 'TI-2H'),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M.Adhitya Yusuf Al-Ayyubi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('TI-2H — 244107020045'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          InfoRow(label: 'NIM', value: '244107020045'),
          InfoRow(label: 'Kelas', value: 'TI-2H'),
          InfoRow(label: 'Email', value: '244107020045@student.polinema.ac.id'),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
