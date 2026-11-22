import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_shell.dart';
import 'session.dart';

/// Pintu masuk fitur tambahan Moeslim Mosque: pilih peran → login/aktivasi → verifikasi email → daftar masjid → dashboard.
class MasjidHomePage extends ConsumerWidget {
  const MasjidHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Moeslim Mosque')),
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
        if (s == null) return const MosqueLandingPage();
        if (!s.emailVerified) return const VerifyEmailPage();
        if (s.mosques.isEmpty) return const RegisterMosquePage();
        return const MasjidDashboardPage();
      },
    );
  }
}

String _apiError(ApiException e) =>
    e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message;

/// "Pilih Peran di Moeslim PM": Personal (gratis) atau Mosque (fitur tambahan pengurus).
class MosqueLandingPage extends StatelessWidget {
  const MosqueLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void openLogin(int tab) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage(initialTab: tab)));
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: BrandArt(BrandIllustration.cornerLattice, width: 170, opacity: .8)),
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Text('Pilih Peran di Moeslim PM', style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text(
                'Tentukan modul yang ingin Anda gunakan. Anda dapat beralih kapan saja.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: MoeslimIcons.profil,
                title: 'Moeslim Personal',
                body: 'Ibadah harian, Al-Qur\'an, doa, dan kebutuhan pribadi Muslim. Gratis tanpa akun.',
                selected: false,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              const SizedBox(height: 12),
              const _RoleCard(
                icon: MoeslimIcons.masjid,
                title: 'Moeslim Mosque',
                body: 'Kelola masjid: kas, kegiatan, petugas, pengurus, dan TV Display. Rp59.000/bulan per masjid (uji coba 30 hari).',
                selected: true,
              ),
              const SizedBox(height: 24),
              const BrandArt(BrandIllustration.mosqueCircle, key: Key('landing-art'), height: 230),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('register-mosque-start'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
                onPressed: () => openLogin(1),
                icon: const Icon(MoeslimIcons.masjid),
                label: const Text('Daftarkan Masjid'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  key: const Key('login-admin-start'),
                  onPressed: () => openLogin(0),
                  child: const Text('Sudah punya akses masjid? Aktifkan atau Login Admin'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback? onTap;
  const _RoleCard({required this.icon, required this.title, required this.body, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(body, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                selected ? MoeslimIcons.berhasil : Icons.circle_outlined,
                color: selected ? scheme.primary : scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Login / Aktivasi Admin Masjid: tab Login Admin (akun ada) dan Aktivasi Akun (akun baru + kode undangan opsional).
class LoginPage extends ConsumerStatefulWidget {
  final int initialTab;
  const LoginPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _invite = TextEditingController();
  late int _tab = widget.initialTab;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final n = ref.read(sessionProvider.notifier);
      if (_tab == 1) {
        await n.register(_name.text.trim(), _email.text.trim(), _password.text);
        if (_invite.text.trim().isNotEmpty) ref.read(pendingInviteProvider.notifier).set(_invite.text.trim());
      } else {
        await n.login(_email.text.trim(), _password.text);
      }
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // gerbang MasjidHomePage beralih otomatis
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = _apiError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Aktivasi Admin Masjid'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const BrandArt(BrandIllustration.loginShield, key: Key('login-art'), height: 170),
          const SizedBox(height: 8),
          Text('Akses Admin Moeslim Mosque', style: t.titleLarge, textAlign: TextAlign.center),
          const Text(
            'Masuk atau aktivasi akun admin untuk mengelola masjid Anda di Moeslim PM.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PillTabs(
            labels: const ['Login Admin', 'Aktivasi Akun'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          if (_tab == 1)
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama lengkap *', prefixIcon: Icon(MoeslimIcons.profil)),
            ),
          if (_tab == 1) const SizedBox(height: 12),
          TextField(
            key: const Key('email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(MoeslimIcons.surat)),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: _tab == 1 ? 'Kata sandi * (min. 10 karakter)' : 'Kata sandi *',
              prefixIcon: const Icon(MoeslimIcons.kunci),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                icon: Icon(_obscure ? Icons.lock_open_outlined : MoeslimIcons.kunci),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_tab == 1) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('invite-code'),
              controller: _invite,
              decoration: const InputDecoration(
                labelText: 'Kode undangan pengurus (opsional)',
                helperText: 'Dari admin masjid. Kosongkan bila Anda mendaftarkan masjid baru.',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('submit'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(MoeslimIcons.login),
            label: Text(_tab == 1 ? 'Aktivasi Akun' : 'Masuk ke Dashboard'),
          ),
          const SizedBox(height: 16),
          Card(
            color: BrandColors.gold.withValues(alpha: .12),
            child: const ListTile(
              leading: Icon(MoeslimIcons.pengaman, color: BrandColors.goldText),
              title: Text('Aman & Tepercaya', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Data masjid terisolasi per masjid dan hanya dapat diakses pengurus resmi.'),
            ),
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
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(MoeslimIcons.logout),
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: Icon(MoeslimIcons.surat, size: 72, color: BrandColors.emerald)),
          const SizedBox(height: 12),
          Text('Masukkan 6 digit kode yang dikirim ke $email.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, letterSpacing: 10),
            decoration: const InputDecoration(labelText: 'Kode verifikasi'),
          ),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
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
  final _phone = TextEditingController();
  final _simas = TextEditingController();
  City _city = indonesianCities.firstWhere((c) => c.name == 'Jakarta');
  String? _error;
  bool _busy = false;

  static String _tzName(double offset) => switch (offset) {
    8.0 => 'Asia/Makassar',
    9.0 => 'Asia/Jayapura',
    _ => 'Asia/Jakarta',
  };

  Future<void> _acceptPendingInvite() async {
    final token = ref.read(pendingInviteProvider);
    if (token == null) return;
    try {
      await ref.read(masjidApiProvider).acceptInvitation(token);
      ref.read(pendingInviteProvider.notifier).set(null);
      await ref.read(sessionProvider.notifier).refresh();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = 'Kode undangan: ${_apiError(e)}');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_acceptPendingInvite);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).value?.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Masjid'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(MoeslimIcons.logout),
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const BrandArt(BrandIllustration.manajemenMasjid4, key: Key('register-art'), height: 180),
          const SizedBox(height: 8),
          Text(
            'Daftarkan Masjid Anda di Moeslim PM',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text('Buat profil masjid dan mulai kelola operasional secara digital.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            key: const Key('mosque-name'),
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nama Masjid *',
              hintText: 'Contoh: Masjid Baiturrahman',
              prefixIcon: Icon(MoeslimIcons.masjid),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Alamat Lengkap *',
              hintText: 'Contoh: Jl. Ahmad Yani No. 10',
              prefixIcon: Icon(MoeslimIcons.lokasi),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<City>(
            initialValue: _city,
            decoration: const InputDecoration(labelText: 'Lokasi (Kota) *', prefixIcon: Icon(MoeslimIcons.peta)),
            items: [for (final c in indonesianCities) DropdownMenuItem(value: c, child: Text(c.name))],
            onChanged: (c) => setState(() => _city = c ?? _city),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'No. WhatsApp masjid', prefixIcon: Icon(MoeslimIcons.telepon)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _simas,
            decoration: const InputDecoration(
              labelText: 'ID Masjid SIMAS Kemenag (opsional)',
              helperText: 'Membantu verifikasi kepemilikan masjid.',
              prefixIcon: Icon(MoeslimIcons.petugas),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(MoeslimIcons.admin, color: BrandColors.emerald),
              title: const Text('Admin Utama (Pengelola)'),
              subtitle: Text('${user?['name'] ?? ''} • ${user?['email'] ?? ''}'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('register-mosque'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
            icon: const Icon(MoeslimIcons.check),
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
                        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
                        if (_simas.text.trim().isNotEmpty) 'simas_id': _simas.text.trim(),
                      });
                      await ref.read(sessionProvider.notifier).refresh();
                    } on ApiException catch (e) {
                      setState(() => _error = _apiError(e));
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            label: const Text('Daftarkan Masjid & mulai uji coba 30 hari'),
          ),
        ],
      ),
    );
  }
}
