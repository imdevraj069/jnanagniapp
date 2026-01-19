import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _api = ApiService();
  final _searchCtrl = TextEditingController();
  
  // State Variables
  List<dynamic> _users = [];
  bool _isLoading = true;          // For initial load
  bool _isLoadingMore = false;     // For "Load More" spinner
  String? _errorMessage;
  
  // Pagination Variables
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;           // Matches your backend default

  @override
  void initState() {
    super.initState();
    _loadUsers(refresh: true);
  }

  /// Fetches users from the backend
  /// [refresh]: If true, clears list and starts from page 1.
  ///            If false, fetches the next page.
  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1; // Reset to page 1
        _users = [];      // Clear existing data
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // 1. Build Query String
      String endpoint = '${ApiConstants.allUsers}?page=$_currentPage&limit=$_limit';
      
      // Note: Your provided Node.js code didn't explicitly show search logic in getAllUsers,
      // but if you added it, this passes the query param correctly.
      if (_searchCtrl.text.isNotEmpty) {
        endpoint += '&search=${_searchCtrl.text}';
      }

      // 2. Call API
      final res = await _api.get(endpoint);

      if (mounted) {
        setState(() {
          // 3. Parse Data & Pagination
          List<dynamic> newUsers = [];
          
          if (res['data'] is Map) {
            // Handle { users: [...], pagination: {...} }
            if (res['data']['users'] != null) {
              newUsers = res['data']['users'];
            }
            // Handle Pagination Data from Backend
            if (res['data']['pagination'] != null) {
              _totalPages = res['data']['pagination']['totalPages'] ?? 1;
            }
          } 
          // Fallback for direct lists (though backend suggests Map)
          else if (res['data'] is List) {
            newUsers = res['data'];
          }

          // 4. Update List
          if (refresh) {
            _users = newUsers;
          } else {
            _users.addAll(newUsers);
          }

          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (e.toString().contains("403")) {
            _errorMessage = "Access Restricted: Admins Only";
          } else {
            _errorMessage = "Failed to load users";
          }
        });
      }
    }
  }

  void _onLoadMore() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _loadUsers(refresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(
        title: const Text("User Database"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: CyberColors.neonCyan),
                filled: true,
                fillColor: CyberColors.bgSecondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: CyberColors.neonCyan),
                  onPressed: () => _loadUsers(refresh: true), // Search resets list
                )
              ),
              onSubmitted: (_) => _loadUsers(refresh: true),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Show Error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: CyberColors.neonPink, size: 40),
            const SizedBox(height: 10),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _loadUsers(refresh: true),
              style: ElevatedButton.styleFrom(backgroundColor: CyberColors.bgCard),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    // 2. Show Initial Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: CyberColors.neonCyan));
    }

    // 3. Show Empty State
    if (_users.isEmpty) {
      return const Center(child: Text("No users found.", style: TextStyle(color: Colors.grey)));
    }

    // 4. Show List with "Load More" at the bottom
    return ListView.builder(
      // Add +1 to item count for the "Load More" button
      itemCount: _users.length + 1,
      itemBuilder: (context, index) {
        
        // --- LOAD MORE BUTTON LOGIC (Keep existing) ---
        if (index == _users.length) {
          if (_currentPage >= _totalPages) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("All users loaded", style: TextStyle(color: Colors.grey, fontSize: 12))),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoadingMore ? null : _onLoadMore,
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.bgCard,
                side: const BorderSide(color: CyberColors.neonCyan),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoadingMore 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: CyberColors.neonCyan))
                  : const Text("LOAD MORE", style: TextStyle(color: CyberColors.neonCyan, fontWeight: FontWeight.bold)),
            ),
          );
        }

        // --- USER CARD LOGIC ---
        final u = _users[index];
        
        // 1. Extract Status Data
        final bool emailVerified = u['isVerified'] == true;
        final String paymentStatus = u['paymentStatus'] ?? 'none';
        final bool paymentVerified = paymentStatus == 'verified';

        // 2. Determine Color & Icon based on your rules
        Color statusColor;
        IconData statusIcon;

        if (emailVerified && paymentVerified) {
          // GREEN: All Done
          statusColor = CyberColors.neonGreen; 
          statusIcon = Icons.verified;
        } else if (emailVerified) {
          // YELLOW: Only Email Verified (Payment Pending/None)
          statusColor = Colors.yellowAccent; 
          statusIcon = Icons.mark_email_read;
        } else {
          // RED: Nothing Verified
          statusColor = CyberColors.neonPink; 
          statusIcon = Icons.warning_amber_rounded;
        }

        final name = u['name'] ?? 'Unknown';
        final email = u['email'] ?? 'No Email';
        final jnanagniId = u['jnanagniId'] ?? 'PENDING';

        return Card(
          color: CyberColors.bgCard,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            // Apply the status color to the border
            side: BorderSide(color: statusColor, width: 1.5), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: CyberColors.bgSecondary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?', 
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold) // Colored Initials
              ),
            ),
            title: Text(
              name, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  "$jnanagniId • ${paymentStatus.toUpperCase()}", 
                  style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            trailing: Icon(statusIcon, color: statusColor),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(userId: u['_id'])));
            },
          ),
        );
      },
    );
  }
}