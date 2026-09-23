import { Module } from '@nestjs/common';
import { ApplicationController } from './application.controller.js';
import { ApplicationService } from './application.service.js';
import { StorageModule } from '../storage/storage.module.js';

@Module({
  imports: [StorageModule],
  controllers: [ApplicationController],
  providers: [ApplicationService],
  exports: [ApplicationService],
})
export class ApplicationModule {}
