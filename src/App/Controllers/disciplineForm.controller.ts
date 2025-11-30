// fileName: src/App/Controllers/disciplineForm.controller.ts
import { Request, Response } from 'express';
import * as service from '@/Services/disciplineForm.service';

export async function listForms(req: Request, res: Response) {
  try {
    // Query param ?active=true để lọc
    const onlyActive = req.query.active === 'true';
    const data = await service.getAllForms(onlyActive);
    res.json(data);
  } catch (err) {
    console.error('List Forms Error:', err);
    res.status(500).json({ error: 'Failed to fetch forms' });
  }
}

export async function addForm(req: Request, res: Response) {
  try {
    const { name, description } = req.body;
    if (!name) {
        return res.status(400).json({ error: 'Name is required' });
    }
    
    const data = await service.createForm(name, description);
    res.status(201).json(data);
  } catch (err: any) {
    console.error('Create Form Error:', err);
    // Lỗi trùng tên (Unique constraint)
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Form name already exists' });
    }
    res.status(500).json({ error: 'Failed to create form' });
  }
}

export async function removeForm(req: Request, res: Response) {
  try {
    const { id } = req.params;
    if (!id) return res.status(400).json({ error: 'ID is required' });

    const result = await service.deleteForm(Number(id));
    res.json(result);
  } catch (err: any) {
    console.error('Delete Form Error:', err);
    if (err.status === 404) {
        return res.status(404).json({ error: err.message });
    }
    res.status(500).json({ error: 'Failed to delete form' });
  }
}
export async function toggleStatus(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { is_active } = req.body; // Nhận true/false từ client
    
    await service.toggleStatus(Number(id), is_active);
    res.json({ message: 'Status updated successfully' });
  } catch (err) {
    console.error('Toggle Status Error:', err);
    res.status(500).json({ error: 'Failed to update status' });
  }
}