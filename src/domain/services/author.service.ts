import { Injectable, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CrudService } from './crud.service';
import { Repository } from 'typeorm';
import { Author } from '../entities/author.entity';

@Injectable()
export class AuthorService extends CrudService<Author> {
  constructor(
    @InjectRepository(Author)
    private readonly repository: Repository<Author>,
  ) {
    super(repository);
  }
}
