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

  bool isInit = false;
  bool isLoading = false;
  Global? globalProvider;
  final TextEditingController searchController = TextEditingController();
  List<Device> filteredDevices = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      globalProvider = Provider.of<Global>(context, listen: false);
      globalProvider?.addListener(_handleGlobalUpdate);
      _initializeDevices();
      isInit = true;
    }
  }

  void _initializeDevices() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _updateFilteredDevices();
      setState(() {
        isLoading = false;
      });
    });
  }

  void _handleGlobalUpdate() {
    if (mounted) {
      debugPrint("Global Update - Devices: ${globalProvider?.devices.map((d) => d.deviceName).toList()}");
      _updateFilteredDevices();
    }
  }

  void _updateFilteredDevices() {
    if (mounted && globalProvider != null) {
      setState(() {
        filteredDevices = searchController.text.isEmpty
            ? globalProvider!.devices
            : globalProvider!.devices
            .where((device) => device.deviceName
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    globalProvider?.removeListener(_handleGlobalUpdate);
    super.dispose();
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              autofocus: false,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Search devices...",
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
              onChanged: (value) => _updateFilteredDevices(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _initializeDevices,
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Refresh devices',
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

  Widget _buildDeviceList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.devices_other,
                size: 64,
                color: Theme.of(context).colorScheme.secondary
            ),
            const SizedBox(height: 16),
            Text(
              'No devices found nearby',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredDevices.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final device = filteredDevices[index];
        return _buildDeviceListItem(device);
      },
    );
  }


  Widget _buildDeviceListItem(Device device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: getButtonColor(device.state).withOpacity(0.2),
          child: Icon(Icons.devices,
              color: getButtonColor(device.state)),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          getButtonStateName(device.state),
          style: TextStyle(color: getButtonColor(device.state)),
        ),
        trailing: _buildConnectionButton(device),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(converser: device.deviceName),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionButton(Device device) {
    return GestureDetector(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _initializeDevices();
              },
              child: _buildDeviceList(),
            ),
          ),
        ],
      ),
    );
  }
}
