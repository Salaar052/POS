/// Registry status for a known business database on this device.
abstract final class ProvisioningStatus {
  static const provisioning = 'PROVISIONING';
  static const ready = 'READY';

  static const all = [provisioning, ready];

  static bool isValid(String value) => all.contains(value);
}
