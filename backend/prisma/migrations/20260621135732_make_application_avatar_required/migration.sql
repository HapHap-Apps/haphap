/*
  Warnings:

  - Made the column `avatar` on table `applications` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "applications" ALTER COLUMN "avatar" SET NOT NULL;
