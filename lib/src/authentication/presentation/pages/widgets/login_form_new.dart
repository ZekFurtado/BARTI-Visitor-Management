import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:visitor_management/core/widgets/loader_dialog.dart';

import '../../../../../core/common/user_provider.dart';
import '../../bloc/auth_cubit.dart';
import '../../bloc/authentication_bloc.dart';

class LoginFormNew extends StatelessWidget {
  LoginFormNew({super.key});

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final emailFieldKey = const Key('login-email-field');

  final passwordFieldKey = const Key('login-password-field');

  final loginButtonKey = const Key('login-button');

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is SigningInEmailUser) {
          showDialog(
              context: context,
              builder: (context) => const LoaderDialog(title: 'Signing in'));
        } else if (state is AuthenticationError) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text("Authentication Error"),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.popUntil(
                              context, ModalRoute.withName('/loginNew'));
                        },
                        child: const Text("Ok"),
                      )
                    ],
                  ));
        } else if (state is Authenticated) {
          // Navigator.pushNamedAndRemoveUntil(
          //     context, '/home', (route) => false);
          context.read<UserProvider>().initUser(state.visitor);
          Navigator.popUntil(context, ModalRoute.withName('/loginNew'));
          Navigator.popAndPushNamed(context, '/home');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to Samta Doot",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            key: emailFieldKey,
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.25)),
                ),
                labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          BlocProvider(
            create: (context) => PasswordVisibilityCubit(),
            child: BlocBuilder<PasswordVisibilityCubit, bool>(
              builder: (context, hidePass) {
                return TextFormField(
                  key: passwordFieldKey,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.25)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.25)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.25)),
                      ),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          context.read<PasswordVisibilityCubit>().toggle();
                        },
                        icon: hidePass
                            ? const Icon(IconlyLight.hide)
                            : const Icon(IconlyLight.show),
                      )),
                  obscureText: hidePass,
                  obscuringCharacter: "*",
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    context.read<AuthenticationBloc>().add(EmailSignInEvent(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim()));
                  },
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface),
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.secondary)),
              child: const Text(
                "Forgot Password?",
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: TextButton(
              key: loginButtonKey,
              style: Theme.of(context).textButtonTheme.style?.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(150, 35)),
                    maximumSize: const WidgetStatePropertyAll(Size(150, 35)),
                  ),
              onPressed: () {
                /* Calls AuthenticationCubit.emailSignIn(email,
                            password). This call will cause a series of actions
                            in different layers. This is the presentation layer.
                             */

                /*context.read<cubit.AuthenticationCubit>().emailSignIn(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());*/

                context.read<AuthenticationBloc>().add(EmailSignInEvent(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim()));
              },
              child: const Text("Login"),
            ),
          )
        ],
      ),
    );
  }
}
