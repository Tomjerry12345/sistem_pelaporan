import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sistem_pelaporan/values/output_utils.dart';

class FirebaseServices {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getUser() => _auth.currentUser;

  Future<void> signOut() => _auth.signOut();

  Future<UserCredential> registerWithEmailAndPassword(
          String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signInWithEmailAndPassword(
          String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future addDataCollection(String collection, Map<String, dynamic> data) =>
      _db.collection(collection).add(data);

  Stream<QuerySnapshot<Map<String, dynamic>>>? getDataStreamCollection(
      String collection,
      {String orderBy = ""}) {
    CollectionReference<Map<String, dynamic>> col = _db.collection(collection);
    final snap = orderBy == "" ? col : col.orderBy(orderBy);
    snap.snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDataStreamDoc(
          String collection, String doc) =>
      _db.collection(collection).doc(doc).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataQueryStream(
      String collection, List<Map> query,
      {String orderBy = ""}) {
    CollectionReference<Map<String, dynamic>> col = _db.collection(collection);

    query.forEach((e) {
      col.where(e["key"], isEqualTo: e["value"]);
    });
    final snap = orderBy == "" ? col : col.orderBy(orderBy);
    return snap.snapshots();
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getDataTwoQueryStream(
  //         String collection,
  //         String query,
  //         dynamic value,
  //         String query1,
  //         dynamic value1) =>
  //     _db
  //         .collection(collection)
  //         .where(query, isEqualTo: value)
  //         .where(query1, isEqualTo: value1)
  //         .snapshots();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDataCollection(
      String collection) async {
    final data = await _db.collection(collection).get();

    return data.docs;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDataDoc(
      String collection, String doc) async {
    final data = await _db.collection(collection).doc(doc).get();

    return data;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getDataCollectionByQuery(
          String collection, String query, dynamic value) async {
    final data =
        await _db.collection(collection).where(query, isEqualTo: value).get();

    return data.docs;
  }

  Future<void> updateDataAllDoc(String collection, String doc, data) async =>
      _db.collection(collection).doc(doc).set(data);

  Future<void> updateDataSpecifictDoc(
          String collection, String doc, data) async =>
      _db.collection(collection).doc(doc).update(data);

  Future<void> updateDataCollectionByQuery(
      String collection, String query, dynamic value) async {
    final res =
        await _db.collection(collection).where(query, isEqualTo: value).get();
    logO("res", m: res.size);
    await res.docs[0].data().update(query, value);
  }

  void updateDataCollectionByTwoQuery(String collection, String query,
      dynamic value, String query1, dynamic value1) async {
    final res =
        await _db.collection(collection).where(query, isEqualTo: value).get();

    final ref = res.docs[0].reference;

    final batch = _db.batch();
    batch.update(ref, {query1: value1});
    batch.commit();
  }

  Future<void> deleteDoc(String collection, String doc) async =>
      _db.collection(collection).doc(doc).delete();

  Future uploadFile(File file, String type) async {
    String fileName = basename(file.path);
    final firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$type/$fileName');
    final uploadTask = await firebaseStorageRef.putFile(file);
    final taskSnapshot = uploadTask.ref.getDownloadURL();
    return taskSnapshot;
  }
}
