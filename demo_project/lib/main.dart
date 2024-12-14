// Import necessary Flutter packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(),
      },
    );
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash_image.png',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void fetchMovies() async {
    final response =
        await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/search');
          }
        },
      ),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Featured Movies',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index]['show'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsScreen(movie: movie),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            width: 120,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      movie['image'] != null
                                          ? movie['image']['medium']
                                          : '',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  movie['name'] ?? 'No Title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'All Movies',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index]['show'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(movie: movie),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  movie['image'] != null
                                      ? movie['image']['medium']
                                      : '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              movie['name'] ?? 'No Title',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// Search Screen
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  bool isLoading = false;

  void searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      searchResults = [];
    });

    final response = await http
        .get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));
    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onSubmitted: searchMovies,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? Center(child: Text('Search for movies'))
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final movie = searchResults[index]['show'];
                    return ListTile(
                      leading: movie['image'] != null
                          ? Image.network(
                              movie['image']['medium'],
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 50, color: Colors.grey),
                      title: Text(movie['name'] ?? 'No Title'),
                      subtitle: Text(movie['summary'] != null
                          ? movie['summary'].replaceAll(RegExp(r'<[^>]*>'), '')
                          : 'No Summary'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(movie: movie),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// Details Screen
class DetailsScreen extends StatelessWidget {
  final dynamic movie;

  DetailsScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['name'] ?? 'No Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie['image'] != null)
              Image.network(movie['image']['original'],
                  height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(
              movie['name'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              movie['summary'] != null
                  ? movie['summary'].replaceAll(RegExp(r'<[^>]*>'), '')
                  : 'No Summary',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
