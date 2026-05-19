class CommentModel {
  final String id;
  final String author;
  final String text;
  final DateTime createdAt;
  final bool isEdited;
  final String? parentId;
  final int upvotes;
  final int downvotes;
  final int? myVote;
  final bool isMine;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.isEdited = false,
    this.parentId,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
    this.isMine = false,
    this.replies = const [],
  });

  CommentModel copyWith({
    String? id,
    String? author,
    String? text,
    DateTime? createdAt,
    bool? isEdited,
    String? parentId,
    int? upvotes,
    int? downvotes,
    int? myVote,
    bool? isMine,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
      parentId: parentId ?? this.parentId,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: myVote ?? this.myVote,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isEdited': isEdited,
      'parentId': parentId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'myVote': myVote,
      'isMine': isMine,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      author: json['author'] ?? 'Anonyme',
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      isEdited: json['isEdited'] ?? false,
      parentId: json['parentId']?.toString(),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      myVote: json['myVote'],
      isMine: json['isMine'] ?? json['is_mine'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
                .toList()
          : const [],
    );
  }
}
