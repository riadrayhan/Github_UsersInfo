import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*class UserInputPage extends StatefulWidget {
  @override
  _UserInputPageState createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  String username = '';

  void _navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter GitHub username',
              ),
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Explore'),
              onPressed: () {
                setState(() {
                  _navigateToHomePage();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}*/

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  Map<String, dynamic> userData = {};

  List<dynamic> repositories = [];
  bool isGridView = false;
  FilterOptions selectedFilterOption = FilterOptions.date;

  @override
  void initState() {
    super.initState();
    _fetchRepositories();
  }

  Future<void> _fetchRepositories() async {
    final response = await http.get(Uri.parse('https://api.github.com/users/${widget.username}/repos'));
    if (response.statusCode == 200) {
      setState(() {
        repositories = json.decode(response.body);
      });
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch user data.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildRepositoryList() {
    switch (selectedFilterOption) {
      case FilterOptions.date:
        repositories.sort((a, b) => b['created_at'].compareTo(a['created_at']));
        break;
      case FilterOptions.name:
        repositories.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case FilterOptions.stars:
        repositories.sort((a, b) => b['stargazers_count'].compareTo(a['stargazers_count']));
        break;
    }

    return ListView.builder(
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repository = repositories[index];
        return ListTile(
          title: Text(repository['name']),
          subtitle: Text(repository['description'] ?? 'No description'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepositoryDetails(repository: repository),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepositoryGrid() {
    switch (selectedFilterOption) {
      case FilterOptions.date:
        repositories.sort((a, b) => b['created_at'].compareTo(a['created_at']));
        break;
      case FilterOptions.name:
        repositories.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case FilterOptions.stars:
        repositories.sort((a, b) => b['stargazers_count'].compareTo(a['stargazers_count']));
        break;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repository = repositories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepositoryDetails(repository: repository),
              ),
            );
          },
            child: Card(
              child: Container(
                height: 140,
                width: 90,
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(repository['name']),
                    SizedBox(height: 8.0),
                    Text(repository['description'] ?? 'No description'),
                    SizedBox(height: 8.0),
                    Text('Stars: ${repository['stargazers_count']}'),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: ${widget.username}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Display Mode:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('List View'),
                  onPressed: () {
                    setState(() {
                      isGridView = false;
                    });
                  },
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  child: Text('Grid View'),
                  onPressed: () {
                    setState(() {
                      isGridView = true;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Repository List:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: isGridView ? _buildRepositoryGrid() : _buildRepositoryList(),
            ),
          ],
        ),
      ),
    );
  }
}

class RepositoryDetails extends StatelessWidget {
  final dynamic repository;

  const RepositoryDetails({required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repository Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repository: ${repository['name']}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text('Description: ${repository['description'] ?? 'No description'}'),
            SizedBox(height: 8.0),
            Text('Stars: ${repository['stargazers_count']}'),
            SizedBox(height: 8.0),
            Text('Forks: ${repository['forks_count']}'),
            SizedBox(height: 8.0),
            Text('Language: ${repository['language'] ?? 'N/A'}'),
            SizedBox(height: 8.0),
            Text('Created At: ${repository['created_at']}'),
          ],
        ),
      ),
    );
  }
}

enum FilterOptions {
  date,
  name,
  stars,
}
