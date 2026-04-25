/**
 * Fallback when DATABASE_URL is not set.
 */
export function getMockServices() {
  return [
    { id: 'birth_certificate', name: 'Birth certificate' },
    { id: 'residence_certificate', name: 'Residence certificate' },
  ];
}
