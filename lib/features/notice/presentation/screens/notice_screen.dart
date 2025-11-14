import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/connectivity_service.dart';
import 'package:EduLink/core/services/local_db_helper.dart';
import 'package:EduLink/features/notice/presentation/screens/add_notice_screen.dart';
import 'package:EduLink/features/notice/presentation/screens/notice_details_screen.dart';
import 'package:EduLink/features/notice/presentation/widgets/linkify_description.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';
import 'package:EduLink/features/shared/presentaion/widgets/icon_filled_button.dart';
import '../../data/models/notice_model.dart';
import 'package:EduLink/app/collections.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final _connectivity = ConnectivityService();
  final _dbHelper = LocalDbHelper.getInstance();
  late Future<List<NoticeModel>> _noticesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noticesFuture = _fetchNotices();

    // Listen to connectivity changes
    _connectivity.isOffline.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (mounted && !_isLoading) {
      _loadNotices();
    }
  }

  void _loadNotices() {
    if (!mounted || _isLoading) return;

    _isLoading = true;
    setState(() {
      _noticesFuture = _fetchNotices();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _isLoading = false;
      }
    });
  }

  Future<List<NoticeModel>> _fetchNotices() async {
    if (!mounted) return [];

    try {
      if (_connectivity.isOffline.value == false) {
        debugPrint("📡 Fetching notices from Firestore...");

        final snapshot = await FirebaseFirestore.instance
            .collection(Collectons.classes)
            .doc(AuthController.classDocId)
            .collection(Collectons.notice)
            .orderBy('createdAt', descending: true)
            .get();

        if (!mounted) return [];

        debugPrint("✅ Fetched ${snapshot.docs.length} notices from Firestore");

        final notices = snapshot.docs
            .map((e) => NoticeModel.fromFireStore(e.data(), e.id))
            .toList();

        // Cache notices in background
        Future.microtask(() async {
          for (var notice in notices) {
            await _dbHelper.insertNotice(notice, AuthController.classDocId!);
          }
        });

        return notices;
      } else {
        debugPrint("📴 Fetching notices from Local DB...");
        final notices = await _dbHelper.getAllNotice(AuthController.classDocId!);
        debugPrint("✅ Fetched ${notices.length} notices from local DB");
        return notices;
      }
    } catch (e) {
      debugPrint("❌ Error fetching notices: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notice"),
        actions: [
          // Show offline indicator
          if (_connectivity.isOffline.value)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_off, color: Colors.grey),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<NoticeModel>>(
              future: _noticesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text("Error fetching notices"),
                        Text(
                          "${snapshot.error}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No notices found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notices = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    if (!_connectivity.isOffline.value) {
                      _loadNotices();
                      await _noticesFuture;
                    }
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final notice = notices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Published on: ${formatDate(notice.createdAt)}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinkifyDescription(
                                    description: notice.description),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        NoticeDetailsScreen.name,
                                        arguments: notice,
                                      );
                                    },
                                    child: const Text(
                                      "Read More",
                                      style: TextStyle(
                                          color: AppColors.themeColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (AuthController.isAdmin)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconFilledButton(
                onTap: () async {
                  final result =
                  await Navigator.pushNamed(context, AddNotice.name);
                  if (result == true) {
                    _loadNotices();
                  }
                },
                title: 'Add Notice',
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isLoading = false;
    _connectivity.isOffline.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}