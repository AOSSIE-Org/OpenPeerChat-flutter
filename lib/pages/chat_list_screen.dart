import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/database/database_helper.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import 'chat_page.dart';

/// ChatListScreen: Lists all devices the user has chatted with and keeps a record of messages.
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
  bool _hasError = false;
  String _errorMessage = '';

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

  /// Loads all conversations and handles errors
  Future<void> _loadConversations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await readAllUpdateConversation(context);
      readAllUpdateCache(); // This is called without await since it returns void
      _updateConversersList();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load conversations: $e';
      });
      _showErrorSnackBar();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _updateConversersList() {
    if (!mounted) return;

    final global = Provider.of<Global>(context, listen: false);
    setState(() {
      _conversers =
          global.conversations.keys.where((key) => key.isNotEmpty).toList();
      _filterConversers();
    });
  }

  void _filterConversers() {
    if (!mounted) return;

    final searchText = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredConversers = searchText.isEmpty
          ? List.from(_conversers)
          : _conversers
          .where((converser) => converser.toLowerCase().contains(searchText))
          .toList();
    });
  }


  /// Shows a snackbar for errors
  void _showErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadConversations,
        ),
      ),
    );
  }

  /// Navigates to the chat page
  void _navigateToChatPage(String converser) {
    if (!mounted || converser.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(converser: converser),
      ),
    ).then((_) => _loadConversations());
  }

  /// Builds the search bar widget
  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _loadConversations,
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Refresh conversations',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Builds a chat list item
  Widget _buildChatListItem(String converser) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
        child: Icon(Icons.person, color: Theme
            .of(context)
            .colorScheme
            .primary),
      ),
      title: Text(
          converser, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Tap to view chat'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _navigateToChatPage(converser),
    );
  }

  /// Builds the empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No conversations found'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Global>(
        builder: (context, global, child) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Stack(
                  children: [
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_hasError)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage),
                            ElevatedButton(
                              onPressed: _loadConversations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_filteredConversers.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          itemCount: _filteredConversers.length,
                          itemBuilder: (context, index) {
                            return _buildChatListItem(_filteredConversers[index]);
                          },
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}