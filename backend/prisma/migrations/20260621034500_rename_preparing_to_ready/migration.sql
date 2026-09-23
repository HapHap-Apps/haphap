-- RenameEnumValue: PREPARING → READY
-- Update all rows using the old value first, then rename the enum value
UPDATE "orders" SET "status" = 'PROCESSING' WHERE "status" = 'PREPARING';
ALTER TYPE "OrderStatus" RENAME VALUE 'PREPARING' TO 'READY';
