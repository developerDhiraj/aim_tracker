import 'package:aim_tracker/models/activity_log.dart';
import 'package:aim_tracker/services/local_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}
List <Activity> activities = [];



class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState(){
    super.initState();
    _printAllActivities();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final db = ActtivityDatabase.instance;
    final allActivities = await db.readAllActivities();

    setState(() {
      activities = allActivities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Aim Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: activities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6),
              itemBuilder: (context, index){
                final activity = activities[index];
                return quadrant(activity: activity);
            },

            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  SystemNavigator.pop();
                },
                child: Container(
                  width: 150,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFBABA),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text("QUIT", style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(width: 10,),
              Text("Made By Dhiraj",style: TextStyle(color: Colors.grey),)
            ],
          ),
        ],
      ),
    );
  }

  Widget quadrant ({required Activity activity}) {

    return Container(
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                color: Color(0xFFD9D9D9),
                padding: EdgeInsets.only(top: 8, left: 16),
                child: Text(activity.title, style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                ),),
              ),
              Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () async{
                      // Show input dialog
                      final newTitle = await _showEditDialog(context, activity.title);
                      // If user input new title, update to DB
                      if (newTitle != null && newTitle.isNotEmpty){
                        final db = ActtivityDatabase.instance;
                        final existing = await db.readActivity(activity.id ?? 0);

                        if (existing != null){
                          await db.update(
                             existing.copy(
                               title: newTitle,
                               lastDone: DateTime.now()
                             )
                          );
                        }
                        setState(() {
                          _loadActivities();
                          print(existing?.id);
                          print(ActivityFields.id);
                          // print(activity.id);
                        });
                      }
                    },
                      child: Icon(Icons.edit)))
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Total - ${activity.total}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          final db = ActtivityDatabase.instance;
                          final existing = await db.readActivity(activity.id!);
                          if (existing != null){
                            final updatedActivity = existing.copy(
                              total: existing.total +1,
                              lastDone: DateTime.now(),
                            );
                            await db.update(updatedActivity);
                            setState(() {
                              _loadActivities();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            "+ Add Today",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Wrap(
                      spacing: 4,
                      children:
                        List.generate(
                            activity.total, (index) => const Icon( Icons.star, color: Colors.amber, size: 20,))
                      ,
                    ),
                  ),
                  Text(
                    "Your last ${activity.title}\nin ${_formatLastDone(activity.lastDone)}",textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastDone(DateTime? date){
    if (date == null) return "No Record Yet";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doneDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(doneDate).inDays;
    print(difference);
    if (difference == 0) {
      return "Today";
    } else if (difference == 1){
      return "Yesterday";
    } else {
      return "${date.day} ${_getMonthName(date.month)} ${date.year}";
    }
  }

  String _getMonthName(int month){
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month -1];
  }



  Future<String?> _showEditDialog(BuildContext context, String currentTitle) async {
    final TextEditingController controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Edit Title"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Enter New Title"
              ),
            ),
            actions: [
              TextButton(
                  onPressed: ()=>Navigator.pop(context),
                  child: const Text("Cancel"),
              ),
              TextButton(
                  onPressed: ()=>Navigator.pop(context, controller.text),
                  child: const Text("Save"),)
            ],
          );
        },
    );
  }

  Future<void> _printAllActivities() async {
    final db = ActtivityDatabase.instance;
    final activities = await db.readAllActivities();

    if (activities.isEmpty) {
      print("📭 Database is empty");
    } else {
      print("✅ Database contains:");
      for (var activity in activities) {
        print(
            "ID: ${activity.id}, Title: ${activity.title}, Total: ${activity.total}, LastDone: ${activity.lastDone}");
      }
    }
  }
}


