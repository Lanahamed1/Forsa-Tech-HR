import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/presentation/screens/candidate_filter_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/home_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/opportunity_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/policy_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/scheduling_appointments_secreen.dart';
import 'package:forsatech/dash_board/presentation/widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  final Widgets widgets = Widgets();

  final List<Widget> pages = [
    const HomeScreen(),
    const CandidateFilterScreen(),
    const OpportunityScreen(),
    const AppointmentScreen(),
    const PoliciesScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1050;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: widgets.Sidebar(
                context: context,
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() => selectedIndex = index);
                  Navigator.pop(context);
                },
              ),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              widgets.Sidebar(
                context: context,
                selectedIndex: selectedIndex,
                onItemSelected: (index) =>
                    setState(() => selectedIndex = index),
              ),
            Expanded(
              child: Column(
                children: [
                  widgets.CustomAppBar(context),
                  Expanded(
                    child: pages[selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
