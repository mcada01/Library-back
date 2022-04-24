import { Connection } from 'typeorm';
import { Book } from '../../domain/entities/book.entity';

export const BookProvider = [
  {
    provide: 'BookRepository',
    useFactory: (connection: Connection) => connection.getRepository(Book),
    inject: ['DATABASE_CONNECTION'],
  },
];
