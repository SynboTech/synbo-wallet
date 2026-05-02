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
