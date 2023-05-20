import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gbvapp/minicomponents/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SecurityModeBtnContainer(),
    );
  }
}

// button and text
class SecurityModeBtnContainer extends StatefulWidget {
  const SecurityModeBtnContainer({super.key});

  @override
  State<SecurityModeBtnContainer> createState() => _SecurityModeBtnContainerState();
}

class _SecurityModeBtnContainerState extends State<SecurityModeBtnContainer> {
  // storage object

  String activeMessage = 'MOVE YOUR FINGER AROUND THE BUTTON';
  String btnActivateMessage = 'THEN RELEASE TO SEND A SECURITY ALERT';
  String inActiveMessage = 'HOLD DOWN TO ACTIVATE';
  String btnDeactivateMessage = 'SECURITY MODE';

  // button default states
  String UItext = 'HOLD DOWN TO ACTIVATE';
  String BTNtext = 'SECURITY MODE';
  bool activeMode = false;

  // function to manipulate the activemode value in  storage

  // to get the value of the security button on page load (weather its active or not)

  // button colors
  dynamic deactivated = Color.fromARGB(128, 91, 55, 183);
  dynamic activated = Color(0xFF332885);

  dynamic BTNcolor = Color.fromARGB(128, 91, 55, 183);

  void _checkPermission() async {
    // check if the location, sms and microphone permissions are granted
    bool locationStatus = await Permission.location.request().isGranted;
    bool micStatus = await Permission.microphone.request().isGranted;
    bool smsStatus = await Permission.sms.request().isGranted;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // if true , the users are allowed to enable security mode
    if (locationStatus && micStatus && smsStatus && serviceEnabled) {
      // activate security mode on button release
      activeMode = true;
      if (activeMode == true) {
        UItext = activeMessage;
        BTNtext = btnActivateMessage;
        BTNcolor = activated;
      } else {
        UItext = inActiveMessage;
        BTNtext = btnDeactivateMessage;
        BTNcolor = deactivated;
      }
      setState(() {});
    } else {
      showErrSnack(context: context, text: 'You must enable all permissions before using security mode');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            child: GestureDetector(
              onPanEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx == 0 && details.velocity.pixelsPerSecond.dy == 0) {
                  if (activeMode) {
                    showModalBottomSheet(context: context, builder: (context) => PinModal(), isScrollControlled: true);
                  }
                }
              },
              child: ElevatedButton(
                  onLongPress: () {
                    _checkPermission();
                  },
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(shape: CircleBorder(), backgroundColor: BTNcolor, elevation: 5, shadowColor: Colors.grey),
                  child: Icon(
                    Icons.power_settings_new,
                    size: 80,
                  )),
            )),
        SizedBox(height: 20),
        Text(UItext, style: TextStyle(color: activated)),
        Text(BTNtext, style: TextStyle(color: activated)),
        SizedBox(height: 30),
      ],
    );
  }
}

// pop up modal for pin

class PinModal extends StatefulWidget {
  const PinModal({super.key});

  @override
  State<PinModal> createState() => _PinModalState();
}

class _PinModalState extends State<PinModal> {
  // codes from the user
  String digitOne = '';
  String digitTwo = '';
  String digitThree = '';
  String digitFour = '';
  bool isDeactivated = false;
  //--------- function to send security alert

  Future<void> _verifyPin() async {
    // concatinate code to one
    String stringCode = '$digitOne$digitTwo$digitThree$digitFour';

    //----- from here , i compare with user pin to see if correct

    // get the users id
    String userID = FirebaseAuth.instance.currentUser!.uid;
    // point to the users collection
    var collectionRef = FirebaseFirestore.instance.collection("users");
    // point to the users doc
    var documentRef = collectionRef.doc(userID);

    // get the doc
    try {
      var snapshot = await documentRef.get();
      // check if anything is returned
      if (snapshot.exists) {
        // snapshot.data() returns an object of type string(key) dynamic(value)
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // compare the code we collected with the pin in the document
        if (data['pin'] == stringCode) {
          isDeactivated = true;
          Navigator.pop(context);
          showSuccSnack(context: context, text: 'DeActivated');
        } else {
          showErrSnack(context: context, text: 'Wrong PIN!');
        }
      } else {
        showErrSnack(context: context, text: 'Error sending alert, try again!');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrSnack(context: context, text: e.toString());
    }
  }
  // ----------function end

  // states for the pin
  TextEditingController _digitOne = TextEditingController();
  TextEditingController _digitTwo = TextEditingController();
  TextEditingController _digitThree = TextEditingController();
  TextEditingController _digitFour = TextEditingController();
  // state for new pin for when we are resetting the pin
  TextEditingController _newPin = TextEditingController();
  // forgot pin toggler
  bool isVisible = true;

  // the reason for his variable below is because i discovered a glitch where
  // anytime the modal is tapped the build method is callsed, every single time
  // and i have tried everything within my knowledge as of now and i cannot find the cause of the error (the setStates in the modal arent the cause)
  // the variable wont stop it from being called it will just stop SMS from being sent multiple times on every build

  int buildCount = 0;
  // send alert
  List<dynamic> contacts = [];
  Future<void> _sendAlert() async {
    // while security mode is not deactivated and cont is greater than 0 execute

    await Future.delayed(Duration(seconds: 15), () async {
      // if security mode has not been deactivated we do the code below
      
      if (!isDeactivated) {
        // get the current location, then.....
        
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) async {
          // sms message we will send
          String alertTxt = 'This Alert was sent by the Voice up Emergency alerts app, you recieved this alert because the app detected that the user of this device may be in danger, their location is $value';
          // reference to the user document
          DocumentReference _documentReference = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
          // the snapshot is the result of the request
          var snapshot = await _documentReference.get();
          // if something is returned then we can send the sms
          if (snapshot.exists) {
            // get data
            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            // store data in outer array first, i did this because flutter was throwing a null exception when i try to just loop directly from the data Map
            contacts = data['contacts'];

            List<String> recipentsOfSms = [];

            // get the phone numbers from the contacts array of maps
            contacts.forEach((item) {
              recipentsOfSms.add(item['phone']);
            });
            // now that we have our numbers we can send an sms
            await sendSMS(message: alertTxt, recipients: recipentsOfSms).then((value) {
              Navigator.pop(context);
              showSuccSnack(context: context, text: 'SMS sent sucessfully');
              // handle sms error
            }).catchError((e) {
              Navigator.pop(context);
              showErrSnack(context: context, text: e.toString());
            });
          }
        }) // handle geo locator error
            .catchError((err) {
          showErrSnack(context: context, text: err.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (buildCount == 0) {
      buildCount++;
      _sendAlert();
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            SizedBox(height: 10),

            ///
            ///
            ///
            Text('You have 15 seconds to enter your pin, or an alert will be sent to all emergency contacts'),

            ///
            ///
            ///
            SizedBox(
              height: 50,
            ),
            //
            // body of modal
            //
            Text(
              'ENTER VERIFICATION PIN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(
              height: 10,
            ),

            // input box row container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // input box 1
                SizedBox(
                  height: 70,
                  width: 44,
                  child: TextField(
                    autofocus: true,
                    controller: _digitOne,
                    cursorColor: Colors.black,
                    maxLength: 1,
                    onChanged: (value) {
                      digitOne = _digitOne.text;

                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Color(0xFF332885),
                        width: 1,
                      )),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
                    ),
                  ),
                ),

                // input box 2
                SizedBox(
                  height: 70,
                  width: 44,
                  child: TextField(
                    controller: _digitTwo,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      digitTwo = _digitTwo.text;
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.length == 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF332885), width: 1)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
                    ),
                  ),
                ),

                // input box 3

                SizedBox(
                  height: 70,
                  width: 44,
                  child: TextField(
                    controller: _digitThree,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      digitThree = _digitThree.text;
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.length == 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF332885), width: 1)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
                    ),
                  ),
                ),

                // input box 4

                SizedBox(
                  height: 70,
                  width: 44,
                  child: TextField(
                    controller: _digitFour,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      digitFour = _digitFour.text;
                      if (value.length == 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF332885), width: 1)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)), border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            //
            ////
            // verify button
            ///
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885)),
                  onPressed: () {
                    _verifyPin();
                  },
                  child: Text('Verify')),
            ),
            //
            ///
            ////
            SizedBox(height: 30),
            //
            ///
            // forgot pin button
            //
            Visibility(
              visible: isVisible,
              replacement: ChangePinForm(),
              child: GestureDetector(
                onTap: () {
                  isVisible = !isVisible;
                  setState(() {});
                },
                child: Text(
                  'FORGOT PIN?',
                  style: TextStyle(color: Color(0xFF332885)),
                ),
              ),
            ),

            // change pin
          ],
        ),
      ),
    );
  }

  //
  //----- this function returns the form for changing pin
  //
  Widget ChangePinForm() {
    // state

    Future<bool> _changePin() async {
      if (_newPin.text.length <= 3) {
        Navigator.pop(context);
        showErrSnack(context: context, text: 'Pin must be 4 digits!');
        return false;
      }
      String userID = FirebaseAuth.instance.currentUser!.uid;
      var documentef = FirebaseFirestore.instance.collection('users').doc(userID);

      try {
        await documentef.update({'pin': _newPin.text.toString()}).then((value) {
          Navigator.pop(context);
          showSuccSnack(context: context, text: 'Pin changed');
        });
      } catch (e) {
        showErrSnack(context: context, text: e.toString());
      }

      return true;
    }

    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              isVisible = !isVisible;
              setState(() {});
            },
            child: Text('CANCEL', style: TextStyle(color: Color(0xFF332885))),
          ),
          //
          ///
          SizedBox(height: 20),

          ///
          // new pin field
          //
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextField(
                controller: _newPin,
                maxLength: 4,
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
                  hintText: 'New PIN',
                )),
          ),
          //
          ///
          SizedBox(height: 20),

          ///
          ///
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885)),
                onPressed: () {
                  _changePin();
                },
                child: Text('CHANGE PIN')),
          )

          //----- end of column
        ],
      ),
    );
  }
}
