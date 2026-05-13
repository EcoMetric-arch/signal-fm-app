import 'package:flutter/material.dart';
import 'package:musicapp/feed.dart';
import 'package:musicapp/ranking.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),

                
               Container(
                margin: EdgeInsets.symmetric(horizontal: 45),
                child:RowModel("News") ,) ,

                SizedBox(
                  height:30,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),

                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),
                SizedBox(
                  height: 40,
                ),
                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),

                SizedBox(
                  height: 40,
                ),

                const NewsTile(
                  photo: "assets/images/justin.png",
                  headline:
                      "Justin Bieber announces new concert dates for his.....",
                ),

                SizedBox(
                  height: 40,
                ),

                
              ],
            ),
          )),
    );
  }
}
