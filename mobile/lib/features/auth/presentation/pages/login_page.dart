import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_memorizer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_memorizer/features/auth/presentation/widgets/auth_form.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(AppRouter.home);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: AuthForm(isLogin: true),
          ),
        ),
      ),
    );
  }
}
