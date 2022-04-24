import {
  Body,
  Controller,
  Delete,
  Get,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  Response,
  Request,
} from '@nestjs/common';
import { AuthorService } from '../../domain/services/author.service';
import { AuthorDto } from '../../domain/dto/author.dto';
import { PaginateOptions } from 'src/domain/services/crud.service';
import { PaginateResponseDto } from 'src/domain/dto/paginated-response.dto';
import { ILike } from 'typeorm';
import { BookService } from 'src/domain/services/book.service';

@Controller('authors')
export class AuthorController {
  constructor(
    private readonly _service: AuthorService,
    private readonly _serviceBook: BookService,
  ) {}

  /**
   *
   * @returns {PaginateResponseDto{}} Returns all authors with theirs pagination
   * @param {PaginateOptions} request
   */
  @Get()
  public async findAll(@Response() res, @Query() options: PaginateOptions) {
    const { page, offset, search } = options;
    const filter = {};
    const authors = await this._service.paginate({
      page,
      offset,
      order: { idAuthor: 'DESC' },
      where: [
        ...(search !== null && search !== undefined && search != ''
          ? [
              Number(search) && {
                ...filter,
                idAuthor: options.search,
              },
              {
                ...filter,
                nationality: ILike(`%${options.search}%`),
              },
              {
                ...filter,
                firstName: ILike(`%${options.search}%`),
              },
              {
                ...filter,
                secondName: ILike(`%${options.search}%`),
              },
              {
                ...filter,
                lastName: ILike(`%${options.search}%`),
              },
              {
                ...filter,
                secondLastName: ILike(`%${options.search}%`),
              },
            ]
          : [
              {
                ...filter,
              },
            ]),
      ],
    });

    return res.status(HttpStatus.OK).json(authors);
  }

  /**
   *
   * @returns {AuthorDto{}} Returns a author by id
   * @param {id} request
   */
  @Get('/:id')
  public async findOne(@Response() res, @Param() param) {
    const author = await this._service.findOne({
      where: { idAuthor: param.id },
    });

    if (author) {
      return res.status(HttpStatus.OK).json(author);
    }

    return res
      .status(HttpStatus.NOT_FOUND)
      .json({ message: "Author doesn't exist!" });
  }

  /**
   *
   * @returns {AuthorDto{}} Returns a new author
   * @param {AuthorDto} request
   */
  @Post()
  public async create(@Response() res, @Body() authorDto: AuthorDto) {
    authorDto.nationality = authorDto.nationality.toUpperCase();
    authorDto.firstName = authorDto.firstName.toUpperCase();
    authorDto.secondName = authorDto.secondName.toUpperCase();
    authorDto.lastName = authorDto.lastName.toUpperCase();
    authorDto.secondLastName = authorDto.secondLastName.toUpperCase();
    const authorExists = await this._service.findOne({
      where: {
        nationality: authorDto.nationality,
        firstName: authorDto.firstName,
        lastName: authorDto.lastName,
      },
    });
    if (authorExists) {
      return res
        .status(HttpStatus.FOUND)
        .json({ message: 'Author already exists!' });
    }

    const author = await this._service.create(authorDto);
    return res.status(HttpStatus.OK).json(author);
  }

  /**
   *
   * @returns {AuthorDto{}} Returns the deleted author
   * @param {id} request
   * @param {AuthorDto} request
   */
  @Delete('/:id')
  public async delete(@Param() param, @Response() res) {
    const options = { where: { idAuthor: param.id } };
    const bookExist = await this._serviceBook.findOne(options);
    if (bookExist) {
      return res.status(HttpStatus.FOUND).json({
        message:
          'You can´t delete this author because he has books registered!',
      });
    }

    const author = await this._service.delete(options);
    if (author) {
      return res.status(HttpStatus.OK).json(author);
    }
  }

  /**
   *
   * @returns {AuthorDto{}} Returns a updated author
   * @param {id} request
   * @param {AuthorDto} request
   */
  @Patch('/:id')
  public async update(@Param() param, @Response() res, @Body() body) {
    body.nationality = body.nationality.toUpperCase();
    body.firstName = body.firstName.toUpperCase();
    body.secondName = body.secondName.toUpperCase();
    body.lastName = body.lastName.toUpperCase();
    body.secondLastName = body.secondLastName.toUpperCase();
    const authorExists = await this._service.findOne({
      where: {
        nationality: body.nationality,
        firstName: body.firstName,
        lastName: body.lastName,
      },
    });
    if (authorExists && param.id != authorExists.idAuthor) {
      return res
        .status(HttpStatus.FOUND)
        .json({ message: 'Author already exists!' });
    }

    const options = { where: { idAuthor: param.id } };
    const author = await this._service.update(body, options);

    if (author) {
      return res.status(HttpStatus.OK).json(author);
    }

    return res
      .status(HttpStatus.NOT_FOUND)
      .json({ message: "Author doesn't exist!" });
  }
}
