import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dio_bloc/core/network/dio_provider.dart';
import 'package:flutter_dio_bloc/features/data/datasources/product_remote_datasource.dart';
import 'package:flutter_dio_bloc/features/data/repositories/product_repository.dart';
import 'package:flutter_dio_bloc/features/presentation/providers/product_provider.dart';
import 'package:flutter_dio_bloc/features/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final provider = ProductProvider(
          repository: ProductRepository(
            remoteDatasource: ProductRemoteDatasource(dio: DioProvider.instance),
          ),
        );
        final isTest = Platform.environment.containsKey('FLUTTER_TEST');
        if (!isTest) {
          provider.loadProducts();
        }
        return provider;
      },
      child: MaterialApp(
        title: 'Product Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0A0F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFBB86FC),
            brightness: Brightness.dark,
            primary: const Color(0xFFBB86FC),
            secondary: const Color(0xFF03DAC6),
            surface: const Color(0xFF141221),
            onSurface: Colors.white,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF141221),
            elevation: 2,
            shadowColor: const Color(0xFFBB86FC).withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF141221),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0B0A0F),
            floatingLabelStyle: const TextStyle(color: Color(0xFFBB86FC)),
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 1.5),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
