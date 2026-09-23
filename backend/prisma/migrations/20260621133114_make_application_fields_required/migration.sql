/*
  Warnings:

  - Made the column `merchantName` on table `applications` required. This step will fail if there are existing NULL values in that column.
  - Made the column `bankAccount` on table `applications` required. This step will fail if there are existing NULL values in that column.
  - Made the column `bankHolder` on table `applications` required. This step will fail if there are existing NULL values in that column.
  - Made the column `bankType` on table `applications` required. This step will fail if there are existing NULL values in that column.
  - Made the column `document` on table `applications` required. This step will fail if there are existing NULL values in that column.
  - Made the column `merchantOwner` on table `applications` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "applications" ALTER COLUMN "merchantName" SET NOT NULL,
ALTER COLUMN "bankAccount" SET NOT NULL,
ALTER COLUMN "bankHolder" SET NOT NULL,
ALTER COLUMN "bankType" SET NOT NULL,
ALTER COLUMN "document" SET NOT NULL,
ALTER COLUMN "merchantOwner" SET NOT NULL;
