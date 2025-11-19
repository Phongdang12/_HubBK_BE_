// src/controllers/discipline.controller.ts
import { Request, Response } from 'express';
import * as service from '@/Services/discipline.service';

function handleError(res: Response, err: any) {
  if (err && typeof err === 'object' && err.status) {
    return res.status(err.status).json({ error: err.message || 'Error' });
  }
  console.error('Unexpected error:', err);
  return res.status(500).json({ error: 'Internal server error' });
}

export async function listDisciplines(req: Request, res: Response) {
  try {
    const data = await service.getAllDisciplines();
    res.json(data);
  } catch (err) {
    handleError(res, err);
  }
}

export async function getDiscipline(req: Request, res: Response) {
  try {
    const { action_id } = req.params;
    const row = await service.getDisciplineById(action_id);
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  } catch (err) {
    handleError(res, err);
  }
}

export async function createDiscipline(req: Request, res: Response) {
  try {
    // require action_id and sssn
    const body = req.body;
    if (!body || !body.action_id) return res.status(400).json({ error: 'action_id is required' });
    if (!body.sssn) return res.status(400).json({ error: 'sssn is required' });

    const created = await service.createDiscipline(body);
    res.status(201).json(created);
  } catch (err) {
    handleError(res, err);
  }
}

export async function updateDiscipline(req: Request, res: Response) {
  try {
    const { action_id } = req.params;
    const body = req.body;

    // prevent action_id change
    if (body && body.action_id && body.action_id !== action_id) {
      return res.status(400).json({ error: 'action_id cannot be changed' });
    }

    const updated = await service.updateDiscipline(action_id, body);
    res.json(updated);
  } catch (err) {
    handleError(res, err);
  }
}

export async function deleteDiscipline(req: Request, res: Response) {
  try {
    const { action_id } = req.params;
    const result = await service.deleteDiscipline(action_id);
    res.json(result);
  } catch (err) {
    handleError(res, err);
  }
}
