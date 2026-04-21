import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';

/// Navigation item descriptor.
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final String? section;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.section,
  });
}

/// Adaptive scaffold — side navigation on desktop, bottom nav on mobile.
class AppScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const List<NavItem> navItems = [
    // MAIN
    NavItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      route: '/dashboard',
      section: 'MAIN',
    ),
    NavItem(
      label: 'Patients',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      route: '/patients',
      section: 'MAIN',
    ),
    NavItem(
      label: 'Appointments',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      route: '/appointments',
      section: 'MAIN',
    ),
    // CLINICAL
    NavItem(
      label: 'Consultations',
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      route: '/consultations',
      section: 'CLINICAL',
    ),
    NavItem(
      label: 'Maternal Care',
      icon: Icons.pregnant_woman_outlined,
      activeIcon: Icons.pregnant_woman_rounded,
      route: '/maternal',
      section: 'CLINICAL',
    ),
    NavItem(
      label: 'Immunization',
      icon: Icons.vaccines_outlined,
      activeIcon: Icons.vaccines_rounded,
      route: '/immunization',
      section: 'CLINICAL',
    ),
    // PROGRAMS
    NavItem(
      label: 'Family Planning',
      icon: Icons.family_restroom_outlined,
      activeIcon: Icons.family_restroom_rounded,
      route: '/family-planning',
      section: 'PROGRAMS',
    ),
    NavItem(
      label: 'Nutrition',
      icon: Icons.monitor_weight_outlined,
      activeIcon: Icons.monitor_weight_rounded,
      route: '/nutrition',
      section: 'PROGRAMS',
    ),
    NavItem(
      label: 'Dental',
      icon: Icons.health_and_safety_outlined,
      activeIcon: Icons.health_and_safety_rounded,
      route: '/dental',
      section: 'PROGRAMS',
    ),
    // SERVICES
    NavItem(
      label: 'Laboratory',
      icon: Icons.science_outlined,
      activeIcon: Icons.science_rounded,
      route: '/laboratory',
      section: 'SERVICES',
    ),
    NavItem(
      label: 'Pharmacy',
      icon: Icons.local_pharmacy_outlined,
      activeIcon: Icons.local_pharmacy_rounded,
      route: '/pharmacy',
      section: 'SERVICES',
    ),
    // MANAGEMENT
    NavItem(
      label: 'Reports',
      icon: Icons.assessment_outlined,
      activeIcon: Icons.assessment_rounded,
      route: '/reports',
      section: 'MANAGEMENT',
    ),
    NavItem(
      label: 'Administration',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings_rounded,
      route: '/admin',
      section: 'MANAGEMENT',
    ),
  ];

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    // Show only first 5 items on bottom nav; rest accessible via "More"
    const mobileItems = [0, 1, 2, 3, 11]; // Dashboard, Patients, Appointments, Consultations, Reports
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
        ),
      ),
      child: NavigationBar(
        selectedIndex: mobileItems.contains(widget.currentIndex)
            ? mobileItems.indexOf(widget.currentIndex)
            : 0,
        onDestinationSelected: (i) {
          context.go(AppScaffold.navItems[mobileItems[i]].route);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primarySurface,
        destinations: mobileItems.map((i) {
          final item = AppScaffold.navItems[i];
          return NavigationDestination(
            icon: Icon(item.icon, size: 22),
            selectedIcon:
                Icon(item.activeIcon, size: 22, color: AppColors.primary),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSidebar() {
    final w = _sidebarCollapsed ? 72.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: w,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: Color(0xFF1A3D40), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ── Logo Header ──────────────────────────────────────────
          _buildLogoHeader(),
          const Divider(color: Color(0xFF1A4548), thickness: 0.5),

          // ── Navigation Items ─────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavList(),
            ),
          ),

          // ── Collapse Toggle ──────────────────────────────────────
          const Divider(color: Color(0xFF1A4548), thickness: 0.5),
          _buildCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _sidebarCollapsed ? 12 : 20,
        vertical: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'BC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (!_sidebarCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BCHMS',
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Brgy. Cabad Health',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.sidebarText.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildNavList() {
    final items = AppScaffold.navItems;
    final List<Widget> widgets = [];
    String? currentSection;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Section header
      if (item.section != currentSection) {
        currentSection = item.section;
        if (!_sidebarCollapsed && currentSection != null) {
          widgets.add(
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: i == 0 ? 4 : 20,
                bottom: 8,
              ),
              child: Text(
                currentSection,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.sidebarText.withValues(alpha: 0.4),
                  letterSpacing: 1.2,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        } else if (_sidebarCollapsed && i > 0) {
          widgets.add(const SizedBox(height: 8));
        }
      }

      widgets.add(_buildNavItem(item, i));
    }

    return widgets;
  }

  Widget _buildNavItem(NavItem item, int index) {
    final isSelected = widget.currentIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _sidebarCollapsed ? 10 : 12,
        vertical: 1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(item.route),
          hoverColor: AppColors.sidebarHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarCollapsed ? 12 : 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sidebarActive.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: AppColors.sidebarActive.withValues(alpha: 0.3),
                      width: 0.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.sidebarActive
                      : AppColors.sidebarText,
                ),
                if (!_sidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.sidebarText,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Icon(
            _sidebarCollapsed
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            color: AppColors.sidebarText,
            size: 20,
          ),
        ),
      ),
    );
  }
}
