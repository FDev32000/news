import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';

class NewsDetail extends StatefulWidget {
  final Map<String, dynamic> newsData;

  NewsDetail({required this.newsData});

  @override
  // ignore: library_private_types_in_public_api
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  late List<dynamic> data;
  late SharedPreferences prefs;
  List<FavoriteNews> favoriteNews = [];

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    favoriteNews = (prefs.getStringList('favoriteNews') ?? [])
        .map((jsonString) => FavoriteNews.fromMap(json.decode(jsonString)))
        .toList();
    setState(() {});
  }

  void saveFavoriteNews(Map<String, dynamic> news) async {
    favoriteNews.add(FavoriteNews(
      title: news['title'] ?? '',
      author: news['author'] ?? '',
      urlToImage: news['urlToImage'] ?? '',
      description: news['description'] ?? '',
      publishedAt: news['publishedAt'] ?? '',
      url: news['url'] ?? '',
      content: news['content'] ?? '',
    ));
    await prefs.setStringList('favoriteNews', favoriteNews.map((news) => json.encode(news.toMap())).toList());
    setState(() {});
  }

  bool isFavorite(Map<String, dynamic> news) {
    return favoriteNews.any((favorite) => favorite.url == news['url']);
  }

  void toggleFavorite(Map<String, dynamic> news) {
    if (isFavorite(news)) {
      favoriteNews.removeWhere((favorite) => favorite.url == news['url']);
      prefs.setStringList('favoriteNews', favoriteNews.map((news) => json.encode(news.toMap())).toList());
    } else {
      saveFavoriteNews(news);
    }
    setState(() {});
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(widget.newsData['publishedAt']);
    String formattedDate = DateFormat('d MMMM yyyy - HH:mm', 'ru_RU').format(parsedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Новость'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite(widget.newsData) ? Icons.favorite : Icons.favorite_border,
              color: isFavorite(widget.newsData) ? Colors.red : Colors.black,
            ),
            onPressed: () {
              toggleFavorite(widget.newsData);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/back.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.newsData['title'] ?? 'Нет заголовка',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Издатель: ${widget.newsData['author'] ?? 'Неизвестный автор'}',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    widget.newsData['urlToImage'] != null && widget.newsData['urlToImage'].isNotEmpty
                    ? Image.network(widget.newsData['urlToImage'])
                    : Container(),
                    SizedBox(height: 10),
                    Text(
                      'Описание: ${widget.newsData['description'] ?? 'Нет описания'}',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Дата публикации: $formattedDate',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        launchURL(Uri.encodeFull(widget.newsData['url']));
                      },
                      child: Text('Читать полностью'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${widget.newsData['content'] ?? ''}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                 ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}