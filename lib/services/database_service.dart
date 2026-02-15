import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _pulseRef => _db.collection('pulse_history');
  CollectionReference get _breathingRef => _db.collection('breathing_history');

  Future<void> createUserData(String name, String email) async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      await _usersRef.doc(uid).set({
        'name': name,
        'email': email,
        'age': 25,
        'weight': 70,
        'height': 175,
        'bloodType': 'A+',
        'notifications': true,
        'lastLogin': FieldValue.serverTimestamp(),
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('${'Ошибка создания профиля'.tr()}: $e');
    }
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _usersRef.doc(uid).snapshots();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _currentUid;
    if (uid == null) return null;

    try {
      final doc = await _usersRef.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _usersRef.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> savePulseData(int bpm, int minBpm, int maxBpm, int spo2, String stress) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _pulseRef.add({
      'uid': uid,
      'bpm': bpm,
      'min': minBpm,
      'max': maxBpm,
      'spo2': spo2,
      'stress': stress,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPulseHistory(String uid, {int? limit}) {
    Query query = _pulseRef
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots();
  }

  Stream<QuerySnapshot> getAllMeasurements() {
    final uid = _currentUid;
    if (uid == null) return const Stream.empty();

    return _pulseRef
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> saveBreathingData(int rate, int count, int duration) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _breathingRef.add({
      'uid': uid,
      'rate': rate,
      'count': count,
      'duration': duration,
      'type': 'breathing',
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getBreathingHistory(String uid, {int? limit}) {
    Query query = _breathingRef
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots();
  }

  Future<void> addMedicine(String name, String dose, String time, int notificationId) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _usersRef.doc(uid).collection('user_medicines').add({
      'name': name,
      'dose': dose,
      'time': time,
      'isTaken': false,
      'notificationId': notificationId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMedicinesStream() {
    final uid = _currentUid;
    if (uid == null) return const Stream.empty();

    return _usersRef
        .doc(uid)
        .collection('user_medicines')
        .orderBy('time')
        .snapshots();
  }

  Future<void> toggleMedicineTaken(String docId, bool currentStatus) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _usersRef.doc(uid).collection('user_medicines').doc(docId).update({
      'isTaken': !currentStatus,
    });
  }

  Future<void> deleteMedicine(String docId) async {
    final uid = _currentUid;
    if (uid == null) return;

    await _usersRef.doc(uid).collection('user_medicines').doc(docId).delete();
  }

  Future<void> saveMedicineList(List<Map<String, dynamic>> medicines) async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      await _db.collection('medicines').doc(uid).set({
        'medicines': medicines,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Ошибка сохранения лекарств'.tr());
    }
  }

  Future<List<Map<String, dynamic>>> getMedicineList() async {
    final uid = _currentUid;
    if (uid == null) return [];

    try {
      final doc = await _db.collection('medicines').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('medicines')) {
          return List<Map<String, dynamic>>.from(data['medicines']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }
}
