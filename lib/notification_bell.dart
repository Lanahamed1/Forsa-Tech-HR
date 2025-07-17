import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LocalNotification {
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  LocalNotification({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

class PushNotifications {
  static final List<LocalNotification> receivedNotifications = [];

  static Future<void> init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        receivedNotifications.add(
          LocalNotification(
            title: message.notification?.title ?? "No title",
            body: message.notification?.body ?? "No content",
            time: DateTime.now(),
            isRead: false,
          ),
        );
      }
    });
  }
}

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<LocalNotification> displayedNotifications = [];

  void _toggleMenu() {
    if (!_isMenuOpen) {
      // Mark all notifications as read
      for (var n in PushNotifications.receivedNotifications) {
        n.isRead = true;
      }
    }

    if (_isMenuOpen) {
      _overlayEntry?.remove();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }

    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  OverlayEntry _createOverlayEntry() {
    displayedNotifications =
        PushNotifications.receivedNotifications.reversed.toList();

    final screenSize = MediaQuery.of(context).size;
    double width = screenSize.width > 360 ? 330 : screenSize.width * 0.9;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        right: 10,
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 450),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(14)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      const Text(
                        "Notifications",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87),
                        onPressed: () {
                          _overlayEntry?.remove();
                          setState(() => _isMenuOpen = false);
                        },
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: displayedNotifications.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  "No new notifications",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: displayedNotifications.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index, animation) {
                            final notif = displayedNotifications[index];
                            return SizeTransition(
                              sizeFactor: animation,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage(
                                            'assets/images/logo.png'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notif.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notif.body,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              timeAgo(notif.time),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        color: Colors.grey,
                                        tooltip: 'Dismiss',
                                        onPressed: () {
                                          setState(() {
                                            final removedItem =
                                                displayedNotifications
                                                    .removeAt(index);
                                            _listKey.currentState?.removeItem(
                                              index,
                                              (context, animation) =>
                                                  SizeTransition(
                                                sizeFactor: animation,
                                                child: Container(),
                                              ),
                                            );
                                            PushNotifications
                                                .receivedNotifications
                                                .remove(removedItem);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount =
        PushNotifications.receivedNotifications.where((n) => !n.isRead).length;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.grey),
            onPressed: _toggleMenu,
            tooltip: 'Show Notifications',
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
