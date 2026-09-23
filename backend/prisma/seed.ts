import 'dotenv/config';
import { PrismaClient } from '../src/generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcrypt';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Clearing existing data...');

  await prisma.review.deleteMany({});
  await prisma.payment.deleteMany({});
  await prisma.orderItem.deleteMany({});
  await prisma.order.deleteMany({});
  await prisma.surplusItem.deleteMany({});
  await prisma.menuItem.deleteMany({});
  await prisma.application.deleteMany({});
  await prisma.merchant.deleteMany({});
  await prisma.user.deleteMany({});

  console.log('Seeding database with initial data...');

  const hashedPassword = await bcrypt.hash('password123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@haphap.com',
      name: 'Budi Santoso',
      password: hashedPassword,
      phone: '081100000000',
      role: 'ADMIN',
    },
  });

  const userCustomerSiti = await prisma.user.create({
    data: {
      email: 'siti@haphap.com',
      name: 'Siti Aminah',
      password: hashedPassword,
      phone: '081211111111',
      role: 'CUSTOMER',
      totalSaved: 45000,
      totalPortion: 3,
    },
  });

  const userCustomerAgus = await prisma.user.create({
    data: {
      email: 'agus@haphap.com',
      name: 'Agus Pratama',
      password: hashedPassword,
      phone: '081222222222',
      role: 'CUSTOMER',
    },
  });

  const userMerchantAyu = await prisma.user.create({
    data: {
      email: 'ayu@haphap.com',
      name: 'Ayu Lestari',
      password: hashedPassword,
      phone: '081233333333',
      role: 'MERCHANT',
    },
  });

  const userMerchantBambang = await prisma.user.create({
    data: {
      email: 'bambang@haphap.com',
      name: 'Bambang Pamungkas',
      password: hashedPassword,
      phone: '081244444444',
      role: 'CUSTOMER',
    },
  });

  const userMerchantCitra = await prisma.user.create({
    data: {
      email: 'citra@haphap.com',
      name: 'Citra Kirana',
      password: hashedPassword,
      phone: '081255555555',
      role: 'CUSTOMER',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantBambang.id,
      merchantName: 'Warung Nasi Bambang',
      merchantOwner: 'Bambang Pamungkas',
      status: 'PENDING',
      address: 'Jl. Merdeka No. 10, Jakarta',
      latitude: -6.2,
      longitude: 106.816666,
      description: 'Menjual aneka lauk pauk sisa hari ini',
      openTime: '08:00',
      closeTime: '20:00',
      phone: '081244444444',
      categories: ['RESTORAN'],
      bankType: 'BCA',
      bankAccount: '1234567890',
      bankHolder: 'Bambang Pamungkas',
      document: 'https://example.com/doc_bambang.pdf',
      avatar: 'https://api.dicebear.com/9.x/adventurer/png?seed=bambang',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantCitra.id,
      merchantName: 'Toko Kue Citra',
      merchantOwner: 'Citra Kirana',
      status: 'REJECTED',
      address: 'Jl. Sudirman No. 5, Jakarta',
      latitude: -6.225014,
      longitude: 106.804359,
      description: 'Kue kering dan basah',
      openTime: '09:00',
      closeTime: '17:00',
      phone: '081255555555',
      categories: ['ROTI', 'PENUTUP'],
      bankType: 'MANDIRI',
      bankAccount: '0987654321',
      bankHolder: 'Citra Kirana',
      document: 'https://example.com/doc_citra.pdf',
      avatar: 'https://api.dicebear.com/9.x/adventurer/png?seed=citra',
      rejectNote: 'Foto KTP buram dan tidak terbaca jelas.',
      reviewedAt: new Date(),
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantAyu.id,
      merchantName: 'Kedai Kopi Bu Ayu',
      merchantOwner: 'Ayu Lestari',
      status: 'APPROVED',
      address: 'Jl. Diponegoro No. 15, Bandung',
      latitude: -6.903444,
      longitude: 107.618774,
      description: 'Kopi susu gula aren dan camilan lokal',
      openTime: '10:00',
      closeTime: '22:00',
      phone: '081233333333',
      categories: ['KAFE', 'JAJANAN'],
      bankType: 'BRI',
      bankAccount: '1122334455',
      bankHolder: 'Ayu Lestari',
      document: 'https://example.com/doc_ayu.pdf',
      avatar: 'https://iili.io/CRqVNwP.jpg',
      reviewedAt: new Date(),
    },
  });

  const merchantAyu = await prisma.merchant.create({
    data: {
      userId: userMerchantAyu.id,
      merchantName: 'Kedai Kopi Bu Ayu',
      address: 'Jl. Diponegoro No. 15, Bandung',
      latitude: -6.903444,
      longitude: 107.618774,
      description: 'Kopi susu gula aren dan camilan lokal',
      openTime: '10:00',
      closeTime: '22:00',
      phone: '081233333333',
      avatar: 'https://iili.io/CRqVNwP.jpg',
      categories: ['KAFE', 'JAJANAN'],
      rating: 4.5,
      totalRevenue: 65000,
      totalPortion: 3,
    },
  });

  const menuKopi = await prisma.menuItem.create({
    data: {
      merchantId: merchantAyu.id,
      name: 'Es Kopi Susu Gula Aren',
      description: 'Kopi susu andalan dengan gula aren asli',
      image: 'https://cdn.phototourl.com/free/2026-06-27-38e0ede2-6d68-4fd8-ae05-c5d4c6205776.jpg',
      originalPrice: 20000,
      isActive: true,
    },
  });

  const menuRoti = await prisma.menuItem.create({
    data: {
      merchantId: merchantAyu.id,
      name: 'Roti Bakar Coklat Keju',
      description: 'Roti bakar tebal lumer',
      image: 'https://cdn.phototourl.com/free/2026-06-27-1a532b78-ca11-4a34-af66-b9ad487c1839.jpg',
      originalPrice: 25000,
      isActive: true,
    },
  });

  const menuNonaktif = await prisma.menuItem.create({
    data: {
      merchantId: merchantAyu.id,
      name: 'Donat Kampung',
      description: 'Donat gula halus',
      originalPrice: 10000,
      isActive: false,
    },
  });

  const today = new Date();

  const surplusKopi = await prisma.surplusItem.create({
    data: {
      menuItemId: menuKopi.id,
      merchantId: merchantAyu.id,
      discountPrice: 10000,
      originalPrice: 20000,
      stock: 8,
      isActive: true,
      date: today,
    },
  });

  const surplusRoti = await prisma.surplusItem.create({
    data: {
      menuItemId: menuRoti.id,
      merchantId: merchantAyu.id,
      discountPrice: 12000,
      originalPrice: 25000,
      stock: 3,
      isActive: true,
      date: today,
    },
  });

  const surplusHabis = await prisma.surplusItem.create({
    data: {
      menuItemId: menuKopi.id,
      merchantId: merchantAyu.id,
      discountPrice: 10000,
      originalPrice: 20000,
      stock: 0,
      isActive: false,
      date: today,
    },
  });

  // ============ MERCHANT 2: Warung Padang Bu Rina ============
  const userMerchantRina = await prisma.user.create({
    data: {
      email: 'rina@haphap.com',
      name: 'Rina Marlina',
      password: hashedPassword,
      phone: '081266666666',
      role: 'MERCHANT',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantRina.id,
      merchantName: 'Warung Padang Bu Rina',
      merchantOwner: 'Rina Marlina',
      status: 'APPROVED',
      address: 'Jl. Sabang No. 22, Jakarta Pusat',
      latitude: -6.186486,
      longitude: 106.823745,
      description: 'Masakan Padang autentik dengan bumbu rempah pilihan',
      openTime: '08:00',
      closeTime: '21:00',
      phone: '081266666666',
      categories: ['RESTORAN'],
      bankType: 'BNI',
      bankAccount: '2233445566',
      bankHolder: 'Rina Marlina',
      document: 'https://example.com/doc_rina.pdf',
      avatar: 'https://iili.io/CRqVVFj.jpg',
      reviewedAt: new Date(),
    },
  });

  const merchantRina = await prisma.merchant.create({
    data: {
      userId: userMerchantRina.id,
      merchantName: 'Warung Padang Bu Rina',
      address: 'Jl. Sabang No. 22, Jakarta Pusat',
      latitude: -6.186486,
      longitude: 106.823745,
      description: 'Masakan Padang autentik dengan bumbu rempah pilihan',
      openTime: '08:00',
      closeTime: '21:00',
      phone: '081266666666',
      avatar: 'https://iili.io/CRqVVFj.jpg',
      categories: ['RESTORAN'],
      rating: 4.8,
      totalRevenue: 120000,
      totalPortion: 8,
    },
  });

  const menuRendang = await prisma.menuItem.create({
    data: {
      merchantId: merchantRina.id,
      name: 'Rendang Daging Sapi',
      description: 'Rendang empuk bumbu meresap khas Minang',
      image: 'https://cdn.phototourl.com/free/2026-06-27-2423b32c-1ee2-48a0-b566-1572a7df47f9.jpg',
      originalPrice: 30000,
      isActive: true,
    },
  });

  const menuAyamPop = await prisma.menuItem.create({
    data: {
      merchantId: merchantRina.id,
      name: 'Ayam Pop',
      description: 'Ayam rebus khas Padang dengan sambal lado hijau',
      image: 'https://cdn.phototourl.com/free/2026-06-27-b0cf0ce2-6b5e-4d22-9add-49c5bee6acd3.jpg',
      originalPrice: 25000,
      isActive: true,
    },
  });

  const menuGulaiNangka = await prisma.menuItem.create({
    data: {
      merchantId: merchantRina.id,
      name: 'Gulai Nangka',
      description: 'Gulai nangka muda kuah santan kental',
      image: 'https://cdn.phototourl.com/free/2026-06-27-7ce5e3e9-b230-4254-ba17-29c4ded117fb.jpg',
      originalPrice: 15000,
      isActive: true,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuRendang.id,
      merchantId: merchantRina.id,
      discountPrice: 18000,
      originalPrice: 30000,
      stock: 5,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuAyamPop.id,
      merchantId: merchantRina.id,
      discountPrice: 15000,
      originalPrice: 25000,
      stock: 3,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuGulaiNangka.id,
      merchantId: merchantRina.id,
      discountPrice: 8000,
      originalPrice: 15000,
      stock: 4,
      isActive: true,
      date: today,
    },
  });

  // ============ MERCHANT 3: Bakery Dewi ============
  const userMerchantDewi = await prisma.user.create({
    data: {
      email: 'dewi@haphap.com',
      name: 'Dewi Sartika',
      password: hashedPassword,
      phone: '081277777777',
      role: 'MERCHANT',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantDewi.id,
      merchantName: 'Bakery Dewi',
      merchantOwner: 'Dewi Sartika',
      status: 'APPROVED',
      address: 'Jl. Braga No. 45, Bandung',
      latitude: -6.917464,
      longitude: 107.609810,
      description: 'Aneka roti dan pastry freshly baked setiap hari',
      openTime: '07:00',
      closeTime: '20:00',
      phone: '081277777777',
      categories: ['ROTI', 'PENUTUP'],
      bankType: 'MANDIRI',
      bankAccount: '3344556677',
      bankHolder: 'Dewi Sartika',
      document: 'https://example.com/doc_dewi.pdf',
      avatar: 'https://iili.io/CRqVj9V.jpg',
      reviewedAt: new Date(),
    },
  });

  const merchantDewi = await prisma.merchant.create({
    data: {
      userId: userMerchantDewi.id,
      merchantName: 'Bakery Dewi',
      address: 'Jl. Braga No. 45, Bandung',
      latitude: -6.917464,
      longitude: 107.609810,
      description: 'Aneka roti dan pastry freshly baked setiap hari',
      openTime: '07:00',
      closeTime: '20:00',
      phone: '081277777777',
      avatar: 'https://iili.io/CRqVj9V.jpg',
      categories: ['ROTI', 'PENUTUP'],
      rating: 4.3,
      totalRevenue: 85000,
      totalPortion: 12,
    },
  });

  const menuCroissant = await prisma.menuItem.create({
    data: {
      merchantId: merchantDewi.id,
      name: 'Croissant Butter',
      description: 'Croissant berlapis mentega premium renyah',
      image: 'https://cdn.phototourl.com/free/2026-06-27-8db01c54-a5d7-43b6-a683-12f5373d951d.jpg',
      originalPrice: 18000,
      isActive: true,
    },
  });

  const menuRotiCoklat = await prisma.menuItem.create({
    data: {
      merchantId: merchantDewi.id,
      name: 'Roti Coklat Lumer',
      description: 'Roti lembut isi coklat Belgian yang meleleh',
      image: 'https://iili.io/CRqW9Hl.jpg',
      originalPrice: 15000,
      isActive: true,
    },
  });

  const menuPizzaBread = await prisma.menuItem.create({
    data: {
      merchantId: merchantDewi.id,
      name: 'Pizza Bread Keju',
      description: 'Roti pizza topping keju mozzarella dan saus tomat',
      image: 'https://iili.io/CRqVtPs.jpg',
      originalPrice: 20000,
      isActive: true,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuCroissant.id,
      merchantId: merchantDewi.id,
      discountPrice: 10000,
      originalPrice: 18000,
      stock: 6,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuRotiCoklat.id,
      merchantId: merchantDewi.id,
      discountPrice: 8000,
      originalPrice: 15000,
      stock: 4,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuPizzaBread.id,
      merchantId: merchantDewi.id,
      discountPrice: 12000,
      originalPrice: 20000,
      stock: 2,
      isActive: true,
      date: today,
    },
  });

  // ============ MERCHANT 4: Sate Kambing Haji Dede ============
  const userMerchantDede = await prisma.user.create({
    data: {
      email: 'dede@haphap.com',
      name: 'Dede Kurniawan',
      password: hashedPassword,
      phone: '081288888888',
      role: 'MERCHANT',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantDede.id,
      merchantName: 'Sate Kambing Haji Dede',
      merchantOwner: 'Dede Kurniawan',
      status: 'APPROVED',
      address: 'Jl. Kebon Sirih No. 8, Jakarta Pusat',
      latitude: -6.188028,
      longitude: 106.834915,
      description: 'Sate kambing muda empuk sejak 1985',
      openTime: '16:00',
      closeTime: '23:00',
      phone: '081288888888',
      categories: ['RESTORAN', 'JAJANAN'],
      bankType: 'BCA',
      bankAccount: '4455667788',
      bankHolder: 'Dede Kurniawan',
      document: 'https://example.com/doc_dede.pdf',
      avatar: 'https://iili.io/CRqVWcx.jpg',
      reviewedAt: new Date(),
    },
  });

  const merchantDede = await prisma.merchant.create({
    data: {
      userId: userMerchantDede.id,
      merchantName: 'Sate Kambing Haji Dede',
      address: 'Jl. Kebon Sirih No. 8, Jakarta Pusat',
      latitude: -6.188028,
      longitude: 106.834915,
      description: 'Sate kambing muda empuk sejak 1985',
      openTime: '16:00',
      closeTime: '23:00',
      phone: '081288888888',
      avatar: 'https://iili.io/CRqVWcx.jpg',
      categories: ['RESTORAN', 'JAJANAN'],
      rating: 4.7,
      totalRevenue: 200000,
      totalPortion: 15,
    },
  });

  const menuSateKambing = await prisma.menuItem.create({
    data: {
      merchantId: merchantDede.id,
      name: 'Sate Kambing 10 Tusuk',
      description: 'Sate kambing muda bumbu kacang dan kecap',
      image: 'https://iili.io/CRqVQoX.jpg',
      originalPrice: 35000,
      isActive: true,
    },
  });

  const menuGulaiKambing = await prisma.menuItem.create({
    data: {
      merchantId: merchantDede.id,
      name: 'Gulai Kambing',
      description: 'Gulai kambing kuah kental rempah nusantara',
      image: 'https://iili.io/CRqVstt.jpg',
      originalPrice: 30000,
      isActive: true,
    },
  });

  const menuTongseng = await prisma.menuItem.create({
    data: {
      merchantId: merchantDede.id,
      name: 'Tongseng Kambing',
      description: 'Tongseng kambing pedas manis dengan kol dan tomat',
      image: 'https://iili.io/CRqViNI.jpg',
      originalPrice: 28000,
      isActive: true,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuSateKambing.id,
      merchantId: merchantDede.id,
      discountPrice: 20000,
      originalPrice: 35000,
      stock: 4,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuGulaiKambing.id,
      merchantId: merchantDede.id,
      discountPrice: 18000,
      originalPrice: 30000,
      stock: 3,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuTongseng.id,
      merchantId: merchantDede.id,
      discountPrice: 16000,
      originalPrice: 28000,
      stock: 5,
      isActive: true,
      date: today,
    },
  });

  // ============ MERCHANT 5: Kedai Sehat Fitri ============
  const userMerchantFitri = await prisma.user.create({
    data: {
      email: 'fitri@haphap.com',
      name: 'Fitri Handayani',
      password: hashedPassword,
      phone: '081299999999',
      role: 'MERCHANT',
    },
  });

  await prisma.application.create({
    data: {
      userId: userMerchantFitri.id,
      merchantName: 'Kedai Sehat Fitri',
      merchantOwner: 'Fitri Handayani',
      status: 'APPROVED',
      address: 'Jl. Dago No. 30, Bandung',
      latitude: -6.885214,
      longitude: 107.613144,
      description: 'Makanan sehat, salad, dan smoothie bowl segar',
      openTime: '09:00',
      closeTime: '19:00',
      phone: '081299999999',
      categories: ['KAFE', 'KEBUTUHAN'],
      bankType: 'BRI',
      bankAccount: '5566778899',
      bankHolder: 'Fitri Handayani',
      document: 'https://example.com/doc_fitri.pdf',
      avatar: 'https://iili.io/CRqVX8Q.jpg',
      reviewedAt: new Date(),
    },
  });

  const merchantFitri = await prisma.merchant.create({
    data: {
      userId: userMerchantFitri.id,
      merchantName: 'Kedai Sehat Fitri',
      address: 'Jl. Dago No. 30, Bandung',
      latitude: -6.885214,
      longitude: 107.613144,
      description: 'Makanan sehat, salad, dan smoothie bowl segar',
      openTime: '09:00',
      closeTime: '19:00',
      phone: '081299999999',
      avatar: 'https://iili.io/CRqVX8Q.jpg',
      categories: ['KAFE', 'KEBUTUHAN'],
      rating: 4.6,
      totalRevenue: 95000,
      totalPortion: 10,
    },
  });

  const menuSaladBowl = await prisma.menuItem.create({
    data: {
      merchantId: merchantFitri.id,
      name: 'Chicken Salad Bowl',
      description: 'Salad segar dengan ayam panggang dan dressing wijen',
      image: 'https://iili.io/CRqVvMg.jpg',
      originalPrice: 35000,
      isActive: true,
    },
  });

  const menuSmoothie = await prisma.menuItem.create({
    data: {
      merchantId: merchantFitri.id,
      name: 'Smoothie Bowl Acai Berry',
      description: 'Smoothie bowl acai berry topping granola dan buah segar',
      image: 'https://iili.io/CRqVkoF.jpg',
      originalPrice: 30000,
      isActive: true,
    },
  });

  const menuWrap = await prisma.menuItem.create({
    data: {
      merchantId: merchantFitri.id,
      name: 'Veggie Wrap',
      description: 'Tortilla wrap isi sayuran panggang dan hummus',
      image: 'https://iili.io/CRqVOt1.jpg',
      originalPrice: 25000,
      isActive: true,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuSaladBowl.id,
      merchantId: merchantFitri.id,
      discountPrice: 20000,
      originalPrice: 35000,
      stock: 3,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuSmoothie.id,
      merchantId: merchantFitri.id,
      discountPrice: 18000,
      originalPrice: 30000,
      stock: 5,
      isActive: true,
      date: today,
    },
  });

  await prisma.surplusItem.create({
    data: {
      menuItemId: menuWrap.id,
      merchantId: merchantFitri.id,
      discountPrice: 15000,
      originalPrice: 25000,
      stock: 4,
      isActive: true,
      date: today,
    },
  });

  const now = new Date();
  const future15 = new Date(now.getTime() + 15 * 60000);
  const past60 = new Date(now.getTime() - 60 * 60000);
  const past30 = new Date(now.getTime() - 30 * 60000);

  const orderPending = await prisma.order.create({
    data: {
      userId: userCustomerSiti.id,
      merchantId: merchantAyu.id,
      status: 'PENDING',
      totalAmount: 10000,
      totalOriginal: 20000,
      qrCode: `QR-PENDING-${Date.now()}`,
      expiredAt: future15,
      orderItems: {
        create: [
          {
            surplusItemId: surplusKopi.id,
            name: menuKopi.name,
            quantity: 1,
            discountPrice: 10000,
            originalPrice: 20000,
          },
        ],
      },
    },
  });

  await prisma.payment.create({
    data: {
      orderId: orderPending.id,
      transactionId: `TX-PENDING-${Date.now()}`,
      status: 'PENDING',
      amount: 10000,
      snapToken: 'snap-token-mock-123',
    },
  });

  const orderProcessing = await prisma.order.create({
    data: {
      userId: userCustomerAgus.id,
      merchantId: merchantAyu.id,
      status: 'PROCESSING',
      totalAmount: 22000,
      totalOriginal: 45000,
      qrCode: `QR-PROCESSING-${Date.now()}`,
      notes: 'Es dipisah',
      expiredAt: future15,
      paidAt: past30,
      orderItems: {
        create: [
          {
            surplusItemId: surplusKopi.id,
            name: menuKopi.name,
            quantity: 1,
            discountPrice: 10000,
            originalPrice: 20000,
          },
          {
            surplusItemId: surplusRoti.id,
            name: menuRoti.name,
            quantity: 1,
            discountPrice: 12000,
            originalPrice: 25000,
          },
        ],
      },
    },
  });

  await prisma.payment.create({
    data: {
      orderId: orderProcessing.id,
      transactionId: `TX-PROC-${Date.now()}`,
      status: 'SUCCESS',
      amount: 22000,
    },
  });

  const orderCompleted = await prisma.order.create({
    data: {
      userId: userCustomerSiti.id,
      merchantId: merchantAyu.id,
      status: 'COMPLETED',
      totalAmount: 32000,
      totalOriginal: 65000,
      qrCode: `QR-COMPLETED-${Date.now()}`,
      expiredAt: past60,
      paidAt: past60,
      completedAt: past30,
      orderItems: {
        create: [
          {
            surplusItemId: surplusKopi.id,
            name: menuKopi.name,
            quantity: 2,
            discountPrice: 10000,
            originalPrice: 20000,
          },
          {
            surplusItemId: surplusRoti.id,
            name: menuRoti.name,
            quantity: 1,
            discountPrice: 12000,
            originalPrice: 25000,
          },
        ],
      },
    },
  });

  await prisma.payment.create({
    data: {
      orderId: orderCompleted.id,
      transactionId: `TX-COMP-${Date.now()}`,
      status: 'SUCCESS',
      amount: 32000,
    },
  });

  await prisma.review.create({
    data: {
      userId: userCustomerSiti.id,
      merchantId: merchantAyu.id,
      orderId: orderCompleted.id,
      rating: 5,
      comment: 'Kopinya masih sangat layak minum dan rotinya enak!',
    },
  });

  const orderCancelledExpired = await prisma.order.create({
    data: {
      userId: userCustomerAgus.id,
      merchantId: merchantAyu.id,
      status: 'CANCELLED',
      totalAmount: 12000,
      totalOriginal: 25000,
      qrCode: `QR-CANC-EXP-${Date.now()}`,
      expiredAt: past60,
      orderItems: {
        create: [
          {
            surplusItemId: surplusRoti.id,
            name: menuRoti.name,
            quantity: 1,
            discountPrice: 12000,
            originalPrice: 25000,
          },
        ],
      },
    },
  });

  await prisma.payment.create({
    data: {
      orderId: orderCancelledExpired.id,
      transactionId: `TX-EXP-${Date.now()}`,
      status: 'EXPIRED',
      amount: 12000,
    },
  });

  const orderCancelledFailed = await prisma.order.create({
    data: {
      userId: userCustomerSiti.id,
      merchantId: merchantAyu.id,
      status: 'CANCELLED',
      totalAmount: 20000,
      totalOriginal: 40000,
      qrCode: `QR-CANC-FAIL-${Date.now()}`,
      expiredAt: future15,
      orderItems: {
        create: [
          {
            surplusItemId: surplusKopi.id,
            name: menuKopi.name,
            quantity: 2,
            discountPrice: 10000,
            originalPrice: 20000,
          },
        ],
      },
    },
  });

  await prisma.payment.create({
    data: {
      orderId: orderCancelledFailed.id,
      transactionId: `TX-FAIL-${Date.now()}`,
      status: 'FAILED',
      amount: 20000,
    },
  });

  console.log('Database seeding completed successfully.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
