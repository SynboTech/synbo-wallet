import 'package:flutter/material.dart';

/// 广场帖子数据模型
class SquarePost {
  final String id;
  final String author;
  final String avatar;
  final Color color;
  final DateTime timestamp;
  final String content;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;

  SquarePost({
    required this.id,
    required this.author,
    required this.avatar,
    required this.color,
    required this.timestamp,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
  });

  String get time {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class SquareAuthorProfile {
  const SquareAuthorProfile({
    required this.name,
    required this.handle,
    required this.avatar,
    required this.color,
    required this.bio,
    required this.focus,
    required this.region,
    required this.joined,
    required this.followers,
    required this.accuracy,
    required this.postsCount,
    required this.insights,
    required this.posts,
  });

  final String name;
  final String handle;
  final String avatar;
  final Color color;
  final String bio;
  final String focus;
  final String region;
  final String joined;
  final String followers;
  final String accuracy;
  final String postsCount;
  final List<AuthorInsight> insights;
  final List<AuthorPost> posts;

  factory SquareAuthorProfile.fromPost(SquarePost post) {
    return SquareAuthorProfile(
      name: post.author,
      handle: post.author.toLowerCase().replaceAll(' ', '_'),
      avatar: post.avatar,
      color: post.color,
      bio:
          'Market research desk tracking crypto cycles, liquidity flows, and high-conviction breakout setups.',
      focus: 'BTC / Macro / Liquidity',
      region: 'Global',
      joined: 'Joined 2024',
      followers: '28.4K',
      accuracy: '76%',
      postsCount: '418',
      insights: const [
        AuthorInsight(
          title: 'BTC Support Zone',
          description:
              'Watching the \$95K support band. A clean reclaim above \$100K may trigger continuation.',
          icon: Icons.show_chart_rounded,
          color: Colors.blue,
        ),
        AuthorInsight(
          title: 'Liquidity Signal',
          description:
              'Stablecoin inflows are improving while exchange reserves continue to trend lower.',
          icon: Icons.waterfall_chart_rounded,
          color: Colors.teal,
        ),
        AuthorInsight(
          title: 'Risk Window',
          description:
              'Volatility may expand around macro data releases. Position size remains critical.',
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
      ],
      posts: [
        AuthorPost(
          tag: 'BTC',
          time: post.time,
          content: post.content,
          likes: post.likes.toString(),
          comments: post.comments.toString(),
          shares: post.shares.toString(),
        ),
        const AuthorPost(
          tag: 'Market',
          time: '5h ago',
          content:
              'Spot demand remains constructive. I want to see volume confirm before calling a breakout.',
          likes: '186',
          comments: '31',
          shares: '9',
        ),
        const AuthorPost(
          tag: 'Macro',
          time: '1d ago',
          content:
              'Risk assets are responding to softer yields. Crypto beta may stay bid if liquidity improves.',
          likes: '342',
          comments: '58',
          shares: '21',
        ),
      ],
    );
  }
}

class AuthorInsight {
  const AuthorInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class AuthorPost {
  const AuthorPost({
    required this.tag,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  final String tag;
  final String time;
  final String content;
  final String likes;
  final String comments;
  final String shares;
}
