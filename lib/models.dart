class ViewedNews {
  String title;
  String author;
  String urlToImage;
  String description;
  String publishedAt;
  String url;
  String content;

  ViewedNews({
    required this.title,
    required this.author,
    required this.urlToImage,
    required this.description,
    required this.publishedAt,
    required this.url,
    required this.content,
  });

  factory ViewedNews.fromMap(Map<String, dynamic> json) => ViewedNews(
    title: json["title"],
    author: json["author"],
    urlToImage: json["urlToImage"],
    description: json["description"],
    publishedAt: json["publishedAt"],
    url: json["url"],
    content: json["content"],
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "author": author,
    "urlToImage": urlToImage,
    "description": description,
    "publishedAt": publishedAt,
    "url": url,
    "content": content,
  };
}

class FavoriteNews {
  final String title;
  final String author;
  final String urlToImage;
  final String description;
  final String publishedAt;
  final String url;
  final String content;

  FavoriteNews({
    required this.title,
    required this.author,
    required this.urlToImage,
    required this.description,
    required this.publishedAt,
    required this.url,
    required this.content,
  });

  factory FavoriteNews.fromMap(Map<String, dynamic> json) => FavoriteNews(
    title: json["title"],
    author: json["author"],
    urlToImage: json["urlToImage"],
    description: json["description"],
    publishedAt: json["publishedAt"],
    url: json["url"],
    content: json["content"],
  );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'urlToImage': urlToImage,
      'description': description,
      'publishedAt': publishedAt,
      'url': url,
      'content': content,
    };
  }
}