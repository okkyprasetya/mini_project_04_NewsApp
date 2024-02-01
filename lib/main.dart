import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getwidget/getwidget.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}


class News {
  final String title;
  final String description;
  final String pictURL;
  final String url;

  News({ required this.title, required this.pictURL, required this.description,required this.url});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  Future <List<News>> fetchNewsData() async {
    var response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=keyword&apiKey=4b397c0b925c48649a61b00c6ab69622'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<dynamic> articles = jsonData['articles'];

      List<News> newsList = articles.map(
              (article) {
            return News(
                title: article['title'] ?? 'default title',
                description: article['description'] ?? 'default description',
                pictURL: article['urlToImage'] ?? 'default image',
                url: article['url'] ?? 'default url'
            );
          }
      ).toList();
      return newsList;
    }
    else {
      throw Exception('Failed to load news, status code: ${response.statusCode}');
    }
  }

  late Future<List<News>> newsData;
  @override
  void initState() {
    super.initState();
    newsData = fetchNewsData();
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
            FutureBuilder<List<News>>(
              future: newsData,
              builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                  }
                  else{
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        News news = snapshot.data![index];
                        return Column(
                          children: [
                            GFCard(
                              elevation: 5.0,
                              // content: Image.network(news.pictURL),
                              title: GFListTile(
                                title: Text(news.title,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                                ),
                                ),
                                description:
                                Text(news.description, style: TextStyle(fontSize: 16),),
                              ),
                              buttonBar: GFButtonBar(
                                  children: <Widget> [
                                    GFButton(
                                        onPressed: (){

                                        }, text: 'Read more',
                                    )
                                  ]
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }

              },

            )
          ],
        ),
      ),
    );
  }
}
