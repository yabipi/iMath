class TreeNode {
  String id;
  String title;
  List<TreeNode> children;
  bool isExpanded;

  TreeNode({
    required this.id,
    required this.title,
    this.children = const [],
    this.isExpanded = false,
  });

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      id: json['id'] as String,
      title: json['title'] as String,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => TreeNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}
