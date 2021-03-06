/// RESOURCES:
///  1) https://pusher.com/tutorials/flutter-listviews
/// 

// Import directives
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import 'package:sandbox_riverpod/services.dart';

// Models
import 'package:sandbox_riverpod/models/detail.dart';
import 'package:sandbox_riverpod/models/selection_parameter.dart';

// Providers
import 'package:sandbox_riverpod/providers/selection_providers.dart';
import 'package:sandbox_riverpod/providers/detail_providers.dart';

// Utilities - SharedPreference
import 'package:sandbox_riverpod/sandboxes/schedulerv0.2/utils/selection_prefs.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>{
  // List<SelectionParameter> _selectionListStatePref = SelectionPreferences.selectionListStatePref;
  List<SelectionParameter> selectionListState = [];

  
  
  @override
  void initState() {
    super.initState();

    SelectionPreferences.getSelectionStatePrefs("selectionListPref").then((value) {
      selectionListState = value;
      print("Data loaded from SharedPreference");
      print(value);

      // if(selectionListState == []) {
      //   selectionListState = ref.watch(selectionListProvider);
      //   print("Data loaded from Riverpod");
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    

    

    // declaring riverpod state providers
    // final selectionListState = ref.watch(selectionListProvider);

    // declaring notifiers for updating riverpod states
    final SelectionListNotifier selectionListController = ref.read(selectionListProvider.notifier);
    final DetailListNotifier detailListController = ref.read(detailListProvider.notifier);

    // getSelectionStatePrefs('selectionListPref').then((value) =>
    //   _selectionListStatePref = value
    // );

    // If selectionList is not exist in SharedPreference, take value from Riverpod, vice versa
    // if(_selectionListStatePref != []) {
    //   selectionListState = ref.watch(selectionListProvider);
    //   print("Data loaded from Riverpod");

    //   if(selectionListState == []) {
    //     print("Data loaded from SharedPreference");
        
    //   }
    // }

    


    // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    // final prefs = await SharedPreferences.getInstance();
    // final myString = prefs.getString('my_string_key') ?? '';

    // String userPref = _prefs.getString('user');
    // Map<String,dynamic> userMap = jsonDecode(userPref) as Map<String, dynamic>;

    

    // _selectionListState = _prefs.then((SharedPreferences prefs) {
    //   String selectionListState = (prefs.getString('selectionListPref')) ?? '';
    //   return (jsonDecode(selectionListState));
    // }) as List<SelectionParameter>;

    // Future<int> getIntFromLocalMemory(String key) async {
    //   var pref = await SharedPreferences.getInstance();
    //   var number = pref.getInt(key) ?? 0;
    //   return number;
    // }

    
        
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheduler V0.2"),
      ),
      body: selectionListState.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Empty :(',
                ),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              children: <Widget>[
                const Text(
                  'Course List',
                  style: TextStyle(
                    fontFamily: 'avenir',
                    fontSize: 32,
                    fontWeight: FontWeight.w900
                  ),
                ),
                for (var i=0; i<selectionListState.length; i++) Card(
                  child: ListTile(
                    title: Text(selectionListState[i].courseSelected),
                    trailing: const Icon(Icons.delete),
                    onTap: () {
                      selectionListController.deleteSelection(selectionListState[i]);
                    },
                  ),
                ),
                  
              ],
            ),
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('UiTM Scheduler 0.1.1'),
            ),
            ListTile(
              title: const Text('Dictionary'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
                Navigator.pushNamed(context, '/dictionary');
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ]
        )
      ),
          
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            tooltip: "Add course",
            heroTag: "add",
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/selection');
            },
          ),
  
          const SizedBox(height: 16),
  
          FloatingActionButton(
            tooltip: "Fetch Details",
            heroTag: "fetch",
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.find_in_page),
            onPressed: () async {
              // reading campus, course, group in Provider state
              final jsonString = selectionParameterToJson(selectionListState);
    
              Services.getDetails(jsonString).then((details) {
                final List<DetailElement> jsonStringData = details;
        
                print("==================================");
                print("Details: " + jsonStringData.toString());
                print("==================================");
        
                // updating details list returned from API using Riverpod
                detailListController.updateDetailList(jsonStringData);
    
                Navigator.pushNamed(context, "/result");
              });
            },
          ),

          const SizedBox(height: 16),

          FloatingActionButton(
            tooltip: "Debug that shown in Snackbar",
            heroTag: "snack",
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.miscellaneous_services),
            onPressed: () async {
              final jsonString = selectionParameterToJson(selectionListState);

              final snackBar = SnackBar(
                content: Text("Selection input: " + jsonString),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {},
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ],
      ),
    );
  }
}