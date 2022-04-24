import { ConfigService } from '@nestjs/config';
import { Book } from 'src/domain/entities/book.entity';
import { createConnection } from 'typeorm';
import { Author } from '../../domain/entities/author.entity';

export const databaseProviders = [
  {
    provide: 'DATABASE_CONNECTION',
    inject: [ConfigService],
    useFactory: async (configService: ConfigService) => {
      return await createConnection({
        type: 'postgres',
        host: configService.get<string>('database.host'),
        port: configService.get<number>('database.port'),
        username: configService.get<string>('database.username'),
        password: configService.get<string>('database.password'),
        database: configService.get<string>('database.database'),
        entities: [Author, Book],

        synchronize: true,
        logging: true,
      });
    },
  },
];
