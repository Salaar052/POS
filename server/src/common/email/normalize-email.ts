/**
 * Normalizes an email for uniqueness and lookup (trim + lowercase).
 */
export function normalizeEmail(email: string): string {
  const trimmed = email.trim();
  if (!trimmed) {
    throw new Error('Email must not be empty');
  }
  return trimmed.toLowerCase();
}
