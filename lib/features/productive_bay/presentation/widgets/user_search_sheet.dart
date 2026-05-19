import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:flutter/services.dart';

class UserSearchSheet extends ConsumerStatefulWidget {
  final String groupId;

  const UserSearchSheet({super.key, required this.groupId});

  @override
  ConsumerState<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<UserSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(studyGroupRepositoryProvider);
      //We need to add searchUsers to the repository interface or use a generic client
      //For now,I'll assume we add it to StudyGroupRepository for convenience
      // (Wait,I should check if I should add it there or create a new provider)
      //I'll add it to ApiStudyGroupRepository.

      //Since I haven't updated the repository interface yet,I'll use a placeholder call
      //and update the repository in the next step.
      final users = await (repository as dynamic).searchUsers(query);
      setState(() => _results = users);
    } catch (e) {
      setState(() => _error = context.l10n.searchError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.inviteFriend,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: context.l10n.searchByNameOrEmail,
              prefixIcon: const Icon(Iconsax.search_normal),
              filled: true,
              fillColor: isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else if (_results.isEmpty && _searchController.text.length >= 2)
            Center(child: Text(context.l10n.noUsersFound))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        try {
                          await ref
                              .read(studyGroupRepositoryProvider)
                              .inviteFriend(widget.groupId, user.id.toString());
                          if (context.mounted) {
                            Navigator.pop(context);
                            AppSnackBars.success(
                              context,
                              context.l10n.invitationSent,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackBars.error(
                              context,
                              context.l10n.invitationError,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(context.l10n.invite),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
