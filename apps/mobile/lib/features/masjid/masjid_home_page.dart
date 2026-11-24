import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'mosque_shell.dart';
import 'session.dart';

/// Pintu masuk fitur tambahan Moeslim Mosque: pilih peran → login/aktivasi → verifikasi email → daftar masjid → dashboard.
class MasjidHomePage extends ConsumerWidget {
  const MasjidHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => mosqueScoped(context, (context) {
    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Moeslim Mosque'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  context.tr('Menghubungkan ke server...', 'Connecting to server...'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Moeslim Mosque'), centerTitle: true),
        body: SingleChildScrollView(
          child: BrandEmptyState(
            art: BrandEmptyArt.tanpaInternet,
            title: context.tr('Server belum dapat dijangkau', 'Server unavailable'),
            message: '$e',
            action: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('mosque-retry'),
                  onPressed: () => ref.invalidate(sessionProvider),
                  icon: const Icon(MoeslimIcons.refresh),
                  label: Text(context.tr('Coba lagi', 'Try again')),
                ),
                OutlinedButton(
                  key: const Key('mosque-back-personal'),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(context.tr('Kembali ke Personal', 'Back to Personal')),
                ),
                TextButton(
                  key: const Key('mosque-offline-logout'),
                  onPressed: () => ref.read(sessionProvider.notifier).logout(),
                  child: Text(context.tr('Keluar akun', 'Sign out')),
                ),
              ],
            ),
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
  });
}

String _apiError(ApiException e) =>
    e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message;

/// "Pilih Peran di Moeslim PM": Personal (gratis) atau Mosque (fitur tambahan pengurus).
class MosqueLandingPage extends StatelessWidget {
  const MosqueLandingPage({super.key});

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final t = Theme.of(context).textTheme;
    void openLogin(int tab) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage(initialTab: tab)));
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Text(
                context.tr('Pilih Peran di Moeslim PM', 'Choose Your Role in Moeslim PM'),
                style: t.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(
                  'Tentukan modul yang ingin Anda gunakan. Anda dapat beralih kapan saja.',
                  'Choose the module you want to use. You can switch anytime.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: MoeslimIcons.profil,
                title: 'Moeslim Personal',
                body: context.tr(
                  "Ibadah harian, Al-Qur'an, doa, dan kebutuhan pribadi Muslim. Gratis tanpa akun.",
                  "Daily worship, Qur'an, prayers, and personal Muslim tools. Free, no account needed.",
                ),
                selected: false,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: MoeslimIcons.masjid,
                title: 'Moeslim Mosque',
                body: context.tr(
                  'Kelola masjid: kas, kegiatan, petugas, pengurus, dan TV Display. Rp59.000/bulan per masjid (uji coba 30 hari).',
                  'Manage your mosque: treasury, events, roster, committee, and TV Display. Rp59,000/month per mosque (30-day free trial).',
                ),
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
                label: Text(context.tr('Daftarkan Masjid', 'Register Mosque')),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  key: const Key('login-admin-start'),
                  onPressed: () => openLogin(0),
                  child: Text(
                    context.tr(
                      'Sudah punya akses masjid? Aktifkan atau Login Admin',
                      'Already have mosque access? Activate or Admin Login',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
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
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Login / Aktivasi Admin Masjid', 'Mosque Admin Login / Activation')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const BrandArt(BrandIllustration.loginShield, key: Key('login-art'), height: 170),
          const SizedBox(height: 8),
          Text(
            context.tr('Akses Admin Moeslim Mosque', 'Moeslim Mosque Admin Access'),
            style: t.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            context.tr(
              'Masuk atau aktivasi akun admin untuk mengelola masjid Anda di Moeslim PM.',
              'Sign in or activate your admin account to manage your mosque in Moeslim PM.',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PillTabs(
            labels: [context.tr('Login Admin', 'Admin Login'), context.tr('Aktivasi Akun', 'Activate Account')],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          if (_tab == 1)
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: context.tr('Nama lengkap *', 'Full name *'),
                prefixIcon: const Icon(MoeslimIcons.profil),
              ),
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
              labelText: _tab == 1
                  ? context.tr('Kata sandi * (min. 10 karakter)', 'Password * (min. 10 characters)')
                  : context.tr('Kata sandi *', 'Password *'),
              prefixIcon: const Icon(MoeslimIcons.kunci),
              suffixIcon: IconButton(
                tooltip: _obscure
                    ? context.tr('Tampilkan kata sandi', 'Show password')
                    : context.tr('Sembunyikan kata sandi', 'Hide password'),
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
              decoration: InputDecoration(
                labelText: context.tr('Kode undangan pengurus (opsional)', 'Committee invite code (optional)'),
                helperText: context.tr(
                  'Dari admin masjid. Kosongkan bila Anda mendaftarkan masjid baru.',
                  'From your mosque admin. Leave blank if registering a new mosque.',
                ),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
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
            label: Text(
              _tab == 1
                  ? context.tr('Aktivasi Akun', 'Activate Account')
                  : context.tr('Masuk ke Dashboard', 'Sign In to Dashboard'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: BrandColors.gold.withValues(alpha: .12),
            child: ListTile(
              leading: const Icon(MoeslimIcons.pengaman, color: BrandColors.goldText),
              title: Text(
                context.tr('Aman & Tepercaya', 'Secure & Trusted'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                context.tr(
                  'Data masjid terisolasi per masjid dan hanya dapat diakses pengurus resmi.',
                  'Mosque data is isolated per mosque and accessible only to authorized committee members.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
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
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final email = ref.watch(sessionProvider).value?.user['email'];
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Verifikasi Email', 'Verify Email')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: context.tr('Keluar', 'Sign out'),
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
          Text(
            context.tr('Masukkan 6 digit kode yang dikirim ke $email.', 'Enter the 6-digit code sent to $email.'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, letterSpacing: 10),
            decoration: InputDecoration(labelText: context.tr('Kode verifikasi', 'Verification code')),
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
            child: Text(context.tr('Verifikasi', 'Verify')),
          ),
        ],
      ),
    );
  });
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
      if (mounted) {
        final isEn = mosqueLang(context) == AppLanguage.en;
        setState(() => _error = isEn ? 'Invite code: ${_apiError(e)}' : 'Kode undangan: ${_apiError(e)}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_acceptPendingInvite);
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final user = ref.watch(sessionProvider).value?.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Registrasi Masjid', 'Register Mosque')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: context.tr('Keluar', 'Sign out'),
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
            context.tr('Daftarkan Masjid Anda di Moeslim PM', 'Register Your Mosque on Moeslim PM'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
              'Buat profil masjid dan mulai kelola operasional secara digital.',
              'Create a mosque profile and start managing operations digitally.',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('mosque-name'),
            controller: _name,
            decoration: InputDecoration(
              labelText: context.tr('Nama Masjid *', 'Mosque Name *'),
              hintText: context.tr('Contoh: Masjid Baiturrahman', 'Example: Al-Ikhlas Mosque'),
              prefixIcon: const Icon(MoeslimIcons.masjid),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: InputDecoration(
              labelText: context.tr('Alamat Lengkap *', 'Full Address *'),
              hintText: context.tr('Contoh: Jl. Ahmad Yani No. 10', 'Example: 10 Merdeka Street'),
              prefixIcon: const Icon(MoeslimIcons.lokasi),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<City>(
            initialValue: _city,
            decoration: InputDecoration(
              labelText: context.tr('Lokasi (Kota) *', 'Location (City) *'),
              prefixIcon: const Icon(MoeslimIcons.peta),
            ),
            items: [for (final c in indonesianCities) DropdownMenuItem(value: c, child: Text(c.name))],
            onChanged: (c) => setState(() => _city = c ?? _city),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: context.tr('No. WhatsApp masjid', 'Mosque WhatsApp number'),
              prefixIcon: const Icon(MoeslimIcons.telepon),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _simas,
            decoration: InputDecoration(
              labelText: context.tr('ID Masjid SIMAS Kemenag (opsional)', 'SIMAS Mosque ID (optional)'),
              helperText: context.tr('Membantu verifikasi kepemilikan masjid.', 'Helps verify mosque ownership.'),
              prefixIcon: const Icon(MoeslimIcons.petugas),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(MoeslimIcons.admin, color: BrandColors.emerald),
              title: Text(context.tr('Admin Utama (Pengelola)', 'Primary Admin (Manager)')),
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
            label: Text(
              context.tr('Daftarkan Masjid & mulai uji coba 30 hari', 'Register Mosque & Start 30-Day Trial'),
            ),
          ),
        ],
      ),
    );
  });
}
