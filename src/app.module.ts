import { Module } from '@nestjs/common';
import { AppService } from './app.service';
import configuration from '../config/configuration';
import { ConfigModule } from '@nestjs/config';
import { AuthorModule } from './infrastructure/modules/author.module';
import { TasksService } from './schedule/TasksService';
import { ScheduleModule } from '@nestjs/schedule';
import { BookModule } from './infrastructure/modules/book.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ScheduleModule.forRoot(),
    AuthorModule,
    BookModule,
  ],
  providers: [AppService, TasksService],
})
export class AppModule {}
