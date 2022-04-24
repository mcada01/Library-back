import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger, ValidationPipe } from '@nestjs/common';
import { RedocModule, RedocOptions } from 'nestjs-redoc';
import * as bodyParser from 'body-parser';

const PORT = process.env.APP_PORT;
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(bodyParser.json({ limit: '50mb' }));
  app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

  app.useGlobalPipes(new ValidationPipe());

  app.setGlobalPrefix('api/v1');

  const redocOptionsFullApi: RedocOptions = {
    title: 'Libreria Meli',
    sortPropsAlphabetically: true,
    hideDownloadButton: false,
    hideHostname: false,
    auth: {
      enabled: false,
      user: 'admin',
      password: '123',
    },
  };

  const redocOptions: RedocOptions = {
    title: 'Libreria Meli',
    sortPropsAlphabetically: true,
    hideDownloadButton: false,
    hideHostname: false,
    auth: {
      enabled: false,
      user: 'admin',
      password: '123',
    },
  };

  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    preflightContinue: false,
    optionsSuccessStatus: 200,
    credentials: true,
    allowedHeaders:
      'Origin,X-Requested-With,Content-Type,Accept,Authorization,authorization,X-Forwarded-for',
  });

  await app.listen(PORT);
}

bootstrap().then(() => {
  const logger: Logger = new Logger('MainApplication');
  logger.debug(`Server started on port ${process.env.APP_HOST}`);
});
