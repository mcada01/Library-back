import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { DatabaseModule } from '../database/database.module';
import { LoggerMiddleware } from '../../app/middlewares/logger.middleware';
import { AuthorController } from '../../app/controllers/author.controller';
import { AuthorService } from '../../domain/services/author.service';
import { AuthorProvider } from '../providers/author.provider';
import { BookService } from 'src/domain/services/book.service';
import { BookProvider } from '../providers/book.provider';

@Module({
  imports: [DatabaseModule],
  controllers: [AuthorController],
  providers: [AuthorService, BookService, ...BookProvider, ...AuthorProvider],
  exports: [...AuthorProvider],
})
export class AuthorModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes('authors');
  }
}
