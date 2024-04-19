import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'news_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class NewsList extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  late List<dynamic> data;
  late SharedPreferences prefs;
  late List<ViewedNews> viewedNews;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  String _sortBy = 'popularity';
  DateTime thirtyDaysAgo = DateTime.now();
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    thirtyDaysAgo = DateTime(thirtyDaysAgo.year, thirtyDaysAgo.month, thirtyDaysAgo.day - 30);
    initSharedPreferences();
    fetchData();
  }

  initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    viewedNews = (prefs.getStringList('viewedNews') ?? [])
        .map((jsonString) => ViewedNews.fromMap(json.decode(jsonString)))
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: thirtyDaysAgo,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      fetchData2();
    }
  }

  void _setSortBy(String value) {
    setState(() {
      _sortBy = value;
    });
    fetchData2();
  }

  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    fetchData2();
  }

  fetchData() async {
    http.Response response;
    response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=ru&apiKey=094c2cccfa334b93b0269288ce5ef75b'));
    setState(() {
      data = json.decode(response.body)['articles'];
      _isLoading = false;
    });
  }

  fetchData2() async {
    String url = 'https://newsapi.org/v2/everything?q=$_searchQuery&from=${DateFormat('yyyy-MM-dd').format(_selectedDate)}&sortBy=$_sortBy&apiKey=094c2cccfa334b93b0269288ce5ef75b';
    http.Response response = await http.get(Uri.parse(url));
    setState(() {
      data = json.decode(response.body)['articles'];
    });
  }

  void saveViewedNews(Map<String, dynamic> news) async {
    viewedNews.add(ViewedNews(
      title: news['title'] ?? '',
      author: news['author'] ?? '',
      urlToImage: news['urlToImage'] ?? '',
      description: news['description'] ?? '',
      publishedAt: news['publishedAt'] ?? '',
      url: news['url'] ?? '',
      content: news['content'] ?? '',
    ));
    await prefs.setStringList('viewedNews', viewedNews.map((news) => json.encode(news.toMap())).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новостной клиент'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final query = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Поиск'),
                    content: TextField(
                      onChanged: (value) {
                        _setSearchQuery(value);
                      },
                      decoration: InputDecoration(hintText: 'Введите запрос'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, _searchQuery);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
              if (query != null) {
                _setSearchQuery(query);
              }
            },
          ),
        ],
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
          child: Column(
            children: [
              ListTile(
                title: Text('С какой даты выводить?', style: TextStyle(color: Colors.white)), 
                trailing: Text(DateFormat('d MMMM yyyy').format(_selectedDate), style: TextStyle(color: Colors.white)), 
                onTap: () {
                  _selectDate(context);
                },
              ),
              ListTile(
                title: Text('Сортировать по', style: TextStyle(color: Colors.white)), 
                trailing: DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (String? newValue) {
                    _setSortBy(newValue!);
                  },
                  items: <String>['popularity', 'relevancy']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)), // set text color to white
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index]['title'] ?? 'Нет заголовка', style: TextStyle(color: Colors.white)), // set text color to white
                        subtitle: Text(DateFormat('d MMMM yyyy - HH:mm', 'ru_RU').format(DateTime.parse(data[index]['publishedAt'])) ?? 'Дата неизвестна' + '-' + data[index]['author'] ?? 'Автор неизвестен', style: TextStyle(color: Colors.white)), // set text color to white
                        leading: data[index]['urlToImage'] != null && data[index]['urlToImage'].isNotEmpty
                            ? Image.network(data[index]['urlToImage'])
                            : Icon(Icons.image),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetail(
                                newsData: data[index],
                              ),
                            ),
                          );
                          saveViewedNews(data[index]);
                        },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
