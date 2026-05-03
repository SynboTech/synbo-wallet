import 'package:flutter/material.dart';

/// 社群页面 — 群组和好友列表
class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  late _ClubItem _selectedClub;

  final _clubs = [
    _ClubItem(
      name: '国库基金CLUB',
      avatar: '🏦',
      lastMessage: 'Treasury fund update is ready',
      timestamp: '18:08',
      unreadCount: 0,
      isPublic: true,
    ),
    _ClubItem(
      name: '天空飘来几个字-刀乐',
      avatar: '👥',
      lastMessage: 'BlueEmber2EF joined the group',
      timestamp: '17:50',
      unreadCount: 1,
      isPublic: true,
    ),
    _ClubItem(
      name: '社区核心建设',
      avatar: '🟢',
      lastMessage: '红红: [Picture]',
      timestamp: '昨天 11:21',
      unreadCount: 0,
      isPublic: true,
    ),
    _ClubItem(
      name: 'g',
      avatar: '🔵',
      lastMessage: 'You created a group',
      timestamp: 'Wednesday 15:57',
      unreadCount: 0,
      isPublic: false,
    ),
    _ClubItem(
      name: '小分队',
      avatar: '🟦',
      lastMessage: 'You created a group',
      timestamp: '04月02 11:31',
      unreadCount: 0,
      isPublic: false,
    ),
  ];

  final _friends = [
    _FriendItem(
      name: 'Noti Annie',
      avatar: '💙',
      status: 'q',
      lastSeen: '03月29 18:38',
    ),
    _FriendItem(
      name: 'Crypto King',
      avatar: '👑',
      status: 'online',
      lastSeen: 'now',
    ),
    _FriendItem(
      name: 'DeFi Master',
      avatar: '🌟',
      status: 'idle',
      lastSeen: '2 hours ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedClub = _clubs.first;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _tabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 12,
        title: _ClubTitleSelector(
          selectedClub: _selectedClub,
          clubs: _clubs,
          onSelected: (club) => setState(() => _selectedClub = club),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
            tooltip: 'Add contact',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
            tooltip: 'More options',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('全部'),
                  if (_tabIndex == 0)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded, size: 18),
                  SizedBox(width: 4),
                  Text('公共群'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 18),
                  SizedBox(width: 4),
                  Text('私密群'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 全部
          _buildAllTab(colorScheme, isDark),
          // 公共群
          _buildPublicClubsTab(colorScheme, isDark),
          // 私密群
          _buildPrivateClubsTab(colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildAllTab(ColorScheme colorScheme, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '群组',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildClubItem(_clubs[index], colorScheme, isDark),
            childCount: _clubs.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              '好友',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildFriendItem(_friends[index], colorScheme, isDark),
            childCount: _friends.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicClubsTab(ColorScheme colorScheme, bool isDark) {
    final publicClubs = _clubs.where((c) => c.isPublic).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: publicClubs.length,
      itemBuilder: (context, index) =>
          _buildClubItem(publicClubs[index], colorScheme, isDark),
    );
  }

  Widget _buildPrivateClubsTab(ColorScheme colorScheme, bool isDark) {
    final privateClubs = _clubs.where((c) => !c.isPublic).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: privateClubs.length,
      itemBuilder: (context, index) =>
          _buildClubItem(privateClubs[index], colorScheme, isDark),
    );
  }

  Widget _buildClubItem(_ClubItem club, ColorScheme colorScheme, bool isDark) {
    final selected = club.name == _selectedClub.name;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedClub = club),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(color: colorScheme.primary, width: 1.4)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        club.avatar,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  if (club.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            club.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!club.isPublic)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF6F7781),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            club.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                        Text(
                          club.timestamp,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: club.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    _FriendItem friend,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    friend.avatar,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            friend.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            friend.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend.lastSeen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubTitleSelector extends StatelessWidget {
  const _ClubTitleSelector({
    required this.selectedClub,
    required this.clubs,
    required this.onSelected,
  });

  final _ClubItem selectedClub;
  final List<_ClubItem> clubs;
  final ValueChanged<_ClubItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_ClubItem>(
      tooltip: 'Switch club',
      initialValue: selectedClub,
      onSelected: onSelected,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => clubs
          .map(
            (club) => PopupMenuItem<_ClubItem>(
              value: club,
              child: Row(
                children: [
                  Text(club.avatar, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: club.name == selectedClub.name
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (club.name == selectedClub.name)
                    Icon(
                      Icons.check_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selectedClub.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
          ],
        ),
      ),
    );
  }
}

class _ClubItem {
  final String name;
  final String avatar;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isPublic;

  _ClubItem({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isPublic,
  });
}

class _FriendItem {
  final String name;
  final String avatar;
  final String status;
  final String lastSeen;

  _FriendItem({
    required this.name,
    required this.avatar,
    required this.status,
    required this.lastSeen,
  });
}
