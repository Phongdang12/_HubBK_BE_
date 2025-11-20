// src/controllers/discipline.controller.ts
import { Request, Response } from 'express';
import { ZodError, ZodIssue } from 'zod';
import * as service from '@/Services/discipline.service';
import {
  ActionIdParamSchema,
  DisciplineUpsertInput,
  DisciplineUpsertSchema,
  GENERAL_FORM_ERROR_MESSAGE,
  ACTION_ID_ERROR_MESSAGE,
  STUDENT_CODE_ERROR_MESSAGE,
} from '@/App/Validations/discipline.validator';

type FieldError = {
  field: string;
  message: string;
};

function handleError(res: Response, err: any) {
  if (err && typeof err === 'object' && err.status) {
    return res.status(err.status).json({ error: err.message || 'Error' });
  }
  console.error('Unexpected error:', err);
  return res.status(500).json({ error: 'Internal server error' });
}

function logFieldError(message: string, value: unknown) {
  const printable =
    value === undefined || value === null || value === ''
      ? 'Không có'
      : JSON.stringify(value);
  console.error(`Lỗi: ${message} Giá trị được chọn: ${printable}.`);
}

function respondWithFieldErrors(
  res: Response,
  fieldErrors: FieldError[],
  source?: Record<string, unknown>,
  status = 400
) {
  fieldErrors.forEach((error) => {
    const value = source ? source[error.field] : undefined;
    logFieldError(error.message, value);
  });
  return res.status(status).json({
    error: GENERAL_FORM_ERROR_MESSAGE,
    fieldErrors,
  });
}

function mapIssuesToFieldErrors(issues: ZodIssue[]): FieldError[] {
  return issues.map((issue) => ({
    field: issue.path?.[0]?.toString() || 'form',
    message: issue.message,
  }));
}

function validateActionIdParam(res: Response, params: Request['params']) {
  const parsed = ActionIdParamSchema.safeParse(params);
  if (!parsed.success) {
    const fieldErrors = mapIssuesToFieldErrors(parsed.error.issues);
    respondWithFieldErrors(res, fieldErrors, params);
    return null;
  }
  return parsed.data.action_id;
}

async function ensureStudentExists(res: Response, sssn: string) {
  const exists = await service.doesStudentExist(sssn);
  if (!exists) {
    respondWithFieldErrors(
      res,
      [{ field: 'sssn', message: STUDENT_CODE_ERROR_MESSAGE }],
      { sssn }
    );
    return false;
  }
  return true;
}

function parseDisciplinePayload(res: Response, rawBody: unknown) {
  const parsed = DisciplineUpsertSchema.safeParse(rawBody);
  if (!parsed.success) {
    const fieldErrors = mapIssuesToFieldErrors(parsed.error.issues);
    respondWithFieldErrors(res, fieldErrors, rawBody as Record<string, unknown>);
    return null;
  }
  return parsed.data;
}

function normalisePayload(payload: DisciplineUpsertInput): DisciplineUpsertInput {
  return {
    ...payload,
    effective_to: payload.effective_to || '',
  };
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
    const action_id = validateActionIdParam(res, req.params);
    if (!action_id) return;
    const row = await service.getDisciplineById(action_id);
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  } catch (err) {
    handleError(res, err);
  }
}

export async function createDiscipline(req: Request, res: Response) {
  try {
    const parsedBody = parseDisciplinePayload(res, req.body);
    if (!parsedBody) return;
    const payload = normalisePayload(parsedBody);

    const exists = await service.getDisciplineById(payload.action_id);
    if (exists) {
      respondWithFieldErrors(
        res,
        [{ field: 'action_id', message: ACTION_ID_ERROR_MESSAGE }],
        { action_id: payload.action_id },
        409
      );
      return;
    }

    const studentIsValid = await ensureStudentExists(res, payload.sssn);
    if (!studentIsValid) return;

    const createPayload: service.DisciplineCreateDTO = {
      ...payload,
      severity_level: payload.severity_level as service.DisciplineCreateDTO['severity_level'],
      status: payload.status as service.DisciplineCreateDTO['status'],
    };

    const created = await service.createDiscipline(createPayload);
    res.status(201).json(created);
  } catch (err) {
    if (err instanceof ZodError) {
      respondWithFieldErrors(res, mapIssuesToFieldErrors(err.issues), req.body);
      return;
    }
    handleError(res, err);
  }
}

export async function updateDiscipline(req: Request, res: Response) {
  try {
    const action_id = validateActionIdParam(res, req.params);
    if (!action_id) return;

    const parsedBody = parseDisciplinePayload(res, { ...req.body, action_id });
    if (!parsedBody) return;

    if (parsedBody.action_id !== action_id) {
      respondWithFieldErrors(
        res,
        [{ field: 'action_id', message: ACTION_ID_ERROR_MESSAGE }],
        { action_id: parsedBody.action_id }
      );
      return;
    }

    const studentIsValid = await ensureStudentExists(res, parsedBody.sssn);
    if (!studentIsValid) return;

    const updatePayload: service.DisciplineUpdateDTO = {
      ...parsedBody,
      severity_level: parsedBody.severity_level as service.DisciplineCreateDTO['severity_level'],
      status: parsedBody.status as service.DisciplineCreateDTO['status'],
    };

    const updated = await service.updateDiscipline(action_id, updatePayload);
    res.json(updated);
  } catch (err) {
    handleError(res, err);
  }
}

export async function deleteDiscipline(req: Request, res: Response) {
  try {
    const action_id = validateActionIdParam(res, req.params);
    if (!action_id) return;
    const result = await service.deleteDiscipline(action_id);
    res.json(result);
  } catch (err) {
    handleError(res, err);
  }
}
