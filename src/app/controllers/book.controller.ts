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
import { BookService } from '../../domain/services/book.service';
import { BookDto } from '../../domain/dto/book.dto';
import { PaginateOptions } from 'src/domain/services/crud.service';
import { PaginateResponseDto } from 'src/domain/dto/paginated-response.dto';
import { ILike } from 'typeorm';

@Controller('books')
export class BookController {
  constructor(private readonly _service: BookService) {}

  /**
   *
   * @returns {PaginateResponseDto{}} Returns all books with theirs pagination
   * @param {PaginateOptions} request
   */
  @Get()
  public async findAll(@Response() res, @Query() options: PaginateOptions) {
    const { page, offset, search } = options;
    const filter = {};
    const books = await this._service.paginate({
      page,
      offset,
      order: { idBook: 'DESC' },
      relations: ['author'],
      where: [
        ...(search !== null && search !== undefined && search != ''
          ? [
              Number(search) && {
                ...filter,
                idBook: options.search,
              },
              {
                ...filter,
                name: ILike(`%${options.search}%`),
              },
              {
                ...filter,
                author: {
                  firstName: ILike(`%${options.search}%`),
                },
              },
            ]
          : [
              {
                ...filter,
              },
            ]),
      ],
    });

    return res.status(HttpStatus.OK).json(books);
  }

  /**
   *
   * @returns {BookDto{}} Returns a book by id
   * @param {id} request
   */
  @Get('/:id')
  public async findOne(@Response() res, @Param() param) {
    const book = await this._service.findOne({
      where: { idBook: param.id },
      relations: ['author'],
    });

    if (book) {
      return res.status(HttpStatus.OK).json(book);
    }

    return res
      .status(HttpStatus.NOT_FOUND)
      .json({ message: "Book doesn't exist!" });
  }

  /**
   *
   * @returns {BookDto{}} Returns a new book
   * @param {BookDto} request
   */
  @Post()
  public async create(@Response() res, @Body() bookDto: BookDto) {
    const bookExists = await this._service.findOne({
      where: {
        name: bookDto.name,
        idAuthor: bookDto.idAuthor,
      },
    });
    if (bookExists) {
      return res
        .status(HttpStatus.FOUND)
        .json({ message: 'Book already exists!' });
    }

    const book = await this._service.create(bookDto);
    return res.status(HttpStatus.OK).json(book);
  }

  /**
   *
   * @returns {BookDto{}} Returns the deleted book
   * @param {id} request
   * @param {BookDto} request
   */
  @Delete('/:id')
  public async delete(@Param() param, @Response() res) {
    const options = { where: { idBook: param.id } };

    const book = await this._service.delete(options);
    if (book) {
      return res.status(HttpStatus.OK).json(book);
    }
  }

  /**
   *
   * @returns {BookDto{}} Returns a updated book
   * @param {id} request
   * @param {BookDto} request
   */
  @Patch('/:id')
  public async update(@Param() param, @Response() res, @Body() body) {
    const bookExists = await this._service.findOne({
      where: {
        name: body.name,
        idAuthor: body.idAuthor,
      },
    });
    if (bookExists && param.id != bookExists.idBook) {
      return res
        .status(HttpStatus.FOUND)
        .json({ message: 'Book already exists!' });
    }

    const options = { where: { idBook: param.id } };
    const book = await this._service.update(body, options);

    if (book) {
      return res.status(HttpStatus.OK).json(book);
    }

    return res
      .status(HttpStatus.NOT_FOUND)
      .json({ message: "Book doesn't exist!" });
  }
}
