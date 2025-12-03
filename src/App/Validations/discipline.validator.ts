import { z } from 'zod';

export const GENERAL_FORM_ERROR_MESSAGE =
  'Vui lòng kiểm tra lại thông tin đã nhập và sửa các lỗi được chỉ ra.';
export const ACTION_ID_ERROR_MESSAGE = 'Mã hành động không hợp lệ.';
export const STUDENT_CODE_ERROR_MESSAGE = 'Mã sinh viên không hợp lệ (phải gồm 7 chữ số).';
export const ACTION_TYPE_ERROR_MESSAGE = 'Vui lòng chọn hình thức kỷ luật.';
export const SEVERITY_ERROR_MESSAGE =
  'Mức độ nghiêm trọng không hợp lệ. Vui lòng chọn: Low, Medium, High, Expulsion.';
export const STATUS_ERROR_MESSAGE =
  'Trạng thái không hợp lệ. Vui lòng chọn: Active, Pending, Completed, Cancelled.';
export const REASON_ERROR_MESSAGE = 'Lý do phải từ 10 đến 500 ký tự.';
export const DECISION_DATE_ERROR_MESSAGE =
  "Ngày quyết định không hợp lệ. Ngày quyết định không được là ngày trong tương lai.";
export const EFFECTIVE_FROM_ERROR_MESSAGE =
  'Ngày bắt đầu không hợp lệ.';
export const EFFECTIVE_TO_ERROR_MESSAGE =
  'Ngày kết thúc phải lớn hơn ngày bắt đầu (hoặc để trống nếu vô thời hạn).';

export const VALID_SEVERITY_LEVELS = ['low', 'medium', 'high', 'expulsion'] as const;
export const VALID_STATUS_VALUES = ['active', 'pending', 'completed', 'cancelled'] as const;

// ❌ ĐÃ XÓA: VALID_ACTION_TYPES (Vì giờ form lấy từ DB, không fix cứng nữa)

const ACTION_ID_PATTERN = /^DA\d{3,}$/;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

const baseSchema = z
  .object({
    // 🔄 SỬA: Cho phép Action ID rỗng (Auto Generated)
    action_id: z
      .string()
      .trim()
      .transform((val) => val.toUpperCase())
      .optional()
      .or(z.literal('')), 

    student_id: z
      .string()
      .trim()
      .refine((val) => /^\d{7}$/.test(val), {
        message: STUDENT_CODE_ERROR_MESSAGE,
      }),

    // 🔄 SỬA: Form động -> Chỉ cần check chuỗi không rỗng
    action_type: z
      .string()
      .trim()
      .min(1, { message: ACTION_TYPE_ERROR_MESSAGE }),

    severity_level: z
      .string()
      .trim()
      .transform((val) => val.toLowerCase())
      .refine((val) => VALID_SEVERITY_LEVELS.includes(val as any), {
        message: SEVERITY_ERROR_MESSAGE,
      }),

    status: z
      .string()
      .trim()
      .transform((val) => val.toLowerCase())
      .refine((val) => VALID_STATUS_VALUES.includes(val as any), {
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

    // 🔄 SỬA: Effective To có thể null/rỗng
    effective_to: z
      .string()
      .trim()
      .optional()
      .nullable()
      .or(z.literal('')), 
  })
  .superRefine((data, ctx) => {
    // 1. Check Decision Date
    const decisionDate = new Date(data.decision_date);
    if (Number.isNaN(decisionDate.getTime())) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['decision_date'],
        message: DECISION_DATE_ERROR_MESSAGE,
      });
    }

    // 2. Check Effective From
    const effectiveFrom = new Date(data.effective_from);
    if (Number.isNaN(effectiveFrom.getTime())) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['effective_from'],
        message: EFFECTIVE_FROM_ERROR_MESSAGE,
      });
    }

    // 3. Check Effective To (Chỉ check nếu có dữ liệu)
    if (data.effective_to) {
      const effectiveTo = new Date(data.effective_to);
      
      if (Number.isNaN(effectiveTo.getTime())) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['effective_to'],
          message: 'Ngày kết thúc không đúng định dạng.',
        });
      } else if (effectiveFrom >= effectiveTo) {
        // Logic cũ: From < To
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['effective_to'],
          message: EFFECTIVE_TO_ERROR_MESSAGE,
        });
      }
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