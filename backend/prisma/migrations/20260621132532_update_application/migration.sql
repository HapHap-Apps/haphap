-- CreateEnum
CREATE TYPE "BankType" AS ENUM ('BCA', 'BRI', 'MANDIRI', 'BNI', 'CIMB', 'DANAMON', 'PERMATA', 'BTN', 'MAYBANK', 'OCBC', 'PANIN', 'SINARMAS', 'BTPN', 'MEGA');

-- AlterTable
ALTER TABLE "applications" ADD COLUMN     "avatar" TEXT,
ADD COLUMN     "bankAccount" TEXT,
ADD COLUMN     "bankHolder" TEXT,
ADD COLUMN     "bankType" "BankType",
ADD COLUMN     "document" TEXT,
ADD COLUMN     "merchantOwner" TEXT,
ALTER COLUMN "merchantName" DROP NOT NULL;
