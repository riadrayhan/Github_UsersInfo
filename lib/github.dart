import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'details.dart';

class Github extends StatefulWidget {
  @override
  _GithubState createState() => _GithubState();
}
class _GithubState extends State<Github> {
  String username = '';
  Map<String, dynamic> userData = {};

  Future<void> fetchUserData() async {
    if (username.isNotEmpty) {
      final response = await http.get(Uri.parse('https://api.github.com/users/$username'));
      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub User Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
              child: Text('Fetch User Data'),
              onPressed: fetchUserData,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('User Details'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(username: username),)),
            ),
            SizedBox(height: 16.0),
            if (userData.isNotEmpty)
              Column(
                children: [
                  CircleAvatar(
                    radius: 64.0,
                    backgroundImage: NetworkImage(userData['avatar_url']),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Username: ${userData['login']}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Name: ${userData['name'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Location: ${userData['location'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
