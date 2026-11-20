import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import 'dashboard_page.dart';
import 'masjid_api.dart';
import 'session.dart';

/// Pintu masuk Moeslim Masjid: login → verifikasi email → daftar masjid → dashboard.
class MasjidHomePage extends ConsumerWidget {
  const MasjidHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Moeslim Masjid')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', textAlign: TextAlign.center),
              TextButton(onPressed: () => ref.invalidate(sessionProvider), child: const Text('Coba lagi')),
            ],
          ),
        ),
      ),
      data: (s) {
        if (s == null) return const LoginPage();
        if (!s.emailVerified) return const VerifyEmailPage();
        if (s.mosques.isEmpty) return const RegisterMosquePage();
        return const MasjidDashboardPage();
      },
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final n = ref.read(sessionProvider.notifier);
      _register
          ? await n.register(_name.text.trim(), _email.text.trim(), _password.text)
          : await n.login(_email.text.trim(), _password.text);
    } on ApiException catch (e) {
      setState(() => _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moeslim Masjid')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: BrandLogo(variant: BrandLogoVariant.stacked, height: 120)),
          const SizedBox(height: 8),
          const Text(
            'Kelola kas, agenda, petugas, dan TV Display masjid bersama hingga 5 pengurus. Rp59.000/bulan, seluruh fitur.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_register)
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama lengkap'),
            ),
          TextField(
            key: const Key('email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: _register ? 'Kata sandi (min. 10 karakter)' : 'Kata sandi'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('submit'),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_register ? 'Daftar' : 'Masuk'),
          ),
          TextButton(
            onPressed: () => setState(() => _register = !_register),
            child: Text(_register ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar pengurus'),
          ),
        ],
      ),
    );
  }
}

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _code = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(sessionProvider).value?.user['email'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(sessionProvider.notifier).logout()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Masukkan 6 digit kode yang dikirim ke $email.'),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Kode'),
          ),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(masjidApiProvider).verifyEmail(_code.text.trim());
                await ref.read(sessionProvider.notifier).refresh();
              } on ApiException catch (e) {
                setState(() => _error = e.message);
              }
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
}

class RegisterMosquePage extends ConsumerStatefulWidget {
  const RegisterMosquePage({super.key});

  @override
  ConsumerState<RegisterMosquePage> createState() => _RegisterMosquePageState();
}

class _RegisterMosquePageState extends ConsumerState<RegisterMosquePage> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  City _city = indonesianCities.firstWhere((c) => c.name == 'Jakarta');
  String? _error;
  bool _busy = false;

  static String _tzName(double offset) => switch (offset) {
    8.0 => 'Asia/Makassar',
    9.0 => 'Asia/Jayapura',
    _ => 'Asia/Jakarta',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftarkan Masjid'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(sessionProvider.notifier).logout()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nama masjid'),
          ),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Alamat'),
          ),
          DropdownButtonFormField<City>(
            initialValue: _city,
            decoration: const InputDecoration(labelText: 'Kota (koordinat awal; dapat disesuaikan)'),
            items: [for (final c in indonesianCities) DropdownMenuItem(value: c, child: Text(c.name))],
            onChanged: (c) => setState(() => _city = c ?? _city),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      await ref.read(masjidApiProvider).registerMosque({
                        'name': _name.text.trim(),
                        'address': _address.text.trim(),
                        'city': _city.name,
                        'province': _city.province,
                        'latitude': _city.latitude,
                        'longitude': _city.longitude,
                        'timezone': _tzName(_city.utcOffset),
                      });
                      await ref.read(sessionProvider.notifier).refresh();
                    } on ApiException catch (e) {
                      setState(() => _error = e.message);
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            child: const Text('Daftar & mulai uji coba 30 hari'),
          ),
        ],
      ),
    );
  }
}
