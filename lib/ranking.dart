import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                                const SizedBox(height: 20,),

                RowModel('Monthly Ranking'),

                const SizedBox(height: 30,),
                const PlaylistContainer(
                  song_number: '80 Songs',
                  playlist_name: "Popular Playlist",
                  photo: "assets/images/imagine.png",
                ),
          
              const  SizedBox(height:20),
          
             const   PlaylistContainer(
                  song_number: '80 Songs',
                  playlist_name: "Popular Playlist",
                  photo: "assets/images/post_malone.png",
                ),
          
               const SizedBox(height:20),
          
               const PlaylistContainer(
                  song_number: '80 Songs',
                  playlist_name: "Popular Playlist",
                  photo: "assets/images/imagine_2v.png",
                ),
          
              const  SizedBox(height:20),
          
               const PlaylistContainer(
                  song_number: '80 Songs',
                  playlist_name: "Popular Playlist",
                  photo: "assets/images/power.png",
                ),

                              const  SizedBox(height:20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlaylistContainer extends StatelessWidget {
  const PlaylistContainer({

    required this.photo,
    // ignore: non_constant_identifier_names
    required this.song_number,
    // ignore: non_constant_identifier_names
    required this.playlist_name,
    
    Key? key,
  }) : super(key: key);

  final String photo;
  // ignore: non_constant_identifier_names
  final String song_number;
  // ignore: non_constant_identifier_names
  final String playlist_name;


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      width: 340,
      decoration: BoxDecoration(
        boxShadow: const [
           BoxShadow(
              offset: Offset(4, 4),
              spreadRadius: 0,
              blurRadius: 4,
              color: Color.fromARGB(255, 166, 206, 224),
            ),
            BoxShadow(
              offset: Offset(10, 10),
              spreadRadius: 0,
              blurRadius: 22,
              color: Color.fromARGB(255, 118, 180, 205),
            ),

             BoxShadow(
              offset: Offset(-5, 0),
              spreadRadius: 0,
              blurRadius: 2,
              color: Colors.white,
            ),
          ],
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(11)),
      child: Stack(
        children: [
          Image.asset(
            photo,
            height: 300,
            width: 500,
            fit: BoxFit.fill,
          ),
          Positioned(
            bottom: 0,
            top: 140,
            left: 15,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Text(
                  playlist_name,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  song_number,
                  style:const TextStyle(fontSize: 9, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
RowModel(String words) {
  return Row(
    
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // SizedBox(height: 20,),

      Text(       
        words,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color.fromARGB(255, 111, 171, 211),
        ),
      ),
      
      Container(
        height: 22,
        width: 35,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, -1),
              spreadRadius: 0,
              blurRadius: 1,
              
              color: Color.fromARGB(185, 255, 255, 255),
              
            ),
          ],
          color: const Color.fromARGB(255, 158, 204, 228),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
      )
    ],
  );
}
