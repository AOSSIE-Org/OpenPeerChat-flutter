import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import 'chat_page.dart';
import '../p2p/adhoc_housekeeping.dart';

/// This is the DeviceListScreen page. This page task is to display the
/// devices in the range that are active now. It is used to manage the
/// connection between devices. We can either connect or disconnect
/// with any device in the range.
/// This is the Frontend of the Devices management, the backend is managed
/// with the help of Provider and AdhocHouseKeeping.

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({Key? key, required this.deviceType}) : super(key: key);
  final DeviceType deviceType;

  @override
  State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  late final Global _global;
  List<Device> _filteredDevices = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isInit = false;

  /// Getters for filtered device lists
  List<Device> get _connectedDevices =>
      _filteredDevices
          .where((device) => device.state == SessionState.connected)
          .toList();

  List<Device> get _availableDevices =>
      _filteredDevices
          .where((device) => device.state != SessionState.connected)
          .toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _global = Provider.of<Global>(context, listen: false);
      _global.addListener(_handleGlobalUpdate);
      _updateFilteredDevices();
      _isInit = true;
      
      if (_filteredDevices.isEmpty) {
        _startInitialScan();
      }
    }
  }

  void _handleGlobalUpdate() {
    if (mounted) {
      _updateFilteredDevices();
    }
  }

  void _updateFilteredDevices() {
    if (mounted) {
      setState(() {
        if (_searchController.text.isEmpty) {
          _filteredDevices = _global.devices;
        } else {
          _filterDevices();
        }
      });
    }
  }

  /// Starts initial device scan with loading indicator
  void _startInitialScan() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _filterDevices();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDevices);
    _global.removeListener(_handleGlobalUpdate);
    _searchController.dispose();
    super.dispose();
  }


  /// Refreshes the device list with loading state
  Future<void> _refreshDeviceList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _filterDevices();
        _isLoading = false;
      });
    }
  }


 /// Filters devices based on search text
  void _filterDevices() {
    if (!mounted || _global == null) return;
    setState(() {
      _filteredDevices = _global.devices
          .where((device) =>
          device.deviceName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
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
                hintText: "Search devices...",
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
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                  _filterDevices();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _refreshDeviceList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh devices',
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

  Widget _buildSectionHeader(String title, List<Device> devices) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              devices.length.toString(),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListItem(Device device) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.state == SessionState.connected
              ? Colors.green.shade100
              : Colors.grey.shade100,
          child: Icon(
            Icons.devices,
            color: device.state == SessionState.connected
                ? Colors.green
                : Colors.grey,
          ),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          getButtonStateName(device.state),
          style: TextStyle(
            color: getButtonColor(device.state),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => connectToDevice(device),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: getButtonColor(device.state),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              getButtonStateName(device.state),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ChatPage(
                    converser: device.deviceName,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No devices found nearby',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _refreshDeviceList,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Consumer<Global>(
        builder: (context, global, child) =>
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (_) => true,
                      child: Stack(
                        children: [
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            if (_filteredDevices.isEmpty)
                              _buildEmptyState()
                            else
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_connectedDevices.isNotEmpty) ...[
                                      _buildSectionHeader('Connected Devices',
                                          _connectedDevices),
                                      ..._connectedDevices.map(
                                          _buildDeviceListItem),
                                    ],
                                    if (_availableDevices.isNotEmpty) ...[
                                      _buildSectionHeader('Available Devices',
                                          _availableDevices),
                                      ..._availableDevices.map(
                                          _buildDeviceListItem),
                                    ],
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}