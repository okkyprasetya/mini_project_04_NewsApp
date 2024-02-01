import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getwidget/getwidget.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async{
  await Hive.initFlutter();
  await Hive.openBox('favoriteNewsBox');
  runApp(const MyApp());
}

class News {
  final String title;
  final String description;
  final String pictURL;
  final String url;

  News(
      {required this.title,
      required this.pictURL,
      required this.description,
      required this.url});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController controller;
  late Box _favoriteNewsBox;
  Set<int> favoriteNewsIndices = Set<int>();
  late Future<List<News>> newsData;

  Future<List<News>> fetchNewsData() async {
    var response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=keyword&apiKey=4b397c0b925c48649a61b00c6ab69622'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<dynamic> articles = jsonData['articles'];

      List<News> newsList = articles.map((article) {
        return News(
            title: article['title'] ?? 'default title',
            description: article['description'] ?? 'default description',
            pictURL: article['urlToImage'] ?? 'default image',
            url: article['url'] ?? 'default url');
      }).toList();
      return newsList;
    } else {
      throw Exception(
          'Failed to load news, status code: ${response.statusCode}');
    }
  }


  @override
  void initState() {
    super.initState();
    newsData = fetchNewsData();
    _favoriteNewsBox = Hive.box('favoriteNewsBox');
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteNewsBox.containsKey(index)) {
        _favoriteNewsBox.delete(index);
      } else {
        _favoriteNewsBox.put(index, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('BSI News'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.home),
                child: Text('Home'),
              ),
              Tab(
                icon: Icon(Icons.star),
                child: Text('Favorite'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: FutureBuilder<List<News>>(
                future: newsData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        News news = snapshot.data![index];
                        bool isFavorite = favoriteNewsIndices.contains(index);
                        return Column(
                          children: [
                            GFCard(
                              elevation: 5.0,
                              // content: Image.network(news.pictURL),
                              title: GFListTile(
                                title: Stack(children: [
                                  Image.network(news.pictURL, fit: BoxFit.fill),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: GestureDetector(
                                      onTap: () {
                                        _toggleFavorite(index);
                                        setState(() {
                                          if (isFavorite) {
                                            favoriteNewsIndices.remove(index);
                                          } else {
                                            favoriteNewsIndices.add(index);
                                          }
                                        });
                                      },
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.amber,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                ]),
                                subTitle: Text(
                                  news.title,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                description: Text(
                                  news.description,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              buttonBar: GFButtonBar(children: <Widget>[
                                GFButton(
                                  onPressed: () {

                                  },
                                  text: 'Read more',
                                )
                              ]),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Center(
              child: FutureBuilder<List<News>>(
                future: newsData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    List<int> favoriteIndices = _favoriteNewsBox.keys.cast<int>().toList();
                    if (favoriteIndices.isEmpty) {
                      return Center(
                        child: Text('No favorites yet.'),
                      );
                    }
                    else{
                    return ListView.builder(
                      itemCount: favoriteIndices.length,
                      itemBuilder: (context, index) {
                        int favoriteIndex = favoriteIndices[index];
                        News news = snapshot.data![favoriteIndex];
                        return Column(
                          children: [
                            Card(
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Container(
                                        child: Text(
                                          news.title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),
                                        ),
                                        margin: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => NewsWebView(url: news.url)),
                                  );
                                }, child: Icon(Icons.arrow_circle_right)),
                              ),
                            ),

                          ],
                        );
                      },
                    );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewsWebView extends StatefulWidget {
  final String url;

  NewsWebView({required this.url});

  @override
  _NewsWebViewState createState() => _NewsWebViewState();
}

class _NewsWebViewState extends State<NewsWebView> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Details'),
      ),
      body: WebViewWidget(controller: controller)
    );
  }
}