/// Application-wide constants and enumerations for BCHMS.
library;

// ── User Roles ──────────────────────────────────────────────────────
enum UserRole {
  admin('Admin'),
  healthWorker('Health Worker'),
  viewer('Viewer');

  final String label;
  const UserRole(this.label);
}

// ── Appointment Types ───────────────────────────────────────────────
enum AppointmentType {
  general('General Consultation'),
  prenatal('Prenatal Checkup'),
  immunization('Immunization'),
  familyPlanning('Family Planning'),
  dental('Dental'),
  laboratory('Laboratory'),
  followUp('Follow-up'),
  nutrition('Nutrition Assessment');

  final String label;
  const AppointmentType(this.label);
}

// ── Appointment Status ──────────────────────────────────────────────
enum AppointmentStatus {
  scheduled('Scheduled'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled'),
  noShow('No Show');

  final String label;
  const AppointmentStatus(this.label);
}

// ── Lab Request Status ──────────────────────────────────────────────
enum LabStatus {
  pending('Pending'),
  processing('Processing'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const LabStatus(this.label);
}

// ── Maternal Status ─────────────────────────────────────────────────
enum MaternalStatus {
  prenatal('Prenatal'),
  postnatal('Postnatal'),
  delivered('Delivered'),
  complicated('Complicated');

  final String label;
  const MaternalStatus(this.label);
}

// ── Nutrition Status ────────────────────────────────────────────────
enum NutritionStatus {
  normal('Normal'),
  underweight('Underweight'),
  severelyUnderweight('Severely Underweight'),
  overweight('Overweight'),
  obese('Obese'),
  stunted('Stunted'),
  wasted('Wasted');

  final String label;
  const NutritionStatus(this.label);
}

// ── Family Planning Method ──────────────────────────────────────────
enum FPMethod {
  pills('Pills'),
  injectable('Injectable'),
  iud('IUD'),
  condom('Condom'),
  implant('Implant'),
  btl('BTL'),
  vasectomy('Vasectomy'),
  naturalMethod('Natural Method'),
  lactationalAmenorrhea('LAM');

  final String label;
  const FPMethod(this.label);
}

// ── Family Planning Status ──────────────────────────────────────────
enum FPStatus {
  active('Active'),
  discontinued('Discontinued'),
  switchedMethod('Switched Method'),
  dropout('Dropout');

  final String label;
  const FPStatus(this.label);
}

// ── Vaccine Types ───────────────────────────────────────────────────
enum VaccineType {
  bcg('BCG'),
  hepatitisB('Hepatitis B'),
  pentavalent('Pentavalent'),
  opv('OPV'),
  ipv('IPV'),
  pcv('PCV'),
  mmr('MMR'),
  rotavirus('Rotavirus'),
  influenza('Influenza'),
  japaneseEncephalitis('Japanese Encephalitis'),
  antiRabies('Anti-Rabies'),
  tetanusToxoid('Tetanus Toxoid'),
  covid19('COVID-19'),
  other('Other');

  final String label;
  const VaccineType(this.label);
}

// ── Sex / Gender ────────────────────────────────────────────────────
enum Sex {
  male('Male'),
  female('Female');

  final String label;
  const Sex(this.label);
}

// ── Civil Status ────────────────────────────────────────────────────
enum CivilStatus {
  single('Single'),
  married('Married'),
  widowed('Widowed'),
  separated('Separated'),
  livein('Live-in');

  final String label;
  const CivilStatus(this.label);
}

// ── Blood Type ──────────────────────────────────────────────────────
enum BloodType {
  aPositive('A+'),
  aNegative('A−'),
  bPositive('B+'),
  bNegative('B−'),
  abPositive('AB+'),
  abNegative('AB−'),
  oPositive('O+'),
  oNegative('O−'),
  unknown('Unknown');

  final String label;
  const BloodType(this.label);
}

// ── Medicine Category ───────────────────────────────────────────────
enum MedicineCategory {
  antibiotic('Antibiotic'),
  analgesic('Analgesic'),
  antipyretic('Antipyretic'),
  antihypertensive('Antihypertensive'),
  vitamin('Vitamin/Supplement'),
  vaccine('Vaccine'),
  contraceptive('Contraceptive'),
  antidiabetic('Antidiabetic'),
  antihistamine('Antihistamine'),
  gastrointestinal('Gastrointestinal'),
  respiratory('Respiratory'),
  topical('Topical'),
  other('Other');

  final String label;
  const MedicineCategory(this.label);
}

// ── Medicine Unit ───────────────────────────────────────────────────
enum MedicineUnit {
  tablet('Tablet'),
  capsule('Capsule'),
  bottle('Bottle'),
  vial('Vial'),
  ampule('Ampule'),
  sachet('Sachet'),
  tube('Tube'),
  piece('Piece');

  final String label;
  const MedicineUnit(this.label);
}

// ── Lab Test Types ──────────────────────────────────────────────────
enum LabTestType {
  cbc('CBC'),
  urinalysis('Urinalysis'),
  fecalysis('Fecalysis'),
  bloodTyping('Blood Typing'),
  bloodSugar('Blood Sugar'),
  cholesterol('Cholesterol'),
  hepatitisB('Hepatitis B Screening'),
  hiv('HIV Screening'),
  pregnancyTest('Pregnancy Test'),
  sputumExam('Sputum Exam'),
  drugTest('Drug Test'),
  xray('X-Ray'),
  ultrasound('Ultrasound'),
  other('Other');

  final String label;
  const LabTestType(this.label);
}

// ── Navigation Section Labels ───────────────────────────────────────
class NavSections {
  NavSections._();
  static const String main = 'MAIN';
  static const String clinical = 'CLINICAL';
  static const String programs = 'PROGRAMS';
  static const String services = 'SERVICES';
  static const String management = 'MANAGEMENT';
}
