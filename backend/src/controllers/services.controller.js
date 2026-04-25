import { query } from '../db/pool.js';
import { getPool } from '../db/pool.js';
import { getMockServices } from '../models/service.model.js';

/**
 * GET /services — full service catalog.
 */
export async function listServices(req, res) {
  if (getPool()) {
    const { rows } = await query(
      `SELECT id, name, description, required_documents, fee_display
       FROM services ORDER BY name`,
    );
    return res.status(200).json({
      success: true,
      data: {
        services: rows.map((r) => ({
          id: r.id,
          name: r.name,
          description: r.description,
          requiredDocuments: r.required_documents,
          fees: r.fee_display,
        })),
      },
    });
  }
  return res.status(200).json({
    success: true,
    data: {
      services: getMockServices().map((s) => ({
        id: s.id,
        name: s.name,
        description: '',
        requiredDocuments: [],
        fees: '',
      })),
    },
  });
}
