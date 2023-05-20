import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../minicomponents/snack_bar.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          ListTileContainer(),
        ],
      ),
    );
  }
}

class ListTileContainer extends StatefulWidget {
  ListTileContainer({super.key});

  @override
  State<ListTileContainer> createState() => _ListTileContainerState();
}

class _ListTileContainerState extends State<ListTileContainer> {
  late bool isActive = false;
  late bool realActive;

  // get security mode state
  DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  Future<void> getMode() async {
    var snapshot = await documentReference.get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      realActive = data['securityMode'];
    }
  }

  // change the security mode
  Future<void> updateMode() async {
    await documentReference.update({'securityMode': !isActive}).then((value) {
      showSuccSnack(context: context, text: 'Security mode changed!');
    }).catchError((e) {
      showErrSnack(context: context, text: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
   

    getMode().then((value) {
      isActive = realActive;
    });

    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListTile(
                title: Text('Security Mode'),
                trailing: ElevatedButton(
                  onPressed: () {
                    updateMode();
                  },
                  child: Text('Change Mode'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885)),
                ),
                contentPadding: EdgeInsets.only(top: 10),
                textColor: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
