import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { AuthService } from '../src/auth/auth.service';
import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  UserStatus,
} from '@prisma/client';

describe('Auth controller (e2e)', () => {
  let app: INestApplication<App>;

  const loginMock = jest.fn();
  const restoreMock = jest.fn();
  const logoutMock = jest.fn();

  beforeEach(async () => {
    loginMock.mockReset();
    restoreMock.mockReset();
    logoutMock.mockReset();

    loginMock.mockResolvedValue({
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      accessTokenExpiresInSeconds: 900,
      user: {
        id: '22222222-2222-4222-8222-222222222222',
        name: 'Owner',
        email: 'owner@example.com',
        status: UserStatus.ACTIVE,
      },
      business: {
        id: '11111111-1111-4111-8111-111111111111',
        name: 'Shop',
        status: BusinessStatus.ACTIVE,
      },
      membership: {
        id: '33333333-3333-4333-8333-333333333333',
        role: MembershipRole.OWNER,
        status: MembershipStatus.ACTIVE,
      },
    });

    restoreMock.mockResolvedValue(loginMock.mock.results[0]?.value);
    logoutMock.mockResolvedValue({ serverRevoked: true });

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(AuthService)
      .useValue({
        login: loginMock,
        restoreSession: restoreMock,
        logout: logoutMock,
        getMeFromAccessToken: jest.fn(),
        verifyAccessToken: jest.fn(),
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('POST /auth/login validates body and delegates', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'owner@example.com',
        password: 'short',
        businessId: '11111111-1111-4111-8111-111111111111',
      })
      .expect(400);

    await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'owner@example.com',
        password: 'valid-password-99',
        businessId: '11111111-1111-4111-8111-111111111111',
      })
      .expect(200);

    expect(loginMock).toHaveBeenCalledTimes(1);
  });
});
