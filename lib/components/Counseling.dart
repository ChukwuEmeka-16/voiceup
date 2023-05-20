import 'package:flutter/material.dart';

class CounselingContainer extends StatefulWidget {
  const CounselingContainer({super.key});

  @override
  State<CounselingContainer> createState() => _CounselingContainerState();
}

class _CounselingContainerState extends State<CounselingContainer> {
  TextEditingController _searchVal = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        // top margin
        SizedBox(height: 30),

        //
        //--------- search bar
        //
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Align(
            alignment: Alignment.center,
            child: TextField(
              autofocus: false,
              keyboardType: TextInputType.text,
              controller: _searchVal,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: 'Find someone',
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.search,
                        color: Color.fromARGB(128, 91, 55, 183)),
                    onTap: () {
                      print('search');
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ),

        //
        SizedBox(
          height: 30,
        ),
        //
        //------- body / results
        //
        CounsellorCard()
        //---- end
      ]),
    );
  }
}

class CounsellorCard extends StatelessWidget {
  const CounsellorCard({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width / 2.5;
    var screenHeight = MediaQuery.of(context).size.height / 3.2;

    return Container(
      height: screenHeight,
      width: screenWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/authpage.png'),
              ),
              //
              //---------- counsellor text
              SizedBox(height: 20),
              //
              Text(
                'Eli Asikaro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              //
              //----------- therapist state
              SizedBox(
                height: 5,
              ),
              //
              Text(
                'Abuja,Nigeria',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              //
              //------------ therapist description
              SizedBox(
                height: 5,
              ),
              //
              Text('Experienced therapist specializing in dome...'),

              //
              //----- stars footer
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 15),
                  Icon(Icons.star, color: Colors.yellow, size: 15),
                  Icon(Icons.star, color: Colors.yellow, size: 15),
                  Icon(Icons.star, color: Colors.yellow, size: 15),
                  Icon(Icons.star, color: Colors.yellow, size: 15),
                  Text(
                    '5.0',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
