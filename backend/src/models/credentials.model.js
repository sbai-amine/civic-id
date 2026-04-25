/**
 * Demo credentials for mock authentication.
 * Replace with database / identity provider checks in production.
 */
export const VALID_NATIONAL_ID = '123456';
export const VALID_PIN = '1234';

/**
 * @param {string | undefined} nationalID
 * @param {string | undefined} pin
 * @returns {boolean}
 */
export function isValidCredentials(nationalID, pin) {
  const id = String(nationalID ?? '').trim();
  const p = String(pin ?? '').trim();
  return id === VALID_NATIONAL_ID && p === VALID_PIN;
}
