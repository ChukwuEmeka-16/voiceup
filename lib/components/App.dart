// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'Contacts.dart';
import 'Incident_reporting.dart';
import 'Counseling.dart';
import 'Profile.dart';
import 'Settings.dart';
import 'faq_help.dart';
import 'Login.dart';
import '../firebase/auth_methods.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var currentPage = Pages.Home;

  @override
  Widget build(BuildContext context) {
    var container;

    if (currentPage == Pages.Home) {
      container = Home();
    } else if (currentPage == Pages.EmergencyContacts) {
      container = ContactsContainer();
    } else if (currentPage == Pages.Counseling) {
      container = CounselingContainer();
    } else if (currentPage == Pages.IncidentReporting) {
      container = IncidentContainer();
    } else if (currentPage == Pages.Profile) {
      container = ProfileContainer();
    } else if (currentPage == Pages.Settings) {
      container = SettingsContainer();
    } else if (currentPage == Pages.FaqHelp) {
      container = FaqHelpContainer();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF4637B7),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, right: 20, bottom: 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //----------- column widget start

              //
              //--------- top icon
              //
              TopIcon(),

              SizedBox(
                height: 10,
              ),
              //
              //-----  Drawer body
              //
              ListItem(1, 'Home', currentPage == Pages.Home ? true : false),
              SizedBox(height: 8),
              ListItem(2, 'Emergency Contacts', currentPage == Pages.EmergencyContacts ? true : false),
              SizedBox(height: 8),
              ListItem(3, 'Counseling', currentPage == Pages.Counseling ? true : false),
              SizedBox(height: 8),
              ListItem(4, 'Incident Reporting', currentPage == Pages.IncidentReporting ? true : false),
              SizedBox(height: 8),
              ListItem(5, 'Profile', currentPage == Pages.Profile ? true : false),
              SizedBox(height: 8),
              ListItem(6, 'Settings', currentPage == Pages.Settings ? true : false),
              SizedBox(height: 8),
              ListItem(7, 'FAQ/Help', currentPage == Pages.FaqHelp ? true : false),
              SizedBox(height: 15),
              //
              // ------ logout button
              //
              LogOut(),
              //
              //---------- version text
              //
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Voice Up - v1.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )

              //-------------- end of column widget
            ]),
          ),
        ),
      ),
      body: SafeArea(child: container),
    );
  }

  // function to change to  the current page
  void checkCurrentPage(int id) {
    if (id == 1) {
      currentPage = Pages.Home;
    } else if (id == 2) {
      currentPage = Pages.EmergencyContacts;
    } else if (id == 3) {
      currentPage = Pages.Counseling;
    } else if (id == 4) {
      currentPage = Pages.IncidentReporting;
    } else if (id == 5) {
      currentPage = Pages.Profile;
    } else if (id == 6) {
      currentPage = Pages.Settings;
    } else if (id == 7) {
      currentPage = Pages.FaqHelp;
    }
  }

  // the list items of the sidebar
  Widget ListItem(int id, String title, bool selected) {
    return SizedBox(
      height: 45,
      child: ListTile(
          onTap: () {
            setState(() {
              checkCurrentPage(id);
            });
          },
          textColor: !selected ? Colors.white : Color(0xFF4637B7),
          tileColor: selected ? Colors.white : Colors.transparent,
          contentPadding: EdgeInsets.only(left: selected ? 60 : 20),
          title: Text(title),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(28)),
          )),
    );
  }
}

enum Pages { Home, EmergencyContacts, Counseling, IncidentReporting, Profile, Settings, FaqHelp }

// drawer topicon
class TopIcon extends StatelessWidget {
  const TopIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// logout button
class LogOut extends StatelessWidget {
  const LogOut({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FirebaseAuthMethods(FirebaseAuth.instance).appSignOut(context: context);
      },
      child: ListTile(
        title: Text('Log Out'),
        tileColor: Color(0xFF604AFF),
        textColor: Colors.white,
        contentPadding: EdgeInsets.only(left: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(28)),
        ),
      ),
    );
  }
}
