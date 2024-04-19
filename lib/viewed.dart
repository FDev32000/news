import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'news_details.dart';

class ViewedTab extends StatefulWidget {
  final List<ViewedNews> viewedNews;

  ViewedTab({required this.viewedNews});

  @override
  // ignore: library_private_types_in_public_api
  _ViewedTabState createState() => _ViewedTabState();
}

class _ViewedTabState extends State<ViewedTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новостной клиент'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0), // add padding to the container
        child: Container(
          decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: widget.viewedNews.length,
            itemBuilder: (context, index) {
              final news = widget.viewedNews[index];
              return ListTile(
                hoverColor: Color.fromARGB(67, 141, 141, 141),
                splashColor: Color.fromARGB(67, 141, 141, 141),
                title: Text(news.title, style: TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('d MMMM yyyy - HH:mm', 'ru_RU').format(DateTime.parse(news.publishedAt)), style: TextStyle(color: Colors.white)),
                // ignore: unnecessary_null_comparison
                leading: news.urlToImage != '' && news.urlToImage.isNotEmpty
                    ? Image.network(news.urlToImage)
                    : Icon(Icons.image),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetail(
                        newsData: news.toMap(),
                      ),
                    ),
                  );
                },
              );
            },
          )
        ),
      ),
    );
  }
}