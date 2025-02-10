import 'dart:async';

import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';
import '../classes/global.dart';
import '../database/message_db.dart';
import '../p2p/adhoc_housekeeping.dart';
import 'chat_page.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isInit = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  List<String> filteredConversers = [];
  Global? globalProvider;

  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    globalProvider = Provider.of<Global>(context, listen: false);
    globalProvider?.addListener(_handleGlobalUpdate);
    searchController.addListener(_filterConversers);
    _updateFilteredConversers();
    readAllUpdateCache();
    loadUserNames(context);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      globalProvider = Provider.of<Global>(context, listen: false);
      _setupProfileSync();
      isInit = true;
    }
  }

  void _setupProfileSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted && globalProvider!.connectedDevices.isNotEmpty) {
        broadcastProfileUpdate(context);
      }
    });
  }

  void _handleGlobalUpdate() {
    if (mounted) {
      _updateFilteredConversers();
    }
  }

  void _updateFilteredConversers() {
    if (mounted) {
      setState(() {
        if (searchController.text.isEmpty) {
          filteredConversers = globalProvider?.conversations.keys.toList() ?? [];
        } else {
          _filterConversers();
        }
      });
    }
  }

  void _filterConversers() {
    if (mounted && globalProvider != null) {
      setState(() {
        filteredConversers = globalProvider!.conversations.keys
            .where((converserId) =>
            globalProvider!.getUserName(converserId)
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  Future<String> getConverserName(String converserId) async {
    // First try to get the name from the Global provider for real-time updates
    final currentName = globalProvider?.getUserName(converserId);
    if (currentName != null && currentName != converserId) {
      return currentName;
    }

    // Fallback to database if not found in Global
    final userData = await MessageDB.instance.getUserName(converserId);
    final dbName = userData?.displayName;

    // Update Global provider with the database name if available
    if (dbName != null && dbName != converserId && globalProvider != null) {
      globalProvider!.handleProfileUpdate(converserId, dbName);
    }

    return dbName ?? converserId;
  }


  @override
  void dispose() {
    searchController.removeListener(_filterConversers);
    globalProvider?.removeListener(_handleGlobalUpdate);
    searchController.dispose();
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
            ),
          ),
        ),
        Expanded(
      child: ListView.builder(
        itemCount: filteredConversers.length,
        itemBuilder: (context, index) {
          final converserId = filteredConversers[index];
          return Selector<Global, String>(
            selector: (_, global) => global.getUserName(converserId),
            builder: (_, converserName, __) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(converserName),
                      subtitle: Text(converserId),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              converserName: converserName,
                              converserId: converserId,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.grey),
                  ],
                ),
              );
            },
          );
        },
      ),
    ),
      ],
    );
  }
}
