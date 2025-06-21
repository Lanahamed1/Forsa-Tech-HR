

import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/data/web_services/announcement_web_services.dart';

class AnnouncementRepository {
  final AnnouncementWebServices webServices;

  AnnouncementRepository(this.webServices);

  Future<List<Announcement>> getAllAnnouncements() {
    return webServices.getAnnouncements();
  }

  Future<bool> addAnnouncement(Announcement announcement) {
    return webServices.createAnnouncement(announcement);
  }
}
