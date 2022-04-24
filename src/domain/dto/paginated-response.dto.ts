import { ApiResponseProperty } from '@nestjs/swagger';

export class PaginateResponseDto {
  @ApiResponseProperty()
  readonly total: number;
  @ApiResponseProperty()
  readonly page: number;
  @ApiResponseProperty()
  readonly totalPages: number;
  @ApiResponseProperty()
  readonly items: [];
  @ApiResponseProperty()
  readonly next: number;
  @ApiResponseProperty()
  readonly prev: number;
}
