import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { extname } from 'path';
import { v4 } from 'uuid';

@Injectable()
export class StorageService {
  private supabaseClient: SupabaseClient;

  constructor(private readonly configService: ConfigService) {
    this.supabaseClient = createClient(
      configService.get<string>('SUPABASE_URL')!,
      configService.get<string>('SUPABASE_KEY')!,
    );
  }

  async uploadFile(file: Express.Multer.File, bucketName: string, folderName?: string): Promise<string> {
    const fileExtension = extname(file.originalname);
    const fileName = `${v4()}${fileExtension}`;
    const filePath = folderName ? `${folderName}/${fileName}` : fileName;

    const { data, error } = await this.supabaseClient.storage.from(bucketName).upload(filePath, file.buffer, {
      contentType: file.mimetype,
      upsert: false,
    });

    if (error) {
      throw new InternalServerErrorException(`Supabase Error: ${error.message}`);
    }

    const { data: publicUrlData } = this.supabaseClient.storage.from(bucketName).getPublicUrl(filePath);

    return publicUrlData.publicUrl;
  }
}
