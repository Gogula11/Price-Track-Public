import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get _db {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  String? userEmail;

  // --- Tracked Products ---

  Future<void> trackProduct({
    required String productId,
    required String productName,
    required String productImage,
    required String price,
    required String targetPrice,
    required String productUrl,
    required String source,
  }) async {
    final email = userEmail;
    if (email == null) return;

    await _db
        .collection('users')
        .doc(email)
        .collection('trackedProducts')
        .doc(productId)
        .set({
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'setTrackingPrice': targetPrice,
      'asinOrPid': productId,
      'productUrl': productUrl,
      'source': source,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> untrackProduct(String productId) async {
    final email = userEmail;
    if (email == null) return;

    await _db
        .collection('users')
        .doc(email)
        .collection('trackedProducts')
        .doc(productId)
        .delete();
  }

  Future<bool> isProductTracked(String productId) async {
    final email = userEmail;
    if (email == null) return false;

    final doc = await _db
        .collection('users')
        .doc(email)
        .collection('trackedProducts')
        .doc(productId)
        .get();

    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> getTrackedProductsStream() {
    final email = userEmail;
    if (email == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(email)
        .collection('trackedProducts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // --- Search History ---

  Future<List<String>> getSearchHistory() async {
    final email = userEmail;
    if (email == null) return [];

    final doc = await _db.collection('users').doc(email).get();
    return List<String>.from(doc.data()?['searchHistory'] ?? []);
  }

  Future<void> saveSearchQuery(String query) async {
    final email = userEmail;
    if (email == null) return;

    await _db.collection('users').doc(email).set({
      'searchHistory': FieldValue.arrayUnion([query])
    }, SetOptions(merge: true));
  }

  Future<void> deleteSearchQuery(String query) async {
    final email = userEmail;
    if (email == null) return;

    await _db.collection('users').doc(email).update({
      'searchHistory': FieldValue.arrayRemove([query])
    });
  }

  Future<void> clearSearchHistory() async {
    final email = userEmail;
    if (email == null) return;

    await _db.collection('users').doc(email).update({
      'searchHistory': [],
    });
  }

  // --- Price History ---

  Stream<Map<String, dynamic>?> getPriceHistoryStream(String productId) {
    return _db
        .collection('priceHistory')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.data());
  }

  Stream<List<Map<String, dynamic>>> getPriceEntriesStream(String productId) {
    return _db
        .collection('priceHistory')
        .doc(productId)
        .collection('priceEntries')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                {'id': doc.id, 'price': doc['price']?.toString() ?? ''})
            .toList());
  }

  Future<Map<String, dynamic>?> getPriceHistory(String productId) async {
    final doc = await _db.collection('priceHistory').doc(productId).get();
    return doc.data();
  }
}
