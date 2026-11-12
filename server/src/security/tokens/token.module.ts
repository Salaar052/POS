import { Module } from '@nestjs/common';
import { TokenHashService } from './token-hash.service';

@Module({
  providers: [TokenHashService],
  exports: [TokenHashService],
})
export class TokenModule {}
