import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddSleepScreen extends StatelessWidget {
  const AddSleepScreen({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context){

    // scaffold is basic skeleton that we use to lay everything else out
    // gives you appbar (top of screen, title or back button)
    // body (main part of screen where all your content goes)
    // floating action button if you want it
    // drawer (side menu that slides in from the left)
    // bottom navbar
    // without scaffold you'd have to build all of this from scratch
    return Scaffold(

      backgroundColor: const Color(0xFFF9EDFF),

      appBar: AppBar(
        // shows back arrow on the left if there's a route to go back to
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Sleep Details',
          style: TextStyle(
            color: Color(0xFFDDA7F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),




      // body can have column/row for laying widgets vertically or horizontally
      // listview to make scrollable content
      // center to center a widget
      // stack to put widgets on top of each other
      // padding to add space around
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        // child: widget that you put inside another widget
        // container, padding, center accept a child
        // columns and rows accept children
        child: Column (
          // cross axis alignment controls how children are aligned in direction perpendicular to main axis
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            _infoCard(
              title: "Night of:",
              content: "Friday, March 7, 2025",
              icon: Icons.calendar_today,
            ),
            _infoCard(
              title: "Sleep Duration:",
              content: "11:30 PM  →  7:30 AM",
              icon: Icons.schedule,
            ),

            // rate your sleep
            Container (
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [ 
                  BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
              ),

              child: Column (
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sleep Quality Rating",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(CupertinoIcons.moon_fill, size: 30, color: Color(0xFFA764FF)), // "😞" equivalent
                      Icon(CupertinoIcons.moon_fill, size: 30, color: Color(0xFFA764FF)),     // "😕" equivalent
                      Icon(CupertinoIcons.moon_fill, size: 30, color: Color(0xFFA764FF)), // "😐" equivalent (or a neutral face)
                      Icon(CupertinoIcons.moon, size: 30, color: Color(0xFFDDA7F6)),    // "🙂" equivalent
                      Icon(CupertinoIcons.moon, size: 30, color: Color(0xFFDDA7F6)),
                    ],
                  ),

                ],)
            ),

            //notes
            Container (
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [ 
                  BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
              ),

              child: Column (
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Notes",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Woke up several times throughout the night—once at 1am, then again at 3am. Had caffeine late in the evening yesterday and missed a workout... Focus tomorrow is reducing coffee intake",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                    textAlign: TextAlign.left,
                  ),

                ],)
            ),

            Container(
              margin: const EdgeInsets.only(top: 15),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA764FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Add Sleep",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),


          ]
        ),
      ),
    );
  }

}

Widget _infoCard({required String title, required String content, required IconData icon}) {

  return Container (
    // padding between cards
    margin: const EdgeInsets.only(top: 15),
    // padding within cards
    padding: const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [ 
        BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
    ),
    child: Row (
      children: [
        Icon(icon, color: Color(0xFFDDA7F6), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
        ),
        const Spacer(),
        Text(
          content,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
        ),
      ],)

  );

}
