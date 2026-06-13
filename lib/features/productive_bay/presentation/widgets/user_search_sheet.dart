import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:flutter/services.dart';

class UserSearchSheet extends ConsumerStatefulWidget {
  final String groupId;
  final List<String> memberIds;

  const UserSearchSheet({super.key, required this.groupId, required this.memberIds});

  @override
  ConsumerState<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<UserSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _results = [];
  final Set<User> _selectedUsers = {};
  bool _isLoading = false;
  bool _isInviting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repository = ref.read(studyGroupRepositoryProvider);
      // Query "a" to populate some initial default suggestions
      final users = await (repository as dynamic).searchUsers("a");
      if (mounted) {
        setState(() => _results = users);
      }
    } catch (_) {
      // Quiet fail to keep UX clean
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadSuggestions();
      return;
    }
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
      final users = await (repository as dynamic).searchUsers(query);
      if (mounted) {
        setState(() => _results = users);
      }
    } catch (e) {
      setState(() => _error = context.l10n.searchError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendBatchInvitations() async {
    setState(() => _isInviting = true);
    try {
      final repository = ref.read(studyGroupRepositoryProvider);
      for (final user in _selectedUsers) {
        await repository.inviteFriend(widget.groupId, user.id.toString());
      }
      if (mounted) {
        Navigator.pop(context);
        AppSnackBars.success(
          context,
          "${_selectedUsers.length} invitation(s) envoyée(s) !",
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(
          context,
          context.l10n.invitationError,
        );
      }
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.inviteFriend,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Field
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
          const SizedBox(height: 16),

          // Selected Chips
          if (_selectedUsers.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: _selectedUsers.map((u) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InputChip(
                      label: Text(u.name, style: const TextStyle(fontSize: 12)),
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          u.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onDeleted: () {
                        setState(() => _selectedUsers.remove(u));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.length >= 2
                                  ? context.l10n.noUsersFound
                                  : "Recherchez pour inviter des membres",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = _results[index];
                              final isSelected = _selectedUsers.any((u) => u.id == user.id);
                              final isMember = widget.memberIds.contains(user.id.toString());
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(user.name[0].toUpperCase()),
                                ),
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                trailing: isMember
                                    ? const Text(
                                        "Déjà membre",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            if (val == true) {
                                              _selectedUsers.add(user);
                                            } else {
                                              _selectedUsers.removeWhere((u) => u.id == user.id);
                                            }
                                          });
                                        },
                                      ),
                              );
                            },
                          ),
          ),

          // Send Batch Button
          if (_selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isInviting ? null : _sendBatchInvitations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isInviting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Inviter ${_selectedUsers.length} ami(s)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
