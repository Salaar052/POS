import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { BusinessRegistrationService } from '../src/businesses/business-registration.service';
import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  UserStatus,
} from '@prisma/client';

describe('Business registration (e2e)', () => {
  let app: INestApplication<App>;

  const registerMock = jest.fn();

  beforeEach(async () => {
    registerMock.mockReset();
    registerMock.mockResolvedValue({
      business: {
        id: '11111111-1111-4111-8111-111111111111',
        name: 'Test Shop',
        phone: null,
        email: null,
        currencyCode: 'PKR',
        timezone: 'Asia/Karachi',
        status: BusinessStatus.ACTIVE,
        createdAt: '2026-01-01T00:00:00.000Z',
      },
      owner: {
        id: '22222222-2222-4222-8222-222222222222',
        name: 'Test Owner',
        email: 'owner@example.com',
        status: UserStatus.PENDING_VERIFICATION,
        createdAt: '2026-01-01T00:00:00.000Z',
      },
      membership: {
        id: '33333333-3333-4333-8333-333333333333',
        role: MembershipRole.OWNER,
        status: MembershipStatus.ACTIVE,
      },
    });

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(BusinessRegistrationService)
      .useValue({ register: registerMock })
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

  it('POST /businesses/register accepts valid payload', () => {
    return request(app.getHttpServer())
      .post('/businesses/register')
      .send({
        businessName: 'Test Shop',
        ownerName: 'Test Owner',
        ownerEmail: 'owner@example.com',
        password: 'secure-password-42',
      })
      .expect(201)
      .expect((res) => {
        const body = res.body as {
          business: { name: string };
          membership: { role: string };
        };
        expect(body.business.name).toBe('Test Shop');
        expect(body.membership.role).toBe('OWNER');
        expect(JSON.stringify(body)).not.toContain('secure-password-42');
      });
  });

  it('rejects client-supplied businessId', () => {
    return request(app.getHttpServer())
      .post('/businesses/register')
      .send({
        businessName: 'Test Shop',
        ownerName: 'Test Owner',
        ownerEmail: 'owner@example.com',
        password: 'secure-password-42',
        businessId: '11111111-1111-4111-8111-111111111111',
      })
      .expect(400);
  });

  it('rejects client-supplied role', () => {
    return request(app.getHttpServer())
      .post('/businesses/register')
      .send({
        businessName: 'Test Shop',
        ownerName: 'Test Owner',
        ownerEmail: 'owner@example.com',
        password: 'secure-password-42',
        role: 'ADMIN',
      })
      .expect(400);
  });

  it('rejects invalid password', () => {
    return request(app.getHttpServer())
      .post('/businesses/register')
      .send({
        businessName: 'Test Shop',
        ownerName: 'Test Owner',
        ownerEmail: 'owner@example.com',
        password: 'short',
      })
      .expect(400);
  });

  it('rejects invalid email', () => {
    return request(app.getHttpServer())
      .post('/businesses/register')
      .send({
        businessName: 'Test Shop',
        ownerName: 'Test Owner',
        ownerEmail: 'not-an-email',
        password: 'secure-password-42',
      })
      .expect(400);
  });

  it('/health remains available', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect((res) => {
        const body = res.body as { status: string };
        expect(body.status).toBe('ok');
      });
  });
});
