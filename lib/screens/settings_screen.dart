import 'package:flutter/material.dart';
import '../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifResults = true;
  bool _notifJackpots = true;
  bool _notifSpecial = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          // Notifications section
          const _SectionHeader(title: 'Notificaciones'),
          SwitchListTile(
            title: const Text('Resultados'),
            subtitle: const Text('Recibe los resultados de tus juegos favoritos'),
            value: _notifResults,
            activeTrackColor: AppTheme.primary,
            onChanged: (v) => setState(() => _notifResults = v),
          ),
          SwitchListTile(
            title: const Text('Botes importantes'),
            subtitle: const Text('Aviso cuando hay botes grandes'),
            value: _notifJackpots,
            activeTrackColor: AppTheme.primary,
            onChanged: (v) => setState(() => _notifJackpots = v),
          ),
          SwitchListTile(
            title: const Text('Sorteos extraordinarios'),
            subtitle: const Text('Navidad, El Niño y sorteos especiales'),
            value: _notifSpecial,
            activeTrackColor: AppTheme.primary,
            onChanged: (v) => setState(() => _notifSpecial = v),
          ),

          const Divider(),

          // About section
          const _SectionHeader(title: 'Información'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidad'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Términos de Uso'),
            onTap: () {
              // TODO: Open terms
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_outlined),
            title: const Text('Valora la app'),
            onTap: () {
              // TODO: Open store listing
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Compartir con amigos'),
            onTap: () {
              // TODO: Share app link
            },
          ),

          const Divider(),

          // Legal
          const _SectionHeader(title: 'Legal'),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SuerteYa es una app informativa. No gestiona ni vende loterías. '
              'Los datos provienen de fuentes oficiales (SELAE, ONCE). '
              'Juega con responsabilidad.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
