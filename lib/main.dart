// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/app_router.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/data/repository/announcement_repository.dart';
import 'package:forsatech/dash_board/data/repository/appointment_repository.dart';
import 'package:forsatech/dash_board/data/repository/candidate_filter_repsitory.dart';
import 'package:forsatech/dash_board/data/repository/interview_repository.dart';
import 'package:forsatech/dash_board/data/repository/opportunity_repository.dart';
import 'package:forsatech/dash_board/data/repository/profile_repository.dart';
import 'package:forsatech/dash_board/data/web_services/announcement_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/candidate_filter_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/interview_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/opportunity_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/google_calendar_web_service.dart';
import 'package:forsatech/dash_board/data/web_services/profile_web_servoces.dart';
import 'package:forsatech/notification_bell.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/data/repository/register_repoistory.dart';
import 'package:forsatech/register/data/web_services/register_web_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

// استيراد dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(' Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة من ملف .env
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['API_KEY']!,
        authDomain: dotenv.env['AUTH_DOMAIN']!,
        projectId: dotenv.env['PROJECT_ID']!,
        storageBucket: dotenv.env['STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
        appId: dotenv.env['APP_ID']!,
        measurementId: dotenv.env['MEASUREMENT_ID']!,
      ),
    );

    await html.window.navigator.serviceWorker
        ?.register('/firebase-messaging-sw.js');
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(ForsaTechApp());
}

class ForsaTechApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  ForsaTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RegisterRepository>(
          create: (_) =>
              RegisterRepository(registerWebServices: RegisterWebServices()),
        ),
        Provider<OpportunityWebService>(
          create: (_) => OpportunityWebService(),
        ),
        Provider<InterviewRepository>(
          create: (_) => InterviewRepository(InterviewWebServies()),
        ),
        Provider<OpportunityRepository>(
          create: (context) => OpportunityRepository(
            webService: context.read<OpportunityWebService>(),
          ),
        ),
        Provider<AppointmentRepository>(
          create: (_) => AppointmentRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RegisterCubit>(
            create: (context) => RegisterCubit(
                registerRepository: context.read<RegisterRepository>()),
          ),
          BlocProvider<AppointmentCubit>(
            create: (context) =>
                AppointmentCubit(context.read<AppointmentRepository>()),
          ),
          BlocProvider<CandidateFilterCubit>(
              create: (_) => CandidateFilterCubit(
                  CandidateFilterRepository(CandidateFilterWebService()))),
          BlocProvider<OpportunityCubit>(
            create: (context) =>
                OpportunityCubit(context.read<OpportunityRepository>()),
          ),
          BlocProvider<AnnouncementCubit>(
            create: (_) => AnnouncementCubit(
                AnnouncementRepository(AnnouncementWebServices())),
          ),
          BlocProvider<JobApponitCubit>(
            create: (_) =>
                JobApponitCubit(JobAppointRepository(JobAppointWebService())),
          ),
          BlocProvider<InterviewCubit>(
            create: (context) => InterviewCubit(
              context.read<InterviewRepository>(),
            ),
          ),
          BlocProvider<CompanyCubit>(
            create: (_) => CompanyCubit(CompanyRepository(CompanyWebService())),
          ),
        ],
        child: ForsaTachApp(appRouter: _appRouter),
      ),
    );
  }
}

class ForsaTachApp extends StatefulWidget {
  final AppRouter appRouter;

  const ForsaTachApp({super.key, required this.appRouter});

  @override
  State<ForsaTachApp> createState() => _ForsaTachAppState();
}

class _ForsaTachAppState extends State<ForsaTachApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
    PushNotifications.init();
  }

  void showWebNotification(String title, String body) {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }

  void initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken(
        vapidKey: dotenv.env['VAPID_KEY']!,
      );
      print('✅ FCM Token: $token');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null && mounted) {
          showWebNotification(
              notification.title ?? '', notification.body ?? '');

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   final context = navigatorKey.currentState?.overlay?.context;
          //   if (context != null) {
          //     showDialog(
          //       context: context,
          //       builder: (_) => AlertDialog(
          //         title: Text(notification.title ?? "No Title"),
          //         content: Text(notification.body ?? "No Body"),
          //         actions: [
          //           TextButton(
          //             onPressed: () => Navigator.of(context).pop(),
          //             child: const Text('Close'),
          //           ),
          //         ],
          //       ),
          //     );
          //   }
          // });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      onGenerateRoute: widget.appRouter.generateRoute,
    );
  }
}
