import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';
import '../classes/global.dart';
import 'chat_page.dart';

/// This is ChatListScreen. This screen lists all the Devices with which the
/// device has chat with and keeps all the previous messages records.

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _conversers = [];
  List<String> _filteredConversers = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterConversers);
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterConversers);
    _searchController.dispose();
    super.dispose();
  }

  /// Loads all conversations and updates the cache
  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    await Future.wait([
      readAllUpdateConversation(context),
      Future(() => readAllUpdateCache()),
    ]);
    _updateConversersList();
    setState(() => _isLoading = false);
  }



  /// Updates the list of conversers from the global conversations
  void _updateConversersList() {
    final conversations = Provider.of<Global>(context, listen: false).conversations;
    setState(() {
      _conversers = conversations.keys.toList();
      _filterConversers();
    });
  }

  /// Filters conversers based on search text
  void _filterConversers() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filteredConversers = _conversers
          .where((converser) =>
          converser.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  /// Builds the search bar widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: "Search chats...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              onChanged: (value) => _filterConversers(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _loadConversations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh chats',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual chat list item
  Widget _buildChatListItem(String converser) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.person,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          converser,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Tap to view chat',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(converser: converser),
          ),
        ),
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No chats found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a chat from the devices list',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_filteredConversers.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    itemCount: _filteredConversers.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (context, index) =>
                        _buildChatListItem(_filteredConversers[index]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
