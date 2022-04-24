import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { DatabaseModule } from '../database/database.module';
import { LoggerMiddleware } from '../../app/middlewares/logger.middleware';
import { BookController } from '../../app/controllers/book.controller';
import { BookService } from '../../domain/services/book.service';
import { BookProvider } from '../providers/book.provider';

@Module({
  imports: [DatabaseModule],
  controllers: [BookController],
  providers: [BookService, ...BookProvider],
  exports: [...BookProvider],
})
export class BookModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes('books');
  }
}
