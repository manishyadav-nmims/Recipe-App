import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor:
      isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          _DrawerHeader(isDark: isDark),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _NightModeToggle(
              isDark: isDark,
              onToggle: onThemeToggle,
            ),
          ),

          const Spacer(),

          // ── Logout ──────────────────────────────────────────────────
          _LogoutButton(isDark: isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  const _DrawerHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Recipe Hub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'chef@recipehub.app',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
    isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A2E);
    final iconColor = AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: AppTheme.primaryColor.withOpacity(0.12),
          highlightColor: AppTheme.primaryColor.withOpacity(0.07),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Night Mode Toggle

class _NightModeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _NightModeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final textColor =
    isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A2E);
    final trackColor = isDark
        ? AppTheme.primaryColor.withOpacity(0.35)
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isDark ? 'Night Mode' : 'Light Mode',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: onToggle,
            activeColor: AppTheme.primaryColor,
            trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : trackColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────────────────────────────────────
class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Divider(
        color: Colors.grey.withOpacity(0.25),
        thickness: 1,
        height: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout Button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final bool isDark;
  const _LogoutButton({required this.isDark});

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context); // close drawer first
            _showLogoutSheet(context);
          },
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.logout_rounded,
                    color: AppTheme.errorColor, size: 22),
                const SizedBox(width: 14),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  final BuildContext parentContext;
  const _LogoutSheet({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppTheme.darkSurfaceColor : Colors.white;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout_rounded,
                color: AppTheme.errorColor, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            'Logging out?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll need to sign in again to access your recipes and favourites.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    parentContext
                        .read<AuthBloc>()
                        .add(LogoutEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}