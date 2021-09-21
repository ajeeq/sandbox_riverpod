// Import directives
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sandbox_riverpod/providers/campus_providers.dart';
import 'package:sandbox_riverpod/providers/group_providers.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widgets
import 'package:sandbox_riverpod/sandboxes/schedulerv0.1/widgets/course_autocomplete.dart';
import 'package:sandbox_riverpod/sandboxes/schedulerv0.1/widgets/group_autocomplete.dart';

// API Services
import 'package:sandbox_riverpod/services.dart';

// Models
import 'package:sandbox_riverpod/models/campus.dart';
import 'package:sandbox_riverpod/models/course.dart';
import 'package:sandbox_riverpod/models/selection_parameter.dart';

// Providers
import 'package:sandbox_riverpod/providers/course_providers.dart';
import 'package:sandbox_riverpod/providers/selection_providers.dart';

// TODO: Please change to ConsumerStatefulWidget
// TODO: Rename notifiers object to controller
class Selection extends StatefulWidget {
  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  bool isLoading = false;
  List<String> _campuses = [];
  
  late List<String> autoCompleteData;
  late TextEditingController controller;

  late String _selectedCampus;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    Services.getCampuses().then((campuses) {
      final List<CampusElement> jsonStringData = campuses;

      List<String> l = [];
      for(int i=0; i<jsonStringData.length; i++)
        jsonStringData.forEach((e) => l.add(e.campus));

      print("==================================");
      print(l);
      print("==================================");

      setState(() {
        _campuses = l;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector (
    onTap: () => FocusScope.of(context).unfocus(),
    child: Consumer(
       builder: (context, WidgetRef ref, child) {
        // declaring riverpod state providers
        final courseNameState = ref.watch(courseNameProvider);
        final groupNameState = ref.watch(groupNameProvider);
        final selectionListState = ref.watch(selectionListProvider);

        // declaring notifiers for updating riverpod states
        final CampusNameNotifier campusN = ref.read(campusNameProvider.notifier);
        final CourseListNotifier courseListN = ref.read(courseListProvider.notifier);
        final SelectionListNotifier selectionListN = ref.read(selectionListProvider.notifier);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Add Course"),
          ),
          body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                reverse: true,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Campus',
                            style: TextStyle(
                              fontFamily: 'avenir',
                              fontSize: 32,
                              fontWeight: FontWeight.w900
                            ),
                          ),
                          
                          Autocomplete(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              } else {
                                return _campuses.where((word) => word
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase()));
                              }
                            },
                            optionsViewBuilder: (context, Function(String) onSelected, options) {
                              return Material(
                                elevation: 4,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  separatorBuilder: (context, index) => Divider(),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                
                                    return ListTile(
                                      title: SubstringHighlight(
                                        text: option.toString(),
                                        term: controller.text,
                                        textStyleHighlight: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      onTap: () {
                                        onSelected(option.toString());
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            onSelected: (selectedString) async {
                              _selectedCampus = selectedString.toString();

                              // updating selected campus name in state(riverpod)
                              campusN.updateSelectedCampusName(_selectedCampus);

                              print("==================================");
                              print("Campus selected: " + _selectedCampus);
                              print("==================================");
                        
                              Services.getCourses(selectedString).then((courses) {
                                final List<CourseElement> jsonStringData = courses;
                        
                                List<String> l = [];
                                for(int i=0; i<jsonStringData.length; i++)
                                  jsonStringData.forEach((e) => l.add(e.course));
      
                                print("==================================");
                                print(l);
                                print("==================================");

                                // updating course list state using Riverpod
                                courseListN.updateCourseList(l);
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              this.controller = controller;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  hintText: "Search campus here",
                                  prefixIcon: Icon(Icons.search),
                                  suffixIcon: IconButton(
                                    onPressed: () => controller.clear(), 
                                    icon: Icon(Icons.clear)
                                  )
                                ),
                              );
                            },
                          ),
                        ],
            
                      ),
                    ),
                  
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. Course',
                            style: TextStyle(
                              fontFamily: 'avenir',
                              fontSize: 32,
                              fontWeight: FontWeight.w900
                            ),
                          ),
      
                          CourseAutocomplete(),
                        ]
                      )
                    
                    ),
                  
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3. Group',
                            style: TextStyle(
                              fontFamily: 'avenir',
                              fontSize: 32,
                              fontWeight: FontWeight.w900
                            ),
                          ),
      
                          GroupAutocomplete(),
                        ]
                      )
                    
                    ),
                  
                  ],
                ),
              ),
      
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: Colors.lightBlue,
                icon: const Icon(Icons.done),
                label: const Text('Done'),
                onPressed: () async {
                  // adding user course selection using Riverpod
                  selectionListN.addSelection(SelectionParameter(
                    campusSelected: _selectedCampus,
                    courseSelected: courseNameState.toString(),
                    groupSelected: groupNameState.toString()
                  ));
                  // Unhandled Exception: type 'List<SelectionParameter>' is not a subtype of type 'String'
                  
                  print("==================================");
                  print("Updated CourseListInputProvider-courseList: " + selectionListState.toString());
                  print("==================================");
      
                  Navigator.pop(context);
                },
              ),
        );
       }
    ),

  );
}