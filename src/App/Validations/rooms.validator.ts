import { z } from 'zod';

export const ROOM_STATUS_VALUES = ['Available', 'Occupied', 'Under Maintenance'] as const;

export const MAX_STUDENTS_ERROR =
  'Số lượng sinh viên tối đa không hợp lệ. Vui lòng nhập số lớn hơn hoặc bằng số sinh viên hiện tại.';
export const CURRENT_STUDENTS_ERROR =
  'Số lượng sinh viên hiện tại không thể vượt quá số lượng tối đa.';
export const OCCUPANCY_RATE_ERROR = 'Tỷ lệ chiếm dụng không chính xác, vui lòng kiểm tra lại.';
export const RENTAL_PRICE_ERROR =
  'Giá phòng phải lớn hơn hoặc bằng 10 triệu VND. Vui lòng nhập lại.';
export const ROOM_STATUS_ERROR =
  'Trạng thái phòng không hợp lệ. Vui lòng chọn một trạng thái hợp lệ.';
export const STUDENT_NOT_FOUND_ERROR = 'Sinh viên không tồn tại trong hệ thống.';
export const STUDENT_NOT_IN_ROOM_ERROR = 'Sinh viên không thuộc phòng này.';
export const GENERAL_ROOM_ERROR =
  'Vui lòng kiểm tra lại thông tin phòng và sửa các lỗi được chỉ ra.';

export const BuildingIdParams = z.object({
  buildingId: z.string().min(1, 'buildingId is required').max(5, 'buildingId is invalid'),
});

export const RoomCheckParams = z.object({
  buildingId: z.string().min(1, 'buildingId is required').max(5, 'buildingId is invalid'),
  roomId: z.string().min(1, 'roomId is required').max(5, 'roomId is invalid'),
});

export const RoomStudentParams = RoomCheckParams.extend({
  sssn: z
    .string()
    .trim()
    .regex(/^\d{8}$/, { message: STUDENT_NOT_FOUND_ERROR }),
});

const parseOccupancyValue = (value: unknown) => {
  if (typeof value === 'number') return value;
  if (typeof value === 'string' && value.trim() !== '') {
    const parsed = Number(value);
    if (!Number.isNaN(parsed)) return parsed;
  }
  return null;
};

export const RoomUpdateBody = z
  .object({
    max_num_of_students: z
      .number({
        required_error: MAX_STUDENTS_ERROR,
        invalid_type_error: MAX_STUDENTS_ERROR,
      })
      .int({ message: MAX_STUDENTS_ERROR })
      .positive({ message: MAX_STUDENTS_ERROR }),
    current_num_of_students: z
      .number({
        required_error: CURRENT_STUDENTS_ERROR,
        invalid_type_error: CURRENT_STUDENTS_ERROR,
      })
      .int({ message: CURRENT_STUDENTS_ERROR })
      .nonnegative({ message: CURRENT_STUDENTS_ERROR }),
    rental_price: z
      .number({
        required_error: RENTAL_PRICE_ERROR,
        invalid_type_error: RENTAL_PRICE_ERROR,
      })
      .min(10_000_000, { message: RENTAL_PRICE_ERROR }),
    room_status: z.enum(ROOM_STATUS_VALUES, {
      invalid_type_error: ROOM_STATUS_ERROR,
      required_error: ROOM_STATUS_ERROR,
    }),
    occupancy_rate: z.union([z.number(), z.string()]).optional(),
  })
  .superRefine((data, ctx) => {
    if (data.max_num_of_students < data.current_num_of_students) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['max_num_of_students'],
        message: MAX_STUDENTS_ERROR,
      });
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['current_num_of_students'],
        message: CURRENT_STUDENTS_ERROR,
      });
    }

    const expectedOccupancy =
      data.max_num_of_students === 0
        ? 0
        : Number(((data.current_num_of_students / data.max_num_of_students) * 100).toFixed(2));

    const providedOccupancy = parseOccupancyValue(data.occupancy_rate);
    if (providedOccupancy !== null && Math.abs(providedOccupancy - expectedOccupancy) > 0.01) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['occupancy_rate'],
        message: OCCUPANCY_RATE_ERROR,
      });
    }
  });

export const RoomStudentMutationBody = z.object({
  sssn: z
    .string({
      required_error: STUDENT_NOT_FOUND_ERROR,
      invalid_type_error: STUDENT_NOT_FOUND_ERROR,
    })
    .trim()
    .regex(/^\d{8}$/, { message: STUDENT_NOT_FOUND_ERROR }),
});
export const TransferStudentBody = z.object({
  sssn: z.string().trim().regex(/^\d{8}$/, { message: 'SSN không hợp lệ' }),
  targetBuildingId: z.string().min(1).max(5),
  targetRoomId: z.string().min(1).max(5),
});

export type TransferStudentBodyDto = z.infer<typeof TransferStudentBody>;
export type BuildingIdParamsDto = z.infer<typeof BuildingIdParams>;
export type RoomCheckParamsDto = z.infer<typeof RoomCheckParams>;
export type RoomStudentParamsDto = z.infer<typeof RoomStudentParams>;
export type RoomUpdateBodyDto = z.infer<typeof RoomUpdateBody>;
export type RoomStudentMutationBodyDto = z.infer<typeof RoomStudentMutationBody>;