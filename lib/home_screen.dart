import 'package:crude/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

//get all data from database
  void _refreshData() async{
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState(){
    super.initState();
    _refreshData();
  }

 

//new data
  Future<void> _addData() async{
    await SQLHelper.createData(_titleControler.text, _descControler.text);
    _refreshData();
  }

//update
Future<void> _updateData(int id) async{
  await SQLHelper.updateData(id, _titleControler.text, _descControler.text);
  _refreshData();
}

//delete
void _deleteData(int id) async{
  await SQLHelper.deleteData(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    backgroundColor: Colors.redAccent,
    content: Text("Deletado com sucesso"))
  );

  _refreshData();
}
 final TextEditingController _titleControler = TextEditingController();
final TextEditingController _descControler = TextEditingController();

void showBottomSheet(int? id) async{
  if(id!=null){
    final existingData = _allData.firstWhere((element) => element['id']==id);
    _titleControler.text = existingData['title'];
    _descControler.text = existingData['desc'];
  }

  showModalBottomSheet(
    elevation: 5,
    isScrollControlled: true,
    context: context, 
    builder: (_) => Container(
      padding: EdgeInsets.only(
        top: 30, 
        left: 15, 
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end ,
          children: [

            TextField(
              controller: _titleControler,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            const SizedBox(height: 10,),
             TextField(
              controller: _descControler,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Descrição",
              ),
            ),
            const SizedBox(height: 10,),

            Center(
              child: ElevatedButton(
                onPressed: () async{
                  if(id == null){
                    await _addData();
                  }
                  if(id != null){
                    await _updateData(id);
                  }

                  _titleControler.text = "";
                  _descControler.text = "";
//hide bottom sheet
                  Navigator.of(context).pop();
              

                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null? "Add Data" : "Update",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ),
              )
            ),



          ],
        ),
    ),
    );
}


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xffefeceaf4),
      appBar: AppBar(
        title: const Text("Crud Opereations"),
      ),
      body: _isLoading ? 
        const Center (child: CircularProgressIndicator(),
        )
        : ListView.builder(
          itemCount: _allData.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.all(15),
            child: ListTile(
             title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  _allData[index]['title'],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              subtitle: Text(_allData[index]['desc']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: (){
                      showBottomSheet(_allData[index]['id']);
                    }, 
                    icon: const Icon(Icons.edit,
                    color: Colors.indigo,
                    
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      _deleteData(_allData[index]['id']);
                    }, 
                    icon: const Icon(Icons.delete,
                    color: Colors.redAccent,
                    
                    ),
                  ),
                ],
                ),
            ),
          ), 
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: const Icon(Icons.add),
          
        ),
      );
  }
}