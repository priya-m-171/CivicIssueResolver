import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppColors {
  static const primary = Color(0xFF2B5CE6);
  static const primaryDark = Color(0xFF1A3BAF);
  static const secondary = Color(0xFF00C896);
  static const accent = Color(0xFFFF6B35);
  static const background = Color(0xFFF5F7FF);
  static const surface = Colors.white;
  static const cardBg = Color(0xFFF8F9FF);
  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const citizenColor = Color(0xFF2B5CE6);
  static const authorityColor = Color(0xFF7C3AED);
  static const workerColor = Color(0xFFEA580C);
  static const adminColor = Color(0xFF059669);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}

class AppConstants {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // The 5 basic categories for manual fallback when AI fails
  static const List<String> basicCategories = [
    'Roads & Traffic',
    'Sanitation & Garbage',
    'Water & Pipes',
    'Electricity & Safety',
    'Other',
  ];

  // The comprehensive list of 40 specific civic issues for AI detection
  static const List<String> categories = [
    // Roads & Infrastructure
    'Open Manhole / Uncovered Drain',
    'Large Pothole / Crater',
    'Waterlogged Road / Flooded Street',
    'Caved-in Road / Sinkhole',
    'Broken Pavement / Missing Footpath',
    'Fallen Tree / Large Debris Blocking Road',
    'Damaged / Missing speed breaker',
    'Uprooted or Damaged Traffic Signal/Signboard',
    'Illegal Road Cutting / Unfilled Trench',
    'Construction Material Dumped on Road',

    // Sanitation & Solid Waste Management
    'Large Garbage Dump / Overflowing Dhalao (Bin)',
    'Dead Animal on Street (Dog, Cattle, etc.)',
    'Burning of Garbage / Plastic/ Leaves',
    'Choked Nala / Overflowing Storm Water Drain',
    'Public Defecation / Urination Hotspot',
    'Medical / Bio-hazardous Waste Dumped Openly',
    'Construction Debris (Malba) Dumped Illegally',
    'Uncleaned Public Toilet (Sulabh)',

    // Water Supply & Sewage
    'Major Drinking Water Pipeline Burst / Leakage',
    'Sewage Line Overflow / Manhole Gushing Water',
    'Contaminated / Muddy / Foul Smelling Tap Water',
    'Stagnant Water Pool (Mosquito Breeding)',
    'Illegal Water Connection / Pumping',
    'No Water Supply in Area',

    // Electricity & Streetlights
    'Live / Dangling Electric Wires on Street',
    'Sparking / Smoking Transformer or Pole',
    'Fallen Electricity Pole',
    'Broken / Non-functional Streetlight(s)',
    'Open Junction Box / Exposed Wiring at Ground Level',
    'Streetlights Kept ON During Daytime',

    // Public Safety & Encroachment
    'Illegal Encroachment (Shops/Vendors Blocking Footpath)',
    'Abandoned / Scrap Vehicle Parked on Road',
    'Illegal Hoardings / Banners Blocking View/Signals',
    'Stray Dog Menace / Aggressive Pack',
    'Stray Cattle / Monkeys Causing Nuisance',
    'Unfenced Construction Site / Open Lift Shaft',

    // Environment & Parks
    'Illegal Cutting / Pruning of Trees',
    'Poor Maintenance of Public Park (Broken Swings/Benches)',
    'Industrial Effluent Discharge into Drain/River',
    'Loudspeaker / Noise Pollution Violation',
  ];

  static const List<String> priorities = ['low', 'medium', 'high', 'severe'];

  static const List<String> statuses = [
    'pending',
    'acknowledged',
    'assigned',
    'work_started',
    'completed',
    'closed',
  ];

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'acknowledged':
        return 'Acknowledged';
      case 'assigned':
        return 'Worker Assigned';
      case 'work_started':
        return 'Work Started';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'acknowledged':
        return const Color(0xFF3B82F6);
      case 'assigned':
        return const Color(0xFF6366F1);
      case 'work_started':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFF3B82F6);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'severe':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData categoryIcon(String category) {
    if (category.contains('Road') ||
        category.contains('Pothole') ||
        category.contains('Traffic')) {
      return Icons.construction;
    }
    if (category.contains('Garbage') ||
        category.contains('Waste') ||
        category.contains('Animal')) {
      return Icons.delete_outline;
    }
    if (category.contains('Water') ||
        category.contains('Sewage') ||
        category.contains('Drain')) {
      return Icons.water_drop;
    }
    if (category.contains('Electric') ||
        category.contains('Streetlight') ||
        category.contains('Transformer')) {
      return Icons.bolt;
    }
    if (category.contains('Park') ||
        category.contains('Tree') ||
        category.contains('Environment')) {
      return Icons.park;
    }
    if (category.contains('Sanitation') ||
        category.contains('Toilet') ||
        category.contains('Medical')) {
      return Icons.health_and_safety;
    }
    if (category.contains('Encroachment') ||
        category.contains('Safety') ||
        category.contains('Vehicle')) {
      return Icons.warning_amber;
    }
    return Icons.report_problem;
  }
}
