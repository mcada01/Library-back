import { Injectable, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CrudService } from './crud.service';
import { Repository } from 'typeorm';
import { Book } from '../entities/book.entity';

@Injectable()
export class BookService extends CrudService<Book> {
  constructor(
    @InjectRepository(Book)
    private readonly repository: Repository<Book>,
  ) {
    super(repository);
  }
}
