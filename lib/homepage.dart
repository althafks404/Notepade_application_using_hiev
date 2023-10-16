import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loading_indicator/loading_indicator.dart';

class hiveoperation extends StatefulWidget {
  const hiveoperation({super.key});

  @override
  State<hiveoperation> createState() => _hiveoperationState();
}

class _hiveoperationState extends State<hiveoperation> {
  List<Map<String,dynamic>> task = [];
  @override
  void initState() {
    // TODO: implement initState
    loadTask();
    super.initState();
  }

  void loadTask(){
    final task_from_hive = mybox.keys.map((data) {   //fetch all the keys from hive in ascending order
      final value = mybox.get(data);  //all the values of each individual key from the box
      return {
        'id' : data,
        'task':value['task name'],
        'content':value['content name']
      };
    }).toList();
    setState(() {
      task = task_from_hive.reversed.toList();
      //task = task_from_hive.reversed.toList();
    });
  }

  final mybox = Hive.box('to_do Box');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Hive Operation"),
        centerTitle: true,
      ),
      body:task.isEmpty ? Column(mainAxisAlignment:MainAxisAlignment.center,children:[LoadingIndicator(indicatorType: Indicator.pacman ,colors: [Colors.amberAccent],),Text("Press + button add task")]) : ListView.builder(itemBuilder: (context,index) {
        final mytask = task[index];   //fetch each single map from list
        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            color:Colors.blueAccent,
            child:ListTile(
              title:Text(mytask['task']),
              subtitle: Text(mytask['content']),
              trailing: Wrap(
                children: [
                  IconButton(onPressed: () {
                    showTask(mytask['id'], context);
                  }, icon: Icon(Icons.edit)),
                  SizedBox(width:10),
                  IconButton(onPressed: () {
                    deleteTask(mytask['id'],mytask['task']);
                  }, icon: Icon(Icons.delete)),
                ],
              ),
            )
        );
      },itemCount: task.length,),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => showTask(null,context),
          label: const Text("Add Task"),icon:const Icon(Icons.add)),
    );
  }
  final taskname = TextEditingController();
  final contentname = TextEditingController();
  showTask(int? key, BuildContext context) {  //similar to id in sqfLite
    if(key != null){
      final existingtask = task.firstWhere((element) => element['id'] == key);
      taskname.text  = existingtask['task'];
      contentname.text = existingtask['content'];
    }
    showModalBottomSheet(context: context,isScrollControlled: true, builder: (context){
      return Container(
          padding:const EdgeInsets.only(top:15,left:15,right:15,bottom: 150),
          child:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskname,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),hintText: "Task Name",
                ),
              ),
              SizedBox(height:30),
              TextField(
                controller: contentname,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),hintText: "Task Content",
                ),
              ),
              SizedBox(height:30),
              ElevatedButton(onPressed: () {
                if(taskname != "" && contentname != ""){
                  if(key==null){
                    createTask({
                      'task name' : taskname.text.trim(),
                      'content name':contentname.text.trim()
                    });
                  }
                  else{
                    updateTask(key,{
                      'task name' : taskname.text.trim(),  // trim is used to avoid space in the starting and ending
                      'content name':contentname.text.trim()
                    });
                  }
                }
                contentname.text = "";
                taskname.text = "";
                Navigator.of(context).pop();
              }, child: Text(key == null ? 'Create Task ': 'Update Task'))

            ],
          )
      );
    });
  }



  Future<void> createTask(Map<String, String> task)async{
    await mybox.add(task);
    loadTask();
  }

  Future<void> updateTask(int? key, Map<String, String> updateTask) async{
    await  mybox.put(key,updateTask);
    loadTask();
  }

  Future<void> deleteTask(int ? key,String taskname) async{
    await mybox.delete(key);
    loadTask();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("successfully deleted $taskname")));
  }
}

void main() async{
  await Hive.initFlutter();
  await Hive.openBox('to_do Box');
  runApp(MaterialApp(home:hiveoperation(),));
}