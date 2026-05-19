import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class QuizSaveBottomSheet extends ConsumerStatefulWidget {
  final int questionId;

  const QuizSaveBottomSheet({super.key, required this.questionId});

  @override
  ConsumerState<QuizSaveBottomSheet> createState() =>
      _QuizSaveBottomSheetState();
}

class _QuizSaveBottomSheetState extends ConsumerState<QuizSaveBottomSheet> {
  int? selectedFolderId;
  bool isSaving = false;
  bool isCreating = false;
  bool isSuccess = false;

  final TextEditingController _newFolderController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedColor = '#f44336'; //Default red

  final List<String> _presetColors = [
    '#f44336', //Red
    '#e91e63', //Pink
    '#9c27b0', //Purple
    '#673ab7', //Deep Purple
    '#3f51b5', //Indigo
    '#2196f3', //Blue
    '#00bcd4', //Cyan
    '#009688', //Teal
    '#4caf50', //Green
    '#ffeb3b', //Yellow
    '#ff9800', //Orange
    '#795548', //Brown
  ];

  @override
  void dispose() {
    _newFolderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() => isSaving = true);
    try {
      final repo = ref.read(quizRepositoryProvider);
      await repo.toggleSaveQuestion(
        widget.questionId,
        folderId: selectedFolderId,
      );

      if (mounted) {
        //Refresh saved questions list
        ref.invalidate(mySavedQuestionsProvider);

        setState(() {
          isSuccess = true;
          isSaving = false;
        });
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        AppSnackBars.error(context, 'Failed to save: $e');
      }
    }
  }

  void _createNewFolder() async {
    final name = _newFolderController.text.trim();
    if (name.isEmpty) return;

    setState(() => isSaving = true);
    try {
      final repo = ref.read(quizRepositoryProvider);
      final newFolder = await repo.createQuestionFolder(
        name,
        color: _selectedColor,
      );

      //Refresh folders list
      ref.invalidate(myQuestionFoldersProvider);

      if (mounted) {
        setState(() {
          selectedFolderId = newFolder.id;
          isCreating = false;
          isSaving = false;
          _newFolderController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        AppSnackBars.error(context, 'Failed to create folder: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    final foldersAsync = ref.watch(myQuestionFoldersProvider);

    if (isSuccess) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.quizSaved,
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: quizTheme.secondaryTextColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Iconsax.folder_add, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.saveToCollection,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 24),
          //Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchCollections,
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: quizTheme.secondaryTextColor.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.myCollections,
            style: TextStyle(
              color: quizTheme.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          foldersAsync.when(
            data: (folders) {
              final filteredFolders = folders
                  .where(
                    (f) => f.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filteredFolders.isEmpty && _searchQuery.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No folders yet.Create your first one!',
                      style: TextStyle(color: quizTheme.secondaryTextColor),
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredFolders.length,
                  itemBuilder: (context, index) {
                    final folder = filteredFolders[index];
                    final isSelected = selectedFolderId == folder.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () =>
                            setState(() => selectedFolderId = folder.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withOpacity(0.1)
                                : quizTheme.secondaryTextColor.withOpacity(
                                    0.05,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Iconsax.folder_25 : Iconsax.folder,
                                color: isSelected
                                    ? primaryColor
                                    : quizTheme.secondaryTextColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                folder.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? quizTheme.primaryTextColor
                                      : quizTheme.secondaryTextColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Iconsax.tick_circle5,
                                  color: primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error loading folders: $e')),
          ),
          const SizedBox(height: 12),
          if (isCreating)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newFolderController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: l10n.createCollection,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => _createNewFolder(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _createNewFolder,
                      icon: Icon(Iconsax.add_square5, color: primaryColor),
                    ),
                    IconButton(
                      onPressed: () => setState(() => isCreating = false),
                      icon: const Icon(Iconsax.close_circle),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetColors.length,
                    itemBuilder: (context, index) {
                      final colorHex = _presetColors[index];
                      final color = Color(
                        int.parse(colorHex.replaceFirst('#', '0xFF')),
                      );
                      final isSelected = _selectedColor == colorHex;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = colorHex),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: () => setState(() => isCreating = true),
              icon: const Icon(Iconsax.add_circle, size: 20),
              label: Text(l10n.createCollection),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                alignment: Alignment.centerLeft,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: (selectedFolderId != null && !isSaving)
                ? _handleSave
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: quizTheme.secondaryTextColor.withOpacity(
                0.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.saveChanges,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
