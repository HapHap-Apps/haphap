/*
  Warnings:

  - Made the column `avatar` on table `merchants` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "merchants" ALTER COLUMN "avatar" SET NOT NULL;
