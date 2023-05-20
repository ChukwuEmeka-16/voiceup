import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../minicomponents/snack_bar.dart';

class ProfileContainer extends StatefulWidget {
  ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  // documnt reference
  DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  // result values
  bool securityMode = false;
  String fullName = 'N/A';
  String email = 'N/A';
  int contacts = 0;
  int count = 0;

  // get the user document
  Future<void> getDocument() async {
    var snapshot = await documentReference.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      securityMode = data['securityMode'];
      fullName = data['name'];
      email = data['email'];
      contacts = data['contacts'].length;
      if (count < 1) {
        setState(() {});
        count++;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    getDocument();
    return Container(
      width: double.infinity,
      //alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfilePic(),
            ListTileContainer(trailingTextValue(securityMode ? 'Active' : 'InActive'), 'Security mode :'),
            ListTileContainer(trailingIconWidget('name', context), '$fullName :'),
            ListTileContainer(trailingTextValue('Email'), '$email :'),
            ListTileContainer(trailingTextValue('$contacts'), 'Contacts')
          ],
        ),
      ),
    );
  }
}

// profile pic container

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.3,
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/authpage.png'),
      ),
    );
  }
}

// profile list tiles

class ListTileContainer extends StatefulWidget {
  final String title;
  final Widget trailing;

  ListTileContainer(this.trailing, this.title);

  @override
  State<ListTileContainer> createState() => _ListTileContainerState();
}

class _ListTileContainerState extends State<ListTileContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  widget.title,
                  style: TextStyle(fontSize: 20),
                ),
                trailing: widget.trailing,
                contentPadding: EdgeInsets.only(top: 10),
                textColor: Color(0xFF332885),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget trailingIconWidget(String dbkey, BuildContext context) {
  return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => EditPopUpAlert(
                  dbkeyy: dbkey,
                ));
      },
      child: Icon(Icons.edit_square));
}

Widget trailingTextValue(String text) {
  return Text(
    '$text',
    style: TextStyle(fontSize: 20),
  );
}

// alert dialogue

class EditPopUpAlert extends StatefulWidget {
  final String dbkeyy;
  const EditPopUpAlert({required this.dbkeyy});

  @override
  State<EditPopUpAlert> createState() => _EditPopUpAlertState();
}

class _EditPopUpAlertState extends State<EditPopUpAlert> {
  TextEditingController _newValue = TextEditingController();

  DocumentReference _documentReference = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  Future<void> _updateField() async {
    await _documentReference.update({widget.dbkeyy: _newValue.text}).then((value) {
      Navigator.pop(context);
      showSuccSnack(context: context, text: 'Field updated!');
      
    }).catchError((e) {
      Navigator.pop(context);
      showErrSnack(context: context, text: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _newValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: Color(0xFF332885),
                width: 1,
              )),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
          hintText: 'New value?',
        ),
      ),
      actions: [
        // pop button
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Color.fromARGB(193, 246, 55, 42)))),
        // update button
        TextButton(
            onPressed: () {
              _updateField();
            },
            child: Text('Update', style: TextStyle(color: Colors.orange))),
      ],
    );
  }
}
