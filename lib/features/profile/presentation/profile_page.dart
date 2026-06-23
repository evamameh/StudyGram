import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:pulso/core/providers/supabase_provider.dart';
import 'package:pulso/features/auth/providers/auth_providers.dart';
import 'package:pulso/features/studygram/studygram_data.dart';
import 'package:pulso/features/studygram/studygram_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _tab = 0;

  Future<void> _changeProfilePicture(
      String currentName, String currentBio) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null || file!.bytes!.isEmpty) return;

    final avatarBytes = file.bytes!;
    ref.read(studygramStoreProvider).updateCurrentUser(
          name: currentName,
          bio: currentBio,
          avatarBytes: avatarBytes,
        );
    try {
      await _trySyncProfileToSupabase(currentName, currentBio, avatarBytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Picture updated on this device. Supabase sync failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _editProfile(String currentName, String currentBio) async {
    final nameCtrl = TextEditingController(text: currentName);
    final bioCtrl = TextEditingController(text: currentBio);
    List<int>? avatarBytes =
        ref.read(studygramStoreProvider).currentUser.avatarBytes;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickAvatar() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                withData: true,
              );
              final file = result?.files.single;
              if (file?.bytes == null || file!.bytes!.isEmpty) return;
              setDialogState(() => avatarBytes = file.bytes);
            }

            return AlertDialog(
              title: const Text('Edit profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: pickAvatar,
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFFFD7E4),
                        backgroundImage: avatarBytes == null
                            ? null
                            : MemoryImage(Uint8List.fromList(avatarBytes!)),
                        child: avatarBytes == null
                            ? const Icon(
                                Icons.add_a_photo_rounded,
                                color: StudygramColors.primary,
                                size: 34,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
      );
      if (saved != true) return;

      final name = nameCtrl.text.trim();
      final bio = bioCtrl.text.trim();
      if (name.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name is required.')),
        );
        return;
      }

      ref.read(studygramStoreProvider).updateCurrentUser(
            name: name,
            bio: bio,
            avatarBytes: avatarBytes,
          );
      await _trySyncProfileToSupabase(name, bio, avatarBytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } finally {
      nameCtrl.dispose();
      bioCtrl.dispose();
    }
  }

  Future<void> _trySyncProfileToSupabase(
    String name,
    String bio,
    List<int>? avatarBytes,
  ) async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;
    String? avatarUrl;
    if (avatarBytes != null) {
      final objectPath =
          '${user.id}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      await client.storage.from('avatars').uploadBinary(
            objectPath,
            Uint8List.fromList(avatarBytes),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      avatarUrl = client.storage.from('avatars').getPublicUrl(objectPath);
    }
    await client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': name,
          'avatar_url': avatarUrl,
        }..removeWhere((_, value) => value == null),
      ),
    );
    await client.from('profiles').upsert(
      {
        'id': user.id,
        'username': name,
        'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      onConflict: 'id',
    );
  }

  Future<void> _showSettings() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text(
          'Account settings are ready for the demo. Use Logout to switch accounts.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(supabaseClientProvider).auth.currentUser;
    final store = ref.watch(studygramStoreProvider);
    final editedProfile = store.currentUser;
    final fullName = editedProfile.name == 'StudyGram Student'
        ? _displayName(user?.userMetadata, user?.email)
        : editedProfile.name;
    final bio = editedProfile.bio;
    final myPosts = store.posts.where((post) => post.isMine).toList();
    final visiblePosts = _tab == 0 ? myPosts : store.savedPosts;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: pinkPageGradient()),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              StudygramHeader(
                title: 'Profile',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/search'),
                      icon: const Icon(Icons.search_rounded),
                    ),
                    IconButton(
                      tooltip: 'Logout',
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: softCardDecoration(),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _changeProfilePicture(fullName, bio),
                        customBorder: const CircleBorder(),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFFFD7E4),
                              backgroundImage: editedProfile.avatarBytes == null
                                  ? null
                                  : MemoryImage(
                                      Uint8List.fromList(
                                        editedProfile.avatarBytes!,
                                      ),
                                    ),
                              child: editedProfile.avatarBytes == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 62,
                                      color: StudygramColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: StudygramColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _changeProfilePicture(fullName, bio),
                        icon: const Icon(Icons.image_rounded),
                        label: Text(
                          editedProfile.avatarBytes == null
                              ? 'Add profile picture'
                              : 'Change profile picture',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: StudygramColors.darkText,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          _Badge(label: 'Student'),
                          _Badge(label: 'Note Sharer'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: StudygramColors.secondaryText,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(label: 'Posts', value: '${myPosts.length}'),
                          const _Stat(label: 'Followers', value: '128'),
                          _Stat(
                            label: 'Saved',
                            value: '${store.savedPosts.length}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _editProfile(fullName, bio),
                              style: FilledButton.styleFrom(
                                backgroundColor: StudygramColors.primary,
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _showSettings,
                              child: const Text('Settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Notes')),
                    ButtonSegment(value: 1, label: Text('Saved')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (value) =>
                      setState(() => _tab = value.first),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: visiblePosts.isEmpty
                    ? Container(
                        decoration: softCardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'No posts here yet.',
                          style: TextStyle(
                            color: StudygramColors.secondaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Column(
                        children: visiblePosts
                            .map((post) => _ProfilePostCard(post: post))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StudygramBottomNav(currentIndex: 3),
    );
  }

  String _displayName(Map<String, dynamic>? metadata, String? email) {
    final fullName = metadata?['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    final firstName = metadata?['first_name'] as String?;
    final lastName = metadata?['last_name'] as String?;
    final joined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (joined.isNotEmpty) return joined;
    return email?.split('@').first ?? 'StudyGram Student';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFFFD7E4),
      labelStyle: const TextStyle(
        color: StudygramColors.darkPink,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide.none,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: StudygramColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: StudygramColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfilePostCard extends ConsumerWidget {
  const _ProfilePostCard({required this.post});

  final StudyPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> confirmDelete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This post and its comments will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      ref.read(studygramStoreProvider).deletePost(post.id);
    }

    return InkWell(
      onTap: () => context.push('/comments/${post.id}'),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: softCardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudyMaterialPreview(
              icon: post.thumbnailIcon,
              materialName: post.materialName,
              materialBytes: post.materialBytes,
              materialType: post.materialType,
              height: 150,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(post.subject),
                  backgroundColor: const Color(0xFFFFD7E4),
                  labelStyle: const TextStyle(
                    color: StudygramColors.darkPink,
                    fontWeight: FontWeight.w800,
                  ),
                  side: BorderSide.none,
                ),
                const Spacer(),
                if (post.isMine)
                  IconButton(
                    onPressed: confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: StudygramColors.darkPink,
                    tooltip: 'Delete post',
                  ),
              ],
            ),
            Text(
              post.title,
              style: const TextStyle(
                color: StudygramColors.darkText,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StudygramColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite_border_rounded, size: 18),
                const SizedBox(width: 4),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                const Icon(Icons.mode_comment_outlined, size: 18),
                const SizedBox(width: 4),
                Text('${post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
