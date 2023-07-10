import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_month_picker/flutter_month_picker.dart';
import 'package:hoost_mvp/model/user_model.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class InsertData extends StatefulWidget {
  const InsertData({Key? key}) : super(key: key);

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final DateTime _date = DateTime.now();
  DateTime? _dateFin = DateTime.now();
  DateTime? _dateDebut = DateTime.now();

  final CollectionReference _post =
      FirebaseFirestore.instance.collection('posts');
  

  Future<void> _create(UserModel User,[DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'lieu'),
                ),
                TextField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  child: const Text('Date de début'),
                  onPressed: () async {
                    _dateDebut = await showMonthPicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _date,
                        lastDate: DateTime(2100));
                  },
                ),
                ElevatedButton(
                  child: const Text('Date de fin'),
                  onPressed: () async {
                    _dateFin = await showMonthPicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _date,
                        lastDate: DateTime(2100));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    final String lieu = _nameController.text;
                    final String description = _description.text;
                    final String dateFin = _dateFin.toString();
                    final String dateDebut = _dateDebut.toString();
                    final String uid = User.uid;
                    final String nameUser = User.name;
                    final String profilPicUser = User.profilePic;
                    final String emailUser = User.email;
                    await _post.add({
                      "lieu": lieu,
                      "description": description,
                      "date_debut": dateDebut,
                      "date_fin": dateFin,
                      "uidUser": uid,
                      "nameUser": nameUser,
                      "profilPicUser": profilPicUser,
                      "emailUser": emailUser
                    });

                    _dateDebut = DateTime.now();
                    _dateFin = DateTime.now();
                    _nameController.text = '';
                    _description.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['lieu'];
      _description.text = documentSnapshot['description'];
      _dateDebut = DateTime(documentSnapshot['dateDebut']);
      _dateFin = DateTime(documentSnapshot['dateFin']);
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'lieu'),
                ),
                TextField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Desc'),
                ),
                ElevatedButton(
                  child: const Text('Date de début'),
                  onPressed: () async {
                    _dateDebut = await showMonthPicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _date,
                        lastDate: DateTime(2100));
                  },
                ),
                ElevatedButton(
                  child: const Text('Date de fin'),
                  onPressed: () async {
                    _dateFin = await showMonthPicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _date,
                        lastDate: DateTime(2100));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String lieu = _nameController.text;
                    final String description = _description.text;
                    final String dateFin = _dateFin.toString();
                    final String dateDebut = _dateDebut.toString();
                    await _post.doc(documentSnapshot!.id).update({
                      "lieu": lieu,
                      "description": description,
                      "date_debut": dateDebut,
                      "date_fin": dateFin
                    });
                    _dateDebut = DateTime.now();
                    _dateFin = DateTime.now();
                    _nameController.text = '';
                    _description.text = '';
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _post.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final query = _post.where("uidUser", isEqualTo: ap.uid);
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Mes posts')),
        ),
        body: StreamBuilder(
          stream: query.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  final String yearDebut =
                      DateTime.parse(documentSnapshot['date_debut'])
                          .year
                          .toString();
                  final String monthDebut =
                      DateTime.parse(documentSnapshot['date_debut'])
                          .month
                          .toString();
                  final String yearFin =
                      DateTime.parse(documentSnapshot['date_fin'])
                          .year
                          .toString();
                  final String monthFin =
                      DateTime.parse(documentSnapshot['date_fin'])
                          .month
                          .toString();
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['lieu']),
                      subtitle: Text(documentSnapshot['description'] +
                          ' Durée : ' +
                          yearDebut +
                          ' - ' +
                          monthDebut +
                          ' à ' +
                          yearFin +
                          ' - ' +
                          monthFin),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _update(documentSnapshot)),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(documentSnapshot.id)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
// Add new product
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(ap.userModel),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
