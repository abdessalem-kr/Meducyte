import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/learn/presentation/utils/lesson_pdf_generator.dart';

class PdfPrintSettingsSheet extends StatefulWidget {
  final LearnLesson lesson;

  const PdfPrintSettingsSheet({
    super.key,
    required this.lesson,
  });

  @override
  State<PdfPrintSettingsSheet> createState() => _PdfPrintSettingsSheetState();
}

class _PdfPrintSettingsSheetState extends State<PdfPrintSettingsSheet> {
  PdfColorTheme _selectedTheme = PdfColorTheme.teal;
  PdfFontSize _selectedFontSize = PdfFontSize.medium;
  PdfTypography _selectedTypography = PdfTypography.sansSerif;
  PdfLayoutColumns _selectedLayoutColumns = PdfLayoutColumns.single;
  
  bool _includeNotes = true;
  bool _includeHighlights = true;
  bool _includeCoverPage = true;
  bool _useGutterMargin = false;
  bool _compactTables = false;

  Color _getThemePrimaryColor(PdfColorTheme theme) {
    switch (theme) {
      case PdfColorTheme.teal:
        return const Color(0xFF0F9F90);
      case PdfColorTheme.navy:
        return const Color(0xFF1E3A8A);
      case PdfColorTheme.emerald:
        return const Color(0xFF059669);
      case PdfColorTheme.amber:
        return const Color(0xFFD97706);
      case PdfColorTheme.charcoal:
        return const Color(0xFF374151);
    }
  }

  String _getThemeName(PdfColorTheme theme) {
    switch (theme) {
      case PdfColorTheme.teal:
        return "Classic Teal";
      case PdfColorTheme.navy:
        return "Royal Navy";
      case PdfColorTheme.emerald:
        return "Emerald Care";
      case PdfColorTheme.amber:
        return "Sunset Amber";
      case PdfColorTheme.charcoal:
        return "Minimal Charcoal";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                Icon(Iconsax.printer, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Export & Print Settings",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Theme Selector
            Text(
              "Color Theme",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: PdfColorTheme.values.map((t) {
                final color = _getThemePrimaryColor(t);
                final isSelected = _selectedTheme == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTheme = t),
                  child: Tooltip(
                    message: _getThemeName(t),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Typography & Columns Row
            Row(
              children: [
                // Typography Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Typography",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChoiceChip(
                            label: "Sans-Serif",
                            isSelected: _selectedTypography == PdfTypography.sansSerif,
                            onTap: () => setState(() => _selectedTypography = PdfTypography.sansSerif),
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: "Serif",
                            isSelected: _selectedTypography == PdfTypography.serif,
                            onTap: () => setState(() => _selectedTypography = PdfTypography.serif),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Layout Columns Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Layout Columns",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChoiceChip(
                            label: "Single",
                            isSelected: _selectedLayoutColumns == PdfLayoutColumns.single,
                            onTap: () => setState(() => _selectedLayoutColumns = PdfLayoutColumns.single),
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: "Double",
                            isSelected: _selectedLayoutColumns == PdfLayoutColumns.double,
                            onTap: () => setState(() => _selectedLayoutColumns = PdfLayoutColumns.double),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Font Size Selector
            Text(
              "Text Font Size",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: PdfFontSize.values.map((fs) {
                final isSelected = _selectedFontSize == fs;
                String label = "";
                double fsSize = 14;
                switch (fs) {
                  case PdfFontSize.small:
                    label = "Small";
                    fsSize = 12;
                    break;
                  case PdfFontSize.medium:
                    label = "Medium";
                    fsSize = 15;
                    break;
                  case PdfFontSize.large:
                    label = "Large";
                    fsSize = 18;
                    break;
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFontSize = fs),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: fsSize,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Premium Toggles List
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary,
                    title: _buildToggleTitle(Iconsax.note, "Include Personal Notes", isDark),
                    value: _includeNotes,
                    onChanged: (val) => setState(() => _includeNotes = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary,
                    title: _buildToggleTitle(Iconsax.edit_2, "Include Text Highlights", isDark),
                    value: _includeHighlights,
                    onChanged: (val) => setState(() => _includeHighlights = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary,
                    title: _buildToggleTitle(Iconsax.document_text, "Include Cover Page", isDark),
                    value: _includeCoverPage,
                    onChanged: (val) => setState(() => _includeCoverPage = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary,
                    title: _buildToggleTitle(Iconsax.book, "Double-Sided Margin (Gutter)", isDark),
                    value: _useGutterMargin,
                    onChanged: (val) => setState(() => _useGutterMargin = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  SwitchListTile.adaptive(
                    activeColor: AppColors.primary,
                    title: _buildToggleTitle(Iconsax.grid_8, "Compact Table Cell Padding", isDark),
                    value: _compactTables,
                    onChanged: (val) => setState(() => _compactTables = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Print Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await LessonPdfGenerator.printLesson(
                    widget.lesson,
                    theme: _selectedTheme,
                    fontSize: _selectedFontSize,
                    typography: _selectedTypography,
                    layoutColumns: _selectedLayoutColumns,
                    includeNotes: _includeNotes,
                    includeHighlights: _includeHighlights,
                    includeCoverPage: _includeCoverPage,
                    useGutterMargin: _useGutterMargin,
                    compactTables: _compactTables,
                  );
                },
                icon: const Icon(Iconsax.printer, color: Colors.white),
                label: Text(
                  "Generate & Print PDF",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTitle(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
