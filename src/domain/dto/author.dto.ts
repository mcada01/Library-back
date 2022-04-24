import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty } from 'class-validator';

export class AuthorDto {
  @ApiProperty()
  @IsNotEmpty()
  nationality: string;
  @ApiProperty()
  @IsNotEmpty()
  firstName: string;
  @ApiProperty({
    required: false,
  })
  secondName: string;
  @ApiProperty()
  @IsNotEmpty()
  lastName: string;
  @ApiProperty({
    required: false,
  })
  secondLastName: string;
}
