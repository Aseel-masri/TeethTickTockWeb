import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final Color customColor = const Color(0xFFBBF1FA);
  final Color mainColor = const Color(0xFF389AAB);

  final List<Map<String, dynamic>> specialtyList = [
    {
      "specialtyTitle": "Cosmetic dentist",
      "image": "Cosmetic dentist.jpg",
      "id": "653b617fb20a7b29931645cb",
    },
    {
      "specialtyTitle": "Pediatric dentist",
      "image": "Pediatric dentist.jpg",
      "id": "6543e16a3336dafe8f42c252",
    },
    {
      "specialtyTitle": "Dental neurologist",
      "image": "Dental neurologist.jpg",
      "id": "6543e16a3336dafe8f42c253",
    },
    {
      "specialtyTitle": "Dental Surgeon",
      "image": "doctors3.jpg",
      "id": "653b617fb20a7b29931645cc",
    },
    {
      "specialtyTitle": "Orthodontist",
      "image": "Orthodontist.jpg",
      "id": "6543e16a3336dafe8f42c254",
    },
  ];

  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: mainColor,
           leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.of(context).pop(),
  ), 
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("HomePage");
              print("Title Image Tapped");
            },
            child: Image.asset(
              'images/logo4.png',
              width: 100.0,
              height: 100.0,
              color: customColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 40,
              ),
            ),
          ],
          elevation: 6,
          shadowColor: mainColor,
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 600,
          width: 1100,
          // color: mainColor,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: mainColor,
                  size: 30,
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              SizedBox(width: 50),
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Categories",
                            style: GoogleFonts.lora(
                              textStyle: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: mainColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 9.0,
                                    color: mainColor,
                                    offset: Offset(
                                        MediaQuery.of(context).size.width *
                                            0.002,
                                        MediaQuery.of(context).size.width *
                                            0.002),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.category_rounded,
                            size: 50,
                            color: mainColor,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: specialtyList.length,
                        itemBuilder: (context, i) {
                          return Opacity(
                            opacity: 0.8,
                            child: Card(
                              // color: Colors.black38,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  try {
                                    Navigator.pushNamed(
                                      context,
                                      'Specialty',
                                      arguments: {
                                        'specialtyTitle': specialtyList[i]
                                            ['specialtyTitle'],
                                        'image': specialtyList[i]['image'],
                                        'id': specialtyList[i]['id'],
                                      },
                                    );
                                  } catch (e) {
                                    print('Error: $e');
                                  }
                                },
                                splashColor: mainColor.withOpacity(0.5),
                                child: Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(15.0),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'images/${specialtyList[i]["image"]}'),
                                      fit: BoxFit.cover,
                                    ),
                                     boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // color: Colors.black38,
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.black45,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${specialtyList[i]['specialtyTitle']}',
                                          style: GoogleFonts.lora(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    _buildPageIndicator(),
                  ],
                ),
              ),
              SizedBox(width: 50),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: mainColor,
                  size: 30,
                ),
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        specialtyList.length,
        (index) => Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? mainColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}
