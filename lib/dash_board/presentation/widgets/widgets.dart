import 'package:flutter/material.dart';
import 'package:forsatech/constants/colors.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/presentation/screens/announcement_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/policy_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/profile_secreen.dart';
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
          const SizedBox(height: 10),
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
          Divider(),
          TextButton.icon(
            icon: const Icon(Icons.info_outline),
            label: const Text("Visit Website"),
            onPressed: () async {
              final url = Uri.parse("https://forsatech.netlify.app/");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                // يمكنك عرض رسالة خطأ إن أردت
                debugPrint('❌ Could not launch the URL');
              }
            },
          ),
          const SizedBox(height: 20),
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
            child: AnnouncementDialog(),
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

  Widget LogoSection(BuildContext context) {
    print("🔁 LogoSection rebuilt");
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        String companyName = '';
        String companyLogo = '';

        if (state is RegisterSuccess) {
          companyName = state.companyName;
          companyLogo = state.companyLogo;
        }
        print("Current state: $state");
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("State is: ${state.runtimeType}",
                style: const TextStyle(color: Colors.white)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: companyLogo.isNotEmpty && companyLogo.startsWith('http')
                    ? Image.network(
                        companyLogo,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        width: 70,
                        height: 70,
                        child: Placeholder(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (companyName.isNotEmpty)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

// ignore: non_constant_identifier_names
  Widget ActionButtons(BuildContext context) {
    return Row(children: [
      IconButton(
        icon: const Icon(Icons.notifications, color: Colors.grey),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.account_circle, color: Colors.grey),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      )
    ]);
  }

  // Widget Logo() {
  //   return Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           child: ClipRRect(
  //             child: Image.asset(
  //               'assets/images/photo_2.jpg',
  //               width: 270,
  //               height: 40,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         )
  //       ]);
  // }
}
