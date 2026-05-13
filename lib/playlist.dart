// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.lightBlue[100],
body: SafeArea(
  child:   Padding(
    padding: const EdgeInsets.symmetric(horizontal:40.0),
    child: SingleChildScrollView(
      child: Column(
    
        children: [
                const SizedBox(height: 20,),

          RowModel('Popular Playlist') ,
                const SizedBox(height: 30,),

    
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              PlaylistTile(album: "assets/images/weekend.png", playlist_name: "Top Beats", song_number: '40 Songs'),
    
              PlaylistTile(album: "assets/images/imagine_2v.png", playlist_name: "Top Beats", song_number: '40 Songs')
            ],
          ),
    
          const SizedBox( height: 30,),
    
          const PlaylistContainer(photo: "assets/images/imagine_2v.png", song_number: '80 Songs', playlist_name: "Popular Playlist"),
    
           const SizedBox( height: 30,),
    
    
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              PlaylistTile(album: "assets/images/weekend.png", playlist_name: "Top Beats", song_number: '40 Songs'),
    
              PlaylistTile(album: "assets/images/imagine_2v.png", playlist_name: "Top Beats", song_number: '40 Songs')
    
            ],
          ),
    
      
        ],
      
      ),
    ),
  ),
),
    );
  }
}



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


class PlaylistContainer extends StatelessWidget {
  const PlaylistContainer({

    required this.photo,
    required this.song_number,
    required this.playlist_name,
    
    Key? key,
  }) : super(key: key);

  final String photo;
  final String song_number;
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
