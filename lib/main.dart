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
      create: (_) => ProductProvider(
        repository: ProductRepository(
          remoteDatasource: ProductRemoteDatasource(dio: DioProvider.instance),
        ),
      )..loadProducts(),
      child: MaterialApp(
        title: 'Product Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
