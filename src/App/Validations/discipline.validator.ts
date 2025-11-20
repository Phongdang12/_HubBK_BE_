import { z } from 'zod';

export const GENERAL_FORM_ERROR_MESSAGE =
  'Vui lòng kiểm tra lại thông tin đã nhập và sửa các lỗi được chỉ ra.';
export const ACTION_ID_ERROR_MESSAGE = 'Mã hành động đã tồn tại hoặc không hợp lệ.';
export const STUDENT_CODE_ERROR_MESSAGE = 'Mã sinh viên không hợp lệ hoặc không tồn tại trong hệ thống.';
export const ACTION_TYPE_ERROR_MESSAGE =
  'Loại hình kỷ luật không hợp lệ. Vui lòng chọn một trong các lựa chọn hợp lệ.';
export const SEVERITY_ERROR_MESSAGE =
  'Mức độ nghiêm trọng không hợp lệ. Vui lòng chọn một trong các mức độ: Low, Medium, High, Expulsion.';
export const STATUS_ERROR_MESSAGE =
  'Trạng thái không hợp lệ. Vui lòng chọn một trong các trạng thái: Active, Pending, Completed, Cancelled.';
export const REASON_ERROR_MESSAGE = 'Lý do không hợp lệ. Vui lòng nhập lý do rõ ràng và hợp lý.';
export const DECISION_DATE_ERROR_MESSAGE =
  'Ngày quyết định không hợp lệ. Ngày quyết định phải lớn hơn hoặc bằng ngày hiện tại.';
export const EFFECTIVE_FROM_ERROR_MESSAGE =
  'Ngày bắt đầu có hiệu lực phải nhỏ hơn ngày kết thúc có hiệu lực.';
export const EFFECTIVE_TO_ERROR_MESSAGE =
  'Ngày kết thúc có hiệu lực phải lớn hơn ngày bắt đầu có hiệu lực.';

export const VALID_SEVERITY_LEVELS = ['low', 'medium', 'high', 'expulsion'] as const;
export const VALID_STATUS_VALUES = ['active', 'pending', 'completed', 'cancelled'] as const;
export const VALID_ACTION_TYPES = [
  'Cafeteria Duty',
  'Cleaning Duty',
  'Community Service',
  'Dorm Cleaning',
  'Library Service',
  'Yard Cleaning',
  'Classroom Setup',
  'Hall Monitoring',
  'Expulsion',
] as const;

const ACTION_ID_PATTERN = /^DA\d{3,}$/;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

const baseSchema = z
  .object({
    action_id: z
      .string()
      .trim()
      .min(1, { message: ACTION_ID_ERROR_MESSAGE })
      .transform((val) => val.toUpperCase())
      .refine((val) => ACTION_ID_PATTERN.test(val), {
        message: ACTION_ID_ERROR_MESSAGE,
      }),
    sssn: z
      .string()
      .trim()
      .refine((val) => /^\d{8}$/.test(val), {
        message: STUDENT_CODE_ERROR_MESSAGE,
      }),
    action_type: z
      .string()
      .trim()
      .refine((val) => VALID_ACTION_TYPES.includes(val as (typeof VALID_ACTION_TYPES)[number]), {
        message: ACTION_TYPE_ERROR_MESSAGE,
      }),
    severity_level: z
      .string()
      .trim()
      .transform((val) => val.toLowerCase())
      .refine((val) => VALID_SEVERITY_LEVELS.includes(val as (typeof VALID_SEVERITY_LEVELS)[number]), {
        message: SEVERITY_ERROR_MESSAGE,
      }),
    status: z
      .string()
      .trim()
      .transform((val) => val.toLowerCase())
      .refine((val) => VALID_STATUS_VALUES.includes(val as (typeof VALID_STATUS_VALUES)[number]), {
        message: STATUS_ERROR_MESSAGE,
      }),
    reason: z
      .string()
      .trim()
      .min(10, { message: REASON_ERROR_MESSAGE })
      .max(500, { message: REASON_ERROR_MESSAGE }),
    decision_date: z
      .string()
      .trim()
      .regex(DATE_PATTERN, { message: DECISION_DATE_ERROR_MESSAGE }),
    effective_from: z
      .string()
      .trim()
      .regex(DATE_PATTERN, { message: EFFECTIVE_FROM_ERROR_MESSAGE }),
    effective_to: z
      .string()
      .trim()
      .regex(DATE_PATTERN, { message: EFFECTIVE_TO_ERROR_MESSAGE }),
  })
  .superRefine((data, ctx) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const decisionDate = new Date(data.decision_date);
    if (Number.isNaN(decisionDate.getTime()) || decisionDate < today) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['decision_date'],
        message: DECISION_DATE_ERROR_MESSAGE,
      });
    }

    const effectiveFrom = new Date(data.effective_from);
    const effectiveTo = new Date(data.effective_to);
    if (
      Number.isNaN(effectiveFrom.getTime()) ||
      Number.isNaN(effectiveTo.getTime()) ||
      effectiveFrom >= effectiveTo
    ) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['effective_from'],
        message: EFFECTIVE_FROM_ERROR_MESSAGE,
      });
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['effective_to'],
        message: EFFECTIVE_TO_ERROR_MESSAGE,
      });
    }
  });

export const DisciplineUpsertSchema = baseSchema;
export type DisciplineUpsertInput = z.infer<typeof DisciplineUpsertSchema>;

export const ActionIdParamSchema = z.object({
  action_id: z
    .string()
    .trim()
    .transform((val) => val.toUpperCase())
    .refine((val) => ACTION_ID_PATTERN.test(val), {
      message: ACTION_ID_ERROR_MESSAGE,
    }),
});


