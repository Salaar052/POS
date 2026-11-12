import { ValidationPipe } from '@nestjs/common';

import { NestFactory } from '@nestjs/core';
import type { Express } from 'express';

import { AppModule } from './app.module';

import { assertJwtAccessSecretConfigured } from './config/auth.config';

async function bootstrap() {
  assertJwtAccessSecretConfigured();

  const app = await NestFactory.create(AppModule);

  const trustProxyHops = process.env.TRUST_PROXY_HOPS?.trim();

  if (trustProxyHops && Number.parseInt(trustProxyHops, 10) > 0) {
    const express = app.getHttpAdapter().getInstance() as Express;
    express.set('trust proxy', Number.parseInt(trustProxyHops, 10));
  }

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,

      forbidNonWhitelisted: true,

      transform: true,
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
}

void bootstrap();
