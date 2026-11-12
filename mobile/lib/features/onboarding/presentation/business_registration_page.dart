import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/providers/onboarding_providers.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/onboarding/application/business_registration_controller.dart';
import 'package:pos_mobile/features/onboarding/domain/registration_form_validator.dart';

class BusinessRegistrationPage extends ConsumerStatefulWidget {
  const BusinessRegistrationPage({super.key});

  @override
  ConsumerState<BusinessRegistrationPage> createState() =>
      _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState
    extends ConsumerState<BusinessRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _businessPhone = TextEditingController();
  final _businessEmail = TextEditingController();
  final _ownerName = TextEditingController();
  final _ownerEmail = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _businessName.dispose();
    _businessPhone.dispose();
    _businessEmail.dispose();
    _ownerName.dispose();
    _ownerEmail.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(businessRegistrationControllerProvider);
    final outcome = await controller.submit(
      RegistrationFormValues(
        businessName: _businessName.text,
        ownerName: _ownerName.text,
        ownerEmail: _ownerEmail.text,
        password: _password.text,
        businessPhone: _businessPhone.text,
        businessEmail: _businessEmail.text,
      ),
    );

    if (!mounted) return;
    switch (outcome) {
      case RegistrationFlowOutcome.success:
        ref.invalidate(appLaunchResolutionProvider);
        context.go(AppRoutes.onboardingComplete);
      case RegistrationFlowOutcome.provisioningFailed:
        ref.invalidate(appLaunchResolutionProvider);
        context.go(AppRoutes.onboardingRecover);
      case RegistrationFlowOutcome.validationFailed:
      case RegistrationFlowOutcome.duplicateEmail:
      case RegistrationFlowOutcome.remoteFailed:
      case RegistrationFlowOutcome.unknownRemoteOutcome:
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(businessRegistrationControllerProvider).state;
    final isWide =
        MediaQuery.sizeOf(context).width >= AppSpacing.desktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ui.isBusy
              ? null
              : () => context.go(AppRoutes.onboardingWelcome),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(
              isWide ? AppSpacing.xl : AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (ui.errorMessage != null) ...[
                      _MessageBanner(message: ui.errorMessage!, isError: true),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (ui.infoMessage != null) ...[
                      _MessageBanner(message: ui.infoMessage!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _RegistrationField(
                      controller: _businessName,
                      label: 'Business name',
                      errorText: ui.fieldErrors['businessName'],
                      enabled: !ui.isBusy,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RegistrationField(
                      controller: _ownerName,
                      label: 'Owner full name',
                      errorText: ui.fieldErrors['ownerName'],
                      enabled: !ui.isBusy,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RegistrationField(
                      controller: _ownerEmail,
                      label: 'Owner email',
                      errorText: ui.fieldErrors['ownerEmail'],
                      enabled: !ui.isBusy,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RegistrationField(
                      controller: _password,
                      label: 'Password',
                      errorText: ui.fieldErrors['password'],
                      enabled: !ui.isBusy,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: ui.isBusy
                            ? null
                            : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RegistrationField(
                      controller: _businessPhone,
                      label: 'Business phone (optional)',
                      errorText: ui.fieldErrors['businessPhone'],
                      enabled: !ui.isBusy,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RegistrationField(
                      controller: _businessEmail,
                      label: 'Business email (optional)',
                      errorText: ui.fieldErrors['businessEmail'],
                      enabled: !ui.isBusy,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => ui.isBusy ? null : _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: ui.isBusy ? null : _submit,
                      child: ui.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create business account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistrationField extends StatelessWidget {
  const _RegistrationField({
    required this.controller,
    required this.label,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.autocorrect,
    this.textInputAction,
    this.suffix,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool? autocorrect;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: autocorrect ?? true,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: suffix,
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(color: fg),
      ),
    );
  }
}
