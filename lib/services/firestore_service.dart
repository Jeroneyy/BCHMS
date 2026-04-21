import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore CRUD helper.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Create ──────────────────────────────────────────────────────────
  Future<String> add(String collection, Map<String, dynamic> data) async {
    final doc = await _db.collection(collection).add(data);
    return doc.id;
  }

  Future<void> set(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  // ── Read ────────────────────────────────────────────────────────────
  Future<DocumentSnapshot> get(String collection, String docId) async {
    return await _db.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getAll(String collection, {
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    Query query = _db.collection(collection);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  Future<QuerySnapshot> query(String collection, {
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    Query query = _db.collection(collection).where(field, isEqualTo: value);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  Stream<QuerySnapshot> streamAll(String collection, {
    String? orderBy,
    bool descending = true,
    int? limit,
  }) {
    Query query = _db.collection(collection);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> streamQuery(String collection, {
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = true,
  }) {
    Query query = _db.collection(collection).where(field, isEqualTo: value);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots();
  }

  // ── Update ──────────────────────────────────────────────────────────
  Future<void> update(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  // ── Delete ──────────────────────────────────────────────────────────
  Future<void> delete(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // ── Count ───────────────────────────────────────────────────────────
  Future<int> count(String collection) async {
    final snap = await _db.collection(collection).count().get();
    return snap.count ?? 0;
  }

  Future<int> countWhere(String collection, String field, dynamic value) async {
    final snap = await _db
        .collection(collection)
        .where(field, isEqualTo: value)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
