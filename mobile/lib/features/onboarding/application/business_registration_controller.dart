import 'package:flutter/foundation.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/core/network/business_registration_api.dart';
import 'package:pos_mobile/core/network/business_registration_models.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';
import 'package:pos_mobile/features/onboarding/domain/registration_form_validator.dart';

enum RegistrationSubmitPhase { idle, validating, submitting, provisioning }

@immutable
class BusinessRegistrationUiState {
  const BusinessRegistrationUiState({
    this.phase = RegistrationSubmitPhase.idle,
    this.fieldErrors = const {},
    this.errorMessage,
    this.infoMessage,
    this.lastSuccess,
  });

  final RegistrationSubmitPhase phase;
  final Map<String, String> fieldErrors;
  final String? errorMessage;
  final String? infoMessage;
  final RegisterBusinessResult? lastSuccess;

  bool get isBusy =>
      phase == RegistrationSubmitPhase.submitting ||
      phase == RegistrationSubmitPhase.provisioning;

  BusinessRegistrationUiState copyWith({
    RegistrationSubmitPhase? phase,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    String? infoMessage,
    RegisterBusinessResult? lastSuccess,
    bool clearError = false,
    bool clearInfo = false,
    bool clearSuccess = false,
  }) {
    return BusinessRegistrationUiState(
      phase: phase ?? this.phase,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
      lastSuccess: clearSuccess ? null : lastSuccess ?? this.lastSuccess,
    );
  }
}

class BusinessRegistrationController extends ChangeNotifier {
  BusinessRegistrationController({
    required this._api,
    required this._recoveryStore,
  });

  final BusinessRegistrationApi _api;
  final OnboardingRecoveryStore _recoveryStore;

  BusinessRegistrationUiState _state = const BusinessRegistrationUiState();
  BusinessRegistrationUiState get state => _state;

  Future<RegistrationFlowOutcome> submit(RegistrationFormValues values) async {
    _setState(
      _state.copyWith(
        phase: RegistrationSubmitPhase.validating,
        fieldErrors: const {},
        clearError: true,
        clearInfo: true,
        clearSuccess: true,
      ),
    );

    final validation = validateRegistrationForm(values);
    if (!validation.isValid) {
      _setState(
        _state.copyWith(
          phase: RegistrationSubmitPhase.idle,
          fieldErrors: validation.fieldErrors,
          errorMessage: validation.formError,
        ),
      );
      return RegistrationFlowOutcome.validationFailed;
    }

    _setState(
      _state.copyWith(
        phase: RegistrationSubmitPhase.submitting,
        fieldErrors: const {},
      ),
    );

    final request = RegisterBusinessRequest(
      businessName: values.businessName.trim(),
      ownerName: values.ownerName.trim(),
      ownerEmail: values.ownerEmail.trim(),
      password: values.password,
      businessPhone: values.businessPhone?.trim(),
      businessEmail: values.businessEmail?.trim(),
    );

    try {
      final result = await _api.register(request);
      try {
        await _provisionAfterRemoteSuccess(result, values);
      } catch (_) {
        return RegistrationFlowOutcome.provisioningFailed;
      }
      return RegistrationFlowOutcome.success;
    } on RegistrationApiException catch (error) {
      if (error.kind == RegistrationApiFailureKind.timeout) {
        _setState(
          _state.copyWith(
            phase: RegistrationSubmitPhase.idle,
            errorMessage: error.message,
            infoMessage:
                'If you are not sure whether registration completed, retry with the same email. '
                'A duplicate will return a conflict response instead of creating a second business.',
          ),
        );
        return RegistrationFlowOutcome.unknownRemoteOutcome;
      }
      _setState(
        _state.copyWith(
          phase: RegistrationSubmitPhase.idle,
          errorMessage: error.message,
          fieldErrors: error.fieldErrors ?? const {},
        ),
      );
      if (error.kind == RegistrationApiFailureKind.duplicateEmail) {
        return RegistrationFlowOutcome.duplicateEmail;
      }
      return RegistrationFlowOutcome.remoteFailed;
    } catch (_) {
      _setState(
        _state.copyWith(
          phase: RegistrationSubmitPhase.idle,
          errorMessage: 'Registration failed unexpectedly. Please try again.',
        ),
      );
      return RegistrationFlowOutcome.remoteFailed;
    }
  }

  Future<void> retryLocalProvisioningFromRecovery() async {
    final recoveryRead = await _recoveryStore.readProvisioningRecovery();
    if (recoveryRead
        is! OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>) {
      _setState(
        _state.copyWith(
          errorMessage: 'No saved registration was found for local setup.',
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        phase: RegistrationSubmitPhase.provisioning,
        clearError: true,
        clearInfo: true,
      ),
    );

    final recovery = recoveryRead.value;
    try {
      await AppRuntime.provisionAndSwitchToBusiness(
        businessId: recovery.businessId,
        displayName: recovery.displayName,
        phone: recovery.businessPhone,
      );
      await _recoveryStore.clearProvisioningRecovery();
      await _recoveryStore.saveOwnerPending(
        OwnerPendingSnapshot(
          businessId: recovery.businessId,
          businessName: recovery.displayName,
          ownerEmail: recovery.ownerEmail,
          ownerName: recovery.ownerName,
        ),
      );
      _setState(_state.copyWith(phase: RegistrationSubmitPhase.idle));
    } catch (error) {
      _setState(
        _state.copyWith(
          phase: RegistrationSubmitPhase.idle,
          errorMessage:
              'Local database setup failed again. Your cloud registration is still saved. '
              'Try again or contact support before registering a new business.',
        ),
      );
      rethrow;
    }
  }

  Future<void> _provisionAfterRemoteSuccess(
    RegisterBusinessResult result,
    RegistrationFormValues values,
  ) async {
    _setState(_state.copyWith(phase: RegistrationSubmitPhase.provisioning));

    await _recoveryStore.saveProvisioningRecovery(
      ProvisioningRecoverySnapshot(
        businessId: result.business.id,
        displayName: result.business.name,
        ownerName: result.owner.name,
        ownerEmail: result.owner.email,
        businessPhone: values.businessPhone?.trim(),
        businessEmail: values.businessEmail?.trim(),
      ),
    );

    try {
      await AppRuntime.provisionAndSwitchToBusiness(
        businessId: result.business.id,
        displayName: result.business.name,
        phone: result.business.phone ?? values.businessPhone?.trim(),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          phase: RegistrationSubmitPhase.idle,
          errorMessage:
              'Your business was registered online, but local database setup failed. '
              'Use "Retry local setup" on the recovery screen — do not register again.',
        ),
      );
      rethrow;
    }

    await _recoveryStore.clearProvisioningRecovery();
    await _recoveryStore.saveOwnerPending(
      OwnerPendingSnapshot(
        businessId: result.business.id,
        businessName: result.business.name,
        ownerEmail: result.owner.email,
        ownerName: result.owner.name,
      ),
    );

    _setState(
      _state.copyWith(phase: RegistrationSubmitPhase.idle, lastSuccess: result),
    );
  }

  void _setState(BusinessRegistrationUiState next) {
    _state = next;
    notifyListeners();
  }
}

enum RegistrationFlowOutcome {
  success,
  validationFailed,
  duplicateEmail,
  remoteFailed,
  unknownRemoteOutcome,
  provisioningFailed,
}
