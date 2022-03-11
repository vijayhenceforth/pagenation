import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Kindacode.com',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We will fetch data from this Rest api
  final _baseUrl2 = 'http://139.59.47.49:4004/api/posts';
  List<String> drop = ['Update', 'Delete'];

  // At the beginning, we fetch the first 20 posts
  int _page = 20;
  int _limit = 20;

  // There is next page or not
  bool _hasNextPage = true;

  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  // This holds the posts fetched from the server
  List _posts = [];

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    final res = await http
        .get(Uri.parse('http://139.59.47.49:4004/api/posts?limit=10&start=1'));
    setState(() {
      _posts = json.decode(res.body);
    });

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  // This function will be triggered whenver the user scroll
  // to near the bottom of the list view
  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });

      _page += 1; // Increase _page by 1


          try {
      final res =
                await http.get(Uri.parse("$_baseUrl2?_page=$_page&_limit=$_limit"));
            final List fetchedPosts = json.decode(res.body);
            if (fetchedPosts.length > 0) {
              setState(() {
                _posts.addAll(fetchedPosts);
              });
            } else {
              // This means there is no more data
              // and therefore, we will not send another GET request
              setState(() {
                _hasNextPage = false;
              });
            }
          } catch (err) {                                                            
           
          }
             

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  // The controller for the ListView
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = new ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kindacode.com'),
      ),
      body: _isFirstLoadRunning
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: _controller,
                      itemCount: _posts.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 400,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 18),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(20),
                                              child: CircleAvatar(
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                    _posts[index]
                                                        ['background']),
                                              ),
                                            ),
                                            Text(
                                              _posts[index]['post'],
                                              style: TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: DropdownButton(
                                            elevation: 0,
                                            underline: Container(),
                                            alignment: Alignment.topRight,
                                            icon: const Icon(Icons.more_horiz),
                                            items: drop.map((String items) {
                                              return DropdownMenuItem(
                                                value: items,
                                                child: Text(items),
                                              );
                                            }).toList(),
                                            onChanged: (String? dropvalue) {
                                              setState(() {
                                                if (dropvalue == "Update") {
                                                } else if (dropvalue ==
                                                    "Delete") {
                                                } else {}
                                                ;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Image(
                                          image: NetworkImage(
                                              _posts[index]['background']),
                                          fit: BoxFit.cover),
                                    ),
                                    // When nothing else to load
                                  ],
                                ),
                              )),
                        );
                      }),
                ),

                // when the _loadMore function is running
                if (_isLoadMoreRunning == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                if (_hasNextPage == false)
                  Container(
                    padding: const EdgeInsets.only(top: 30, bottom: 40),
                    color: Colors.amber,
                    child: Center(
                      child: Text('You have fetched all of the content'),
                    ),
                  ),
              ],
            ),
    );
  }
}
