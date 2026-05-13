// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              SizedBox(height: 20,),

              RowModel("Monthly Ranking"),

              SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  AlbumCircle(
                    picture: "assets/images/imagine.png",
                  ),
                  AlbumCircle(
                    picture: "assets/images/marshmello.png",
                  ),
                  AlbumCircle(
                    picture: "assets/images/havana.png",
                  ),
                ],
              ),
              SizedBox(height: 20,),
              RowModel("Popular Playlist"),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  PlaylistTile(
                    playlist_name: 'Pop Playlist',
                    song_number: '80 Songs',
                    album: 'assets/images/weekend.png',
                  ),
                  PlaylistTile(
                    playlist_name: 'Pop Playlist',
                    song_number: '40 Songs',
                    album: 'assets/images/album_art.png',
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),

              RowModel("News"),

              SizedBox(height: 30,),


              const NewsTile(photo: "assets/images/justin.png",
              headline: "Justin Bieber announces new concert dates for his.....",)
              ,

              const SizedBox(
                height: 40,
              ),

              const NewsTile(photo: "assets/images/drake.png",
              headline: "Justin Bieber announces new concert dates for his.....",),

              const SizedBox(
                height: 40,
              ),

              const NewsTile(photo: "assets/images/justin.png",
              headline: "Justin Bieber announces new concert dates for his.....",),
            ],
          ),
        ),
      ),
    );
  }

   RowModel(String words) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // const SizedBox(
      //   height: 0,
      // ),

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

}

class NewsTile extends StatelessWidget {
  const NewsTile({
    required this.headline,
    required this.photo,
    Key? key,
  }) : super(key: key);

   final String headline;
   final String photo;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 328,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 178, 213, 234),
        border: Border.all(color: const Color.fromARGB(180, 254, 254, 254), width: 3),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            offset: Offset(2, 20),
            spreadRadius: -2,
            blurRadius: 20,
            color: Color.fromARGB(255, 144, 184, 217),
          ),
          BoxShadow(
            offset: Offset(-10, -10),
            spreadRadius: -5,
            blurRadius: 64,
            color: Colors.white,
          ),
          BoxShadow(
            offset: Offset(0, 0),
            spreadRadius: -5,
            blurRadius: 12,
            color: Colors.white,
          ),
          BoxShadow(
            offset: Offset(13, 13),
            spreadRadius: -5,
            blurRadius: 19,
            color: Color.fromARGB(255, 157, 201, 228),
          ),
          BoxShadow(
            offset: Offset(-19, -27),
            spreadRadius: -5,
            blurRadius: 39,
            color: Color.fromARGB(255, 221, 238, 246),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              // padding: EdgeInsets.all(20),
              height: 39,
              width: 39,
              decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(
                        photo,
                      ),
                      fit: BoxFit.fill)),
            ),
          ),

          // Text('Lorem ipsum dolor sit amet, consectetur Lorem ipsum dolor sit amet, consectetur', style: TextStyle(fontSize: 12),)
          Expanded(
            child: RichText(
              text:  TextSpan(
                text:
                    headline,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 12,
                  color: Color.fromARGB(255, 35, 104, 168),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    required this.album,
    required this.playlist_name,
    required this.song_number,
    Key? key,
  }) : super(key: key);

  final String album;
  final String playlist_name;
  final String song_number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      height: 252,
      width: 134,
      decoration: BoxDecoration(
          border:
              Border.all(width: 4, color: const Color.fromARGB(255, 200, 228, 241)),
          boxShadow: const [
            BoxShadow(
              offset: Offset(-5, 0),
              spreadRadius: 0,
              blurRadius: 2,
              color: Colors.white,
            ),
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
              offset: Offset(-10, -10),
              spreadRadius: 0,
              blurRadius: 22,
              color: Colors.white,
            )
          ],
          color: const Color.fromARGB(255, 213, 234, 245),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(30),
                topEnd: Radius.circular(30),
                bottomEnd: Radius.circular(10),
                bottomStart: Radius.circular(10)),
            child: Image.asset(
              album,
              height: 167,
              width: 102,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GradientText(
            playlist_name,
            colors: const [
              Color.fromRGBO(0, 35, 105, 1),
              Colors.black,
            ],
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            // textAlign: TextAlign.left,
          ),
          Text(
            song_number,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9,
                color: Colors.blue[300]),
          ),
        ],
      ),
    );
  }
}

class AlbumCircle extends StatelessWidget {
  const AlbumCircle({
    required this.picture,
    Key? key,
  }) : super(key: key);

  final String picture;
  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: const BoxDecoration(
              // border: Border.all(color: Colors.white, width: 3),
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 213, 234, 245),
              boxShadow: [
                BoxShadow(
                  offset: Offset(-5, -6),
                  spreadRadius: 0,
                  blurRadius: 17,
                  color: Color.fromARGB(255, 229, 243, 251),
                ),
                BoxShadow(
                  offset: Offset(2, 6),
                  spreadRadius: 0,
                  blurRadius: 16,
                  color: Color.fromARGB(255, 86, 140, 174),
                ),
                BoxShadow(
                  offset: Offset(2, 20),
                  spreadRadius: -2,
                  blurRadius: 20,
                  color: Color.fromARGB(255, 144, 184, 217),
                ),
                BoxShadow(
                  offset: Offset(-1, -3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  color: Colors.white,
                ),
                BoxShadow(
                  offset: Offset(1, 1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  color: Color.fromARGB(255, 91, 163, 201),
                ),
              ],
            ),
          ),
          Positioned(
            top: 9,
            left: 9,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white, width: 3),
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(300),
                image: DecorationImage(
                  image: AssetImage(
                    picture,
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
