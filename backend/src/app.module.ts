import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { MerchantModule } from './merchant/merchant.module.js';
import { UserModule } from './user/user.module.js';
import { ReviewModule } from './review/review.module.js';
import { ApplicationModule } from './application/application.module.js';
import { PaymentModule } from './payment/payment.module.js';
import { OrderModule } from './order/order.module.js';
import { SurplusModule } from './surplus/surplus.module.js';
import { MenuModule } from './menu/menu.module.js';
import { StorageModule } from './storage/storage.module.js';
import { AppController } from './app.controller.js';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    AuthModule,
    MerchantModule,
    UserModule,
    ReviewModule,
    ApplicationModule,
    PaymentModule,
    OrderModule,
    SurplusModule,
    MenuModule,
    StorageModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
