import 'package:flutter/material.dart';
import 'package:kos_kos/view/umum/halaman_login.dart';


import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart'; 
import 'package:path/path.dart';

import 'controller/auth_controller.dart';
import 'controller/daftar_kost_controller.dart';
import 'controller/detail_kost_controller.dart'; 
import 'controller/owner_kost_controller.dart'; 
import 'controller/booking_controller.dart'; 
import 'models/kost_composite_model.dart';
import 'view/owner/main_owner.dart';
import 'view/owner/tambah_kost.dart';
import 'view/owner/ubah_kost.dart';
import 'view/society/detail_kost.dart';
import 'view/society/main_society.dart';
import 'view/umum/halaman_pilihan_role.dart';
import 'view/umum/halaman_register.dart';
import 'view/umum/halaman_splash.dart'; 

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kost_app.db');
    // ignore: avoid_print
    print("--- LOKASI DATABASE ADA DI: $path ---");
  } catch (e) {
    // ignore: avoid_print
    print("Gagal mendapatkan path DB: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => DaftarKostController()),
        ChangeNotifierProvider(create: (context) => DetailKostController()),
        ChangeNotifierProvider(create: (context) => OwnerKostController()),
        ChangeNotifierProvider(create: (context) => BookingController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // --- Rute Umum ---
          case '/':
            return MaterialPageRoute(builder: (_) => const HalamanSplash());
          case '/login':
            return MaterialPageRoute(builder: (_) => const HalamanLogin());
          case '/register':
            return MaterialPageRoute(builder: (_) => const HalamanRegister());
          case '/pilihan_role':
            return MaterialPageRoute(builder: (_) => const HalamanPilihanRole());

          // --- Rute Utama Society ---
          case '/society/main': // <-- RUTE BARU
            return MaterialPageRoute(builder: (_) => const MainSociety());
            
          // --- Rute Detail Society ---
          case '/society/detail_kost':
            final int kostId = settings.arguments as int;
            return MaterialPageRoute(
                builder: (_) => DetailKostPage(kostId: kostId));

          // --- Rute Utama Owner ---
          case '/owner/main': // <-- RUTE BARU
            return MaterialPageRoute(builder: (_) => const MainOwner());
            
          // --- Rute Detail Owner ---
          case '/owner/tambah_kost':
            return MaterialPageRoute(builder: (_) => const TambahKost());
          case '/owner/ubah_kost':
            final KostCompositeModel kost = settings.arguments as KostCompositeModel;
            return MaterialPageRoute(
              builder: (_) => UbahKostPage(kostComposite: kost),
            );

            case '/society/beranda':
            return MaterialPageRoute(builder: (_) => const MainSociety());
          case '/owner/beranda':
            return MaterialPageRoute(builder: (_) => const MainOwner());

          default:
            return MaterialPageRoute(builder: (_) => const HalamanLogin());
        }
      },
    );
  }
}