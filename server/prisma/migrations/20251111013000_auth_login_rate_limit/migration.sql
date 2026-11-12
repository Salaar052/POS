-- Login rate-limit buckets for distributed POST /auth/login protection.

CREATE TABLE "LoginRateLimitBucket" (
    "clientKey" TEXT NOT NULL,
    "windowStartedAt" TIMESTAMP(3) NOT NULL,
    "attemptCount" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LoginRateLimitBucket_pkey" PRIMARY KEY ("clientKey")
);
