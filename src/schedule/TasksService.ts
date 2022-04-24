import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class TasksService {
  private readonly logger = new Logger(TasksService.name);

  //Runing a job at 6pm,8pm and 11pm
  //@Cron('0 18,20,23 * * *')
  @Cron(CronExpression.EVERY_30_SECONDS)
  handleCron() {
    //this.logger.debug('Called every 30 seconds');
  }
}
