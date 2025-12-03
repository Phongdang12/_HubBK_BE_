import { z } from 'zod';

const MIN_BIRTHDAY = new Date('1980-01-01');
const GUARDIAN_MIN_BIRTHDAY = new Date('1950-01-01');
const GUARDIAN_MAX_BIRTHDAY = new Date('2005-12-31');
const GUARDIAN_RELATIONSHIP_VALUES = ['Father', 'Mother', 'Other'] as const;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PHONE_REGEX = /^(\+?\d{1,3})?[\s-]?(\d{2,4})?[\s-]?\d{7,}$/;

export const STUDENT_GENERAL_ERROR_MESSAGE = 'Vui lòng kiểm tra lại thông tin sinh viên và sửa các lỗi được chỉ ra.';
export const STUDENT_SSN_ERROR_MESSAGE = 'SSN không hợp lệ hoặc đã tồn tại.';
export const STUDENT_ID_ERROR_MESSAGE = 'Mã sinh viên không hợp lệ hoặc đã tồn tại.';
export const STUDENT_BIRTHDAY_ERROR_MESSAGE = 'Ngày sinh không hợp lệ.';
export const STUDENT_EMAIL_ERROR_MESSAGE = 'Email không hợp lệ.';
export const STUDENT_PHONE_ERROR_MESSAGE = 'Số điện thoại không hợp lệ.';
export const STUDENT_SELECTION_ERROR_MESSAGE = 'Trường lựa chọn không hợp lệ. Vui lòng kiểm tra lại các trường đã chọn.';
export const GUARDIAN_SSN_ERROR_MESSAGE = 'CCCD người thân phải gồm 12 chữ số.';
export const GUARDIAN_NAME_ERROR_MESSAGE = 'Tên người thân không hợp lệ.';
export const GUARDIAN_RELATIONSHIP_ERROR_MESSAGE = 'Quan hệ với người thân không hợp lệ.';
export const GUARDIAN_BIRTHDAY_ERROR_MESSAGE = 'Ngày sinh người thân không hợp lệ.';
export const GUARDIAN_PHONE_ERROR_MESSAGE = 'Số điện thoại người thân không hợp lệ.';
export const GUARDIAN_ADDRESS_ERROR_MESSAGE = 'Địa chỉ người thân không hợp lệ.';
export const GUARDIAN_DUPLICATE_CCCD_ERROR_MESSAGE = 'CCCD người thân không được trùng với CCCD của sinh viên.';
export const STUDENT_CCCD_DUPLICATE_MESSAGE = 'CCCD sinh viên không hợp lệ hoặc đã tồn tại.';
const splitMultiValue = (value?: unknown) =>
  typeof value === 'string' && value.length
    ? value.split(/[,;]+/).map((item) => item.trim()).filter(Boolean)
    : [];

export const SsnParam = z.object({
  ssn: z.string().trim().regex(/^\d{8}$/, {
    message: STUDENT_SSN_ERROR_MESSAGE,
  }),
});

// 1. Định nghĩa Shape cơ bản (ZodObject thuần) - CHƯA REFINE
const BaseStudentShape = z.object({
  cccd: z.string().trim().length(12, { message: 'CCCD phải gồm 12 chữ số.' }),
  first_name: z.string().trim().min(1, { message: 'Họ không được để trống.' }),
  last_name: z.string().trim().min(1, { message: 'Tên không được để trống.' }),
  birthday: z.string().trim().refine((val) => {
      const date = new Date(val);
      if (Number.isNaN(date.getTime())) return false;
      date.setHours(0, 0, 0, 0);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      return date >= MIN_BIRTHDAY && date <= today;
    }, { message: STUDENT_BIRTHDAY_ERROR_MESSAGE }),
  sex: z.enum(['M', 'F'], { message: STUDENT_SELECTION_ERROR_MESSAGE }),
  health_state: z.string().nullable().optional(),
  ethnic_group: z.string().trim().min(1, { message: 'Dân tộc không hợp lệ.' }),
  student_id: z.string().trim().regex(/^[A-Za-z0-9]{7}$/, { message: STUDENT_ID_ERROR_MESSAGE }),
  has_health_insurance: z.boolean().nullable().optional(),
  study_status: z.enum(['Active', 'Non_Active'], { message: STUDENT_SELECTION_ERROR_MESSAGE }),
  class_name: z.string().nullable().optional(),
  faculty: z.string().nullable().optional(),
  building_id: z.string().trim().optional().or(z.literal('')).nullable(),
  room_id: z.string().trim().optional().or(z.literal('')).nullable(),
  phone_numbers: z.string().trim(),
  emails: z.string().trim(),
  addresses: z.string().trim(),
  guardian_cccd: z.string().trim().length(12, { message: GUARDIAN_SSN_ERROR_MESSAGE }),
  guardian_name: z.string().trim().min(1, { message: GUARDIAN_NAME_ERROR_MESSAGE }),
  guardian_relationship: z.enum(GUARDIAN_RELATIONSHIP_VALUES, {
    invalid_type_error: GUARDIAN_RELATIONSHIP_ERROR_MESSAGE,
    required_error: GUARDIAN_RELATIONSHIP_ERROR_MESSAGE,
  }),
  guardian_occupation: z.string().trim().optional(),
  guardian_birthday: z.string().trim().refine((val) => {
      const date = new Date(val);
      if (Number.isNaN(date.getTime())) return false;
      return date >= GUARDIAN_MIN_BIRTHDAY && date <= GUARDIAN_MAX_BIRTHDAY;
    }, { message: GUARDIAN_BIRTHDAY_ERROR_MESSAGE }),
  guardian_phone_numbers: z.string().trim(),
  guardian_addresses: z.string().trim(),
});

// 2. Tách logic refine ra một hàm riêng để tái sử dụng
const commonRefinements = (data: any, ctx: z.RefinementCtx) => {
  // --- [NEW] CHECK TRÙNG CCCD ---
  // Kiểm tra nếu cả 2 trường đều có dữ liệu và giống hệt nhau
  if (data.cccd && data.guardian_cccd && data.cccd === data.guardian_cccd) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['guardian_cccd'], // Báo lỗi ngay tại trường CCCD người thân
      message: GUARDIAN_DUPLICATE_CCCD_ERROR_MESSAGE,
    });
  }
  // ------------------------------

  const emailList = splitMultiValue(data.emails);
  const invalidEmail = emailList.find((email: string) => !EMAIL_REGEX.test(email));
  if (invalidEmail) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['emails'], message: STUDENT_EMAIL_ERROR_MESSAGE });
  }

  const phoneList = splitMultiValue(data.phone_numbers);
  const invalidPhone = phoneList.find((phone: string) => !PHONE_REGEX.test(phone));
  if (invalidPhone) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['phone_numbers'], message: STUDENT_PHONE_ERROR_MESSAGE });
  }

  const guardianPhoneList = splitMultiValue(data.guardian_phone_numbers);
  if (guardianPhoneList.length > 0 && guardianPhoneList.some((phone: string) => !PHONE_REGEX.test(phone))) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['guardian_phone_numbers'], message: GUARDIAN_PHONE_ERROR_MESSAGE });
  }

  const guardianAddresses = splitMultiValue(data.guardian_addresses);
  if (guardianAddresses.length > 0 && guardianAddresses.some((addr: string) => addr.length === 0)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['guardian_addresses'], message: GUARDIAN_ADDRESS_ERROR_MESSAGE });
  }
};

// 3. Schema cho CREATE (Sử dụng Shape gốc + Refine)
export const CreateStudentBody = BaseStudentShape.superRefine(commonRefinements);

// 4. Schema cho UPDATE (Extend từ Shape gốc trước, sau đó mới Refine)
export const UpdateStudentBody = BaseStudentShape
  .extend({
    ssn: z.string().trim().regex(/^\d{8}$/, { message: STUDENT_SSN_ERROR_MESSAGE }),
  })
  .superRefine(commonRefinements);

export type SsnParamDto = z.infer<typeof SsnParam>;
export type CreateStudentBodyDto = z.infer<typeof CreateStudentBody>;
export type UpdateStudentBodyDto = z.infer<typeof UpdateStudentBody>;