import { processAgentScanSync, processCitizenServiceQrSync } from '../services/syncService.js';

/**
 * POST /sync/service-qr
 */
export const syncServiceQrBatch = processCitizenServiceQrSync;

/**
 * POST /sync/scans — agent (API key)
 */
export const syncScanBatch = processAgentScanSync;
