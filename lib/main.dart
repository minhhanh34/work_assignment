import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_assignment/admin/admin_screen.dart';
import 'package:work_assignment/clients/home_cubit.dart';
import 'package:work_assignment/clients/home_screen.dart';
import 'package:work_assignment/clients/login_screen.dart';
import 'package:work_assignment/clients/sign_cubit.dart';
import 'package:work_assignment/staff/staff_cubit.dart';
import 'package:work_assignment/staff/staff_service.dart';
import 'package:work_assignment/task/task_cubit.dart';
import 'package:work_assignment/task/task_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final spref = await SharedPreferences.getInstance();
  String? gmail = spref.getString('gmail');
  runApp(WorkAsignmentApp(gmail: gmail));
}

class WorkAsignmentApp extends StatelessWidget {
  const WorkAsignmentApp({Key? key, this.gmail}) : super(key: key);
  final String? gmail;
  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();
    final StaffService staffService = StaffService();
    final StaffCubit staffCubit = StaffCubit(staffService);
    final HomeCubit homeCubit = HomeCubit(taskService, staffService);
    final TaskCubit taskCubit = TaskCubit(taskService, staffCubit);
    final SignCubit signCubit = SignCubit(
      service: staffService,
      homeCubit: homeCubit,
      staffCubit: staffCubit,
      taskCubit: taskCubit,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => taskCubit),
        BlocProvider(create: (_) => staffCubit),
        BlocProvider(create: (_) => signCubit),
        BlocProvider(create: (_) => homeCubit)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(
          builder: (context) {
            if (gmail != null) {
              if (gmail == 'admin@gmail.com') {
                return const AdminPage(title: 'Quản trị lịch công tác');
              }
              return const HomeScreen();
            }
            return const SignInScreen();
          },
        ),
      ),
    );
  }
}
