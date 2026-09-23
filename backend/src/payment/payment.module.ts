import { Module } from '@nestjs/common';
import { PaymentController } from './payment.controller.js';
import { PaymentService } from './payment.service.js';
import { PrismaModule } from '../prisma/prisma.module.js';
import { MidtransService } from './midtrans.service.js';

@Module({
  imports: [PrismaModule],
  controllers: [PaymentController],
  providers: [PaymentService, MidtransService],
  exports: [PaymentService],
})
export class PaymentModule {}
