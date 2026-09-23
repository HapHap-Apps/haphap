import { Role } from '../../generated/prisma/enums.js';

export class CurrentUserDto {
  id!: string;
  role!: Role;
}
