import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gbvapp/minicomponents/snack_bar.dart';

class ContactsContainer extends StatelessWidget {
  const ContactsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CONTACTS', style: TextStyle(fontSize: 15)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: ContactsBody(),
        ),
      ),
    );
  }
}

class ContactsBody extends StatefulWidget {
  const ContactsBody({super.key});

  @override
  State<ContactsBody> createState() => _ContactsBodyState();
}

class _ContactsBodyState extends State<ContactsBody> {
  // list of contacts
  List<dynamic> contacts = [];

  // the reason for this count is because calling setstate without a condition turns your app into an infinite loop, it almost crashed my system
  int count = 0;
  //get contacts from db

  // i wrapped the getContacts() in this tbody() because the place i used the 'tbody()' does not accept functions with a Future<void> return type

  int tbody() {
    // ignore: unused_element
    Future<void> getContacts() async {
      // get the users id
      String userID = FirebaseAuth.instance.currentUser!.uid;
      // point to the users collection and cdocument
      var documentRef = FirebaseFirestore.instance.collection("users").doc(userID);

      var snapshot = await documentRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        contacts = data['contacts'];

        if (count == 0) {
          setState(() {});
          // increment count variable
          count++;
        }
      }
    }

    getContacts();

    return contacts.length;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      itemCount: tbody() + 1,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
        mainAxisSpacing: 10.0, // Spacing between each row
        crossAxisSpacing: 10.0, // Spacing between each column
      ),
      itemBuilder: (context, index) {
        if (index == contacts.length) {
          return addContact();
        } else {
          return ContactCard(contacts[index]['name'], contacts[index]['phone']);
        }
      },
    );
  }
}

// Contact card
class ContactCard extends StatelessWidget {
  final String name;
  final String number;
  ContactCard(this.name, this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9))),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // top icon
              //

              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
              ),
              //
              // ------
              SizedBox(
                height: 5,
              ),
              //-------
              //

              // Contact name
              //
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              //
              //------
              SizedBox(height: 20),
              //------
              //

              // icons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.sms_rounded, color: Color(0xFF332885)),
                  Icon(Icons.location_on, color: Color(0xFF332885)),
                  Icon(Icons.mic, color: Color(0xFF332885)),
                ],
              ),

              // bottom icon
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (context) => DeleteContactAlertForConfirmation(name: name, phone: number));
                        },
                        child: Icon(Icons.delete, color: Color.fromARGB(128, 91, 55, 183)),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

// add contact card

class addContact extends StatefulWidget {
  const addContact({super.key});

  @override
  State<addContact> createState() => _addContactState();
}

class _addContactState extends State<addContact> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(context: context, shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))), builder: (context) => NewContactForm(), isScrollControlled: true);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        elevation: 1,
        color: Color.fromARGB(128, 91, 55, 183),
        child: Icon(
          Icons.add,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}

// add a new contact modal

class NewContactForm extends StatefulWidget {
  const NewContactForm({super.key});

  @override
  State<NewContactForm> createState() => _NewContactFormState();
}

class _NewContactFormState extends State<NewContactForm> {
  // states for the name and phone number
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();

  // upload new contact
  void _uploadContact({required String name, required String phone}) async {
    // get the users id
    String userID = FirebaseAuth.instance.currentUser!.uid;
    // point to the users collection and cdocument
    var documentRef = FirebaseFirestore.instance.collection("users").doc(userID);

    await documentRef.update({
      'contacts': FieldValue.arrayUnion([
        {'name': name, 'phone': phone}
      ])
    }).then((value) {
      Navigator.pop(context);
      showSuccSnack(context: context, text: 'Contact added, Refresh to see updates!');
    }).catchError((e) {
      showErrSnack(context: context, text: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //
          // textfied 1
          TextField(
              controller: _name,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF332885),
                      width: 1,
                    )),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'First Name :',
              )),
          //
          //
          SizedBox(height: 30),
          //
          ///
          // textfield 2
          ///
          //
          TextField(
              controller: _phone,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF332885),
                      width: 1,
                    )),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Phone Number :',
              )),
          //
          //
          SizedBox(height: 30),
          //
          ///
          //add button
          ///
          ///
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.7,
            child: ElevatedButton(
              onPressed: () {
                _uploadContact(name: _name.text.toString(), phone: _phone.text.toString());
              },
              child: Text('Add Contact'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885)),
            ),
          )
        ],
      ),
    );
  }
}

class DeleteContactAlertForConfirmation extends StatelessWidget {
  // get the name and number of the current contact
  final name;
  final phone;
  const DeleteContactAlertForConfirmation({this.name, this.phone});

  // upload new contact
  void _deleteContact(context) async {
    // get the users id
    String userID = FirebaseAuth.instance.currentUser!.uid;
    // point to the users collection and cdocument
    var documentRef = FirebaseFirestore.instance.collection("users").doc(userID);

    await documentRef.update({
      'contacts': FieldValue.arrayRemove([
        {'name': name, 'phone': phone}
      ])
    }).then((value) {
      Navigator.pop(context);
      showSuccSnack(context: context, text: 'Contact deleted, Refresh to see updates!');
    }).catchError((e) {
      showErrSnack(context: context, text: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Are you sure you want to delete this contact?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              _deleteContact(context);
            },
            child: Text('Yes')),
      ],
    );
  }
}
