// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html; // لإضافة خدمة Firebase SW
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/app_router.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/data/repository/announcement_repository.dart';
import 'package:forsatech/dash_board/data/repository/candidate_filter_repsitory.dart';
import 'package:forsatech/dash_board/data/repository/dash_board_repository.dart';
import 'package:forsatech/dash_board/data/web_services/announcement_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/candidate_filter_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/dash_board_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/google_calendar_service.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/data/repository/register_repoistory.dart';
import 'package:forsatech/register/data/web_services/register_web_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCYV_4lTeFYDIcaGZqDM9CT6VDJ7L9ZYOk",
        authDomain: "forsa-204b9.firebaseapp.com",
        projectId: "forsa-204b9",
        storageBucket: "forsa-204b9.firebasestorage.app",
        messagingSenderId: "134152629656",
        appId: "1:134152629656:web:539b2b23784823d6bdcfed",
        measurementId: "G-PKL2RBSP54",
      ),
    );

    // تسجيل service worker لتلقي الرسائل بالخلفية
    await html.window.navigator.serviceWorker
        ?.register('/firebase-messaging-sw.js');
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        Provider<RegisterRepository>(
          create: (_) =>
              RegisterRepository(registerWebServices: RegisterWebServices()),
        ),
        BlocProvider<RegisterCubit>(
          create: (context) => RegisterCubit(
              registerRepository: context.read<RegisterRepository>()),
        ),
        Provider<AppointmentRepository>(
          create: (_) => AppointmentRepository(),
        ),
        BlocProvider<AppointmentCubit>(
          create: (context) =>
              AppointmentCubit(context.read<AppointmentRepository>()),
        ),
        BlocProvider<CandidateCubit>(
            create: (_) =>
                CandidateCubit(CandidateRepository(WebServerService()))),
        Provider<OpportunityWebService>(
          create: (_) => OpportunityWebService(),
        ),
        Provider<OpportunityRepository>(
          create: (context) => OpportunityRepository(
            webService: context.read<OpportunityWebService>(),
          ),
        ),
        BlocProvider<OpportunityCubit>(
            create: (context) =>
                OpportunityCubit(context.read<OpportunityRepository>())),
        BlocProvider(
            create: (_) => AnnouncementCubit(
                AnnouncementRepository(AnnouncementWebServices()))),
        BlocProvider(
            create: (_) => JobApponitCubit(
                JobAppointRepository(JobAppointWebService())))

      ],
      child: ForsaTachApp(appRouter: AppRouter()),
    ),
  );
}

class ForsaTachApp extends StatefulWidget {
  final AppRouter appRouter;

  const ForsaTachApp({super.key, required this.appRouter});

  @override
  State<ForsaTachApp> createState() => _ForsaTachAppState();
}

class _ForsaTachAppState extends State<ForsaTachApp> {
  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
  }

  void initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken(
        vapidKey:
            'BHzVJj-ZAA8aAJh6Bjr0CY1aCYQ7ZJ-MOIOq-TuzL-mD8IHuPDqeDNJDTGP9ni-7zQXFSRWiBFY7ry3KE-QPjAQ',
      );
      print('✅ FCM Token: $token');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Foreground message: ${message.notification?.title}');
        final notification = message.notification;
        if (notification != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(notification.title ?? "No Title"),
                content: Text(notification.body ?? "No Body"),
              ),
            );
          });
        }
      });
    } else {
      print('❌ User declined notification permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: widget.appRouter.generateRoute,
    );
  }
}
