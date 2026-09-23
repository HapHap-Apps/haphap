import { Module } from '@nestjs/common';
import { MerchantController } from './merchant.controller.js';
import { MerchantService } from './merchant.service.js';
import { StorageModule } from '../storage/storage.module.js';

@Module({
  imports: [StorageModule],
  controllers: [MerchantController],
  providers: [MerchantService],
  exports: [MerchantService],
})
export class MerchantModule {}
