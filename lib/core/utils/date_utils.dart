import 'package:intl/intl.dart';

/// Date formatting utilities used throughout the app.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _numericDate = DateFormat('MM/dd/yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy · h:mm a');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// "April 21, 2026"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// "Apr 21, 2026"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// "04/21/2026"
  static String numericDate(DateTime date) => _numericDate.format(date);

  /// "2:30 PM"
  static String time(DateTime date) => _time.format(date);

  /// "Apr 21, 2026 · 2:30 PM"
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// "April 2026"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// "Apr 21"
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// "2026-04-21"
  static String isoDate(DateTime date) => _isoDate.format(date);

  /// Calculate age from birthdate.
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculate age in months (for infants/children).
  static int calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  }

  /// "2 days ago", "Just now", etc.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return shortDate(date);
  }

  /// Calculate Expected Date of Delivery from Last Menstrual Period.
  static DateTime calculateEDD(DateTime lmp) {
    return lmp.add(const Duration(days: 280));
  }

  /// Calculate Age of Gestation in weeks from LMP.
  static int calculateAOG(DateTime lmp) {
    return DateTime.now().difference(lmp).inDays ~/ 7;
  }

  /// Get trimester from LMP.
  static int getTrimester(DateTime lmp) {
    final weeks = calculateAOG(lmp);
    if (weeks <= 12) return 1;
    if (weeks <= 27) return 2;
    return 3;
  }
}
