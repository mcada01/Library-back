import { Connection } from 'typeorm';
import { Author } from '../../domain/entities/author.entity';

export const AuthorProvider = [
  {
    provide: 'AuthorRepository',
    useFactory: (connection: Connection) => connection.getRepository(Author),
    inject: ['DATABASE_CONNECTION'],
  },
];
