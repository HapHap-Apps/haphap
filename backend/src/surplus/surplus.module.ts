import { Module } from '@nestjs/common';
import { SurplusController } from './surplus.controller.js';
import { SurplusService } from './surplus.service.js';

@Module({
  controllers: [SurplusController],
  providers: [SurplusService],
  exports: [SurplusService],
})
export class SurplusModule {}
