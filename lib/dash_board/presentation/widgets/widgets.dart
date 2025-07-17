// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:forsatech/constants/colors.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/presentation/screens/announcement_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/profile_screen.dart';
import 'package:forsatech/notification_bell.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/business_logic/cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class Widgets {
// ignore: non_constant_identifier_names
  Widget Sidebar({
    required BuildContext context,
    required int selectedIndex,
    required Function(int) onItemSelected,
  }) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: MyColors.colorSideBar,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          LogoSection(context),
          const SizedBox(height: 6),
          Expanded(
            child: Column(
              children: [
                SidebarItem(Icons.dashboard, "Dashboard", 0, selectedIndex,
                    onItemSelected),
                SidebarItem(Icons.people_alt, "Applicant", 1, selectedIndex,
                    onItemSelected),
                SidebarItem(Icons.work, "Opportunity", 2, selectedIndex,
                    onItemSelected),
                SidebarItem(Icons.event, "Scheduling appointment", 3,
                    selectedIndex, onItemSelected),
                SidebarItem(
                    Icons.policy, "Policy", 4, selectedIndex, onItemSelected),
              ],
            ),
          ),
          const Divider(),
          logoForsaTech(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

// ignore: non_constant_identifier_names
  Widget SidebarItem(
    IconData icon,
    String title,
    int index,
    int selectedIndex,
    Function(int) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          gradient: selectedIndex == index
              ? const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selectedIndex == index ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedIndex == index ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ignore: non_constant_identifier_names
  Widget createAnnouncement(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<AnnouncementCubit>(context),
            child: const AnnouncementDialog(),
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create),
            SizedBox(width: 5),
            Text(
              "Create an announcement",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

// ignore: non_constant_identifier_names
  Widget CustomAppBar(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          if (!isLargeScreen)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              createAnnouncement(context),
              const SizedBox(width: 16),
              ActionButtons(context),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget LogoSection(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        String companyName = '';
        String companyLogo = '';

        if (state is RegisterSuccess) {
          companyName = state.companyName;
          companyLogo = state.companyLogo;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipOval(
                    child:
                        companyLogo.isNotEmpty && companyLogo.startsWith('http')
                            ? Image.network(
                                companyLogo,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_logo.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/default_logo.png',
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                const SizedBox(height: 15),
                if (companyName.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget ActionButtons(BuildContext context) {
    return Row(
      children: [
        const NotificationBell(),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.grey),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompanyProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}

Widget logoForsaTech(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(width: 10),
      InkWell(
        onTap: () async {
          final url = Uri.parse("https://forsatech.netlify.app/");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('❌ Could not launch the URL');
          }
        },
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Forsa-Tech",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "https://forsatech.netlify.app/",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
