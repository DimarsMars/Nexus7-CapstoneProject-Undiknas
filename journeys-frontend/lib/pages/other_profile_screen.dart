import 'package:flutter/material.dart';

class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen({super.key});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe9ebee),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),

                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                    SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                      ),
                      SizedBox(height: 30),

                      Text(
                        'Name',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      Text(
                        'Denoy',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        'Rank\'s',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      Text(
                        'Traveller',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Column(
                            children: [
                              Text(
                                'Followers',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF1C314A),
                                ),
                              ),
                              Text(
                                '100',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1C314A),
                                ),
                              )
                            ],
                          ),

                          Column(
                            children: [
                              Text(
                                'Reviews',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF1C314A),
                                ),
                              ),
                              Text(
                                '20',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1C314A),
                                ),
                              )
                            ],
                          ),

                          Column(
                            children: [
                              Text(
                                'Route\'s',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF1C314A),
                                ),
                              ),
                              Text(
                                '4',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1C314A),
                                ),
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height:20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                        
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1C314A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'Follow'
                                ),
                              ), 
                            ),
                            
                            SizedBox(width:15),
                        
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                        
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'Report'
                                ),
                              ), 
                            ),
                          ],
                        ),
                      )
                    ]
                  ),
                )
              ),
          ),
        ),
      )
    );
  }
}