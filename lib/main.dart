import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
        body: const TabBarView(
          children: <Widget>[
            Center(
              child:
              Column(
                children: [
                  Card(
                    elevation: 5.0,
                      margin: EdgeInsets.all(16.0),
                      child: ListTile(
                          title: Text('Berita1'),
                          subtitle: Text('description'),
                          trailing: Icon(Icons.favorite),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Text("Ini hujan"),
            ),
          ],
        ),
      ),
    );
  }
}
