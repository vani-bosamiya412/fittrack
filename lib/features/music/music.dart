import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<dynamic> musicList = [];
  bool isLoading = true;

  final String viewApiUrl = "https://prakrutitech.xyz/vani/view_music.php";

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    try {
      final response = await http.get(Uri.parse(viewApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          musicList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load music');
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading music list")));
    }
  }

  Future<void> openSong(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if(!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not open music link")));
      }
    } catch (_) {
      if(!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid music URL")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Workout Music",
          style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : RefreshIndicator(
              color: Colors.pinkAccent,
              onRefresh: fetchMusic,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                children: [
                  ...musicList.map((music) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 14 * scale),
                      padding: EdgeInsets.all(14 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffE76CF9), Color(0xffB041FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),

                          SizedBox(width: 14 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music['title'] ?? 'Untitled',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  music['artist'] ?? 'Unknown Artist',
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  music['genre'] ?? 'Unknown Genre',
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${music['duration']} min",
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => openSong(music['music_url']),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffE76CF9), Color(0xffB041FF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}