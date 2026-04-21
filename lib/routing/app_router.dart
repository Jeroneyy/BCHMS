import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/patients/patient_list_screen.dart';
import '../features/patients/patient_detail_screen.dart';
import '../features/patients/patient_form_screen.dart';
import '../features/appointments/appointment_list_screen.dart';
import '../features/appointments/appointment_form_screen.dart';
import '../features/consultations/consultation_screen.dart';
import '../features/maternal/maternal_list_screen.dart';
import '../features/maternal/prenatal_form_screen.dart';
import '../features/immunization/immunization_list_screen.dart';
import '../features/immunization/immunization_form_screen.dart';
import '../features/family_planning/fp_list_screen.dart';
import '../features/family_planning/fp_form_screen.dart';
import '../features/nutrition/nutrition_list_screen.dart';
import '../features/nutrition/nutrition_form_screen.dart';
import '../features/dental/dental_list_screen.dart';
import '../features/dental/dental_form_screen.dart';
import '../features/laboratory/lab_list_screen.dart';
import '../features/laboratory/lab_form_screen.dart';
import '../features/pharmacy/inventory_screen.dart';
import '../features/pharmacy/medicine_form_screen.dart';
import '../features/pharmacy/dispensing_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/admin/admin_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggedIn = authService.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth Routes (no shell) ─────────────────────────────────
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),

      // ── App Shell ──────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final index = _getNavIndex(state.matchedLocation);
          return AppScaffold(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),

          // Patients
          GoRoute(path: '/patients', builder: (_, _) => const PatientListScreen()),
          GoRoute(path: '/patients/new', builder: (_, _) => const PatientFormScreen()),
          GoRoute(
            path: '/patients/:id',
            builder: (_, state) => PatientDetailScreen(patientId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/patients/:id/edit',
            builder: (_, state) => PatientFormScreen(patientId: state.pathParameters['id']),
          ),

          // Appointments
          GoRoute(path: '/appointments', builder: (_, _) => const AppointmentListScreen()),
          GoRoute(path: '/appointments/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return AppointmentFormScreen(patientId: patientId);
          }),

          // Consultations
          GoRoute(path: '/consultations', builder: (_, _) => const ConsultationScreen()),

          // Maternal
          GoRoute(path: '/maternal', builder: (_, _) => const MaternalListScreen()),
          GoRoute(path: '/maternal/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return PrenatalFormScreen(patientId: patientId);
          }),

          // Immunization
          GoRoute(path: '/immunization', builder: (_, _) => const ImmunizationListScreen()),
          GoRoute(path: '/immunization/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return ImmunizationFormScreen(patientId: patientId);
          }),

          // Family Planning
          GoRoute(path: '/family-planning', builder: (_, _) => const FPListScreen()),
          GoRoute(path: '/family-planning/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return FPFormScreen(patientId: patientId);
          }),

          // Nutrition
          GoRoute(path: '/nutrition', builder: (_, _) => const NutritionListScreen()),
          GoRoute(path: '/nutrition/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return NutritionFormScreen(patientId: patientId);
          }),

          // Dental
          GoRoute(path: '/dental', builder: (_, _) => const DentalListScreen()),
          GoRoute(path: '/dental/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return DentalFormScreen(patientId: patientId);
          }),

          // Laboratory
          GoRoute(path: '/laboratory', builder: (_, _) => const LabListScreen()),
          GoRoute(path: '/laboratory/new', builder: (_, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return LabFormScreen(patientId: patientId);
          }),

          // Pharmacy
          GoRoute(path: '/pharmacy', builder: (_, _) => const InventoryScreen()),
          GoRoute(path: '/pharmacy/new', builder: (_, _) => const MedicineFormScreen()),
          GoRoute(path: '/pharmacy/dispense', builder: (_, _) => const DispensingScreen()),

          // Reports
          GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),

          // Admin
          GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
        ],
      ),
    ],
  );
}

int _getNavIndex(String location) {
  final paths = [
    '/dashboard', '/patients', '/appointments', '/consultations',
    '/maternal', '/immunization', '/family-planning', '/nutrition',
    '/dental', '/laboratory', '/pharmacy', '/reports', '/admin',
  ];
  for (int i = 0; i < paths.length; i++) {
    if (location.startsWith(paths[i])) return i;
  }
  return 0;
}
