import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { RegisterDto } from './dto/register.dto.js';
import { LoginDto } from './dto/login.dto.js';
import { GoogleLoginDto } from './dto/google-login.dto.js';
import { OAuth2Client } from 'google-auth-library';
import bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  private googleOAuthClient: OAuth2Client;

  constructor(
    private readonly prismaService: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    this.googleOAuthClient = new OAuth2Client(this.configService.get<string>('GOOGLE_CLIENT_ID'));
  }

  async register(dto: RegisterDto) {
    const existingUser = await this.prismaService.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new BadRequestException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const user = await this.prismaService.user.create({
      data: {
        name: dto.name,
        email: dto.email,
        password: hashedPassword,
        phone: dto.phone,
      },
    });

    return {
      userId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      createdAt: user.createdAt,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prismaService.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const jwtPayload = { sub: user.id, role: user.role };
    const accessToken = await this.jwtService.signAsync(jwtPayload);

    return {
      userId: user.id,
      name: user.name,
      role: user.role,
      accessToken,
    };
  }

  async googleLogin(dto: GoogleLoginDto) {
    const tikcet = await this.googleOAuthClient.verifyIdToken({
      idToken: dto.idToken,
      audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
    });

    const payload = tikcet.getPayload();

    if (!payload || !payload.email) {
      throw new UnauthorizedException('Invalid credentials');
    }

    let user = await this.prismaService.user.findUnique({
      where: { email: payload.email },
    });

    const { email, name, picture } = payload;

    if (!user) {
      const randomHashedPassword = await bcrypt.hash(payload.sub, 10);

      user = await this.prismaService.user.create({
        data: {
          name: name ?? 'PuyPuy',
          email,
          password: randomHashedPassword,
          phone: '',
          avatar: picture,
        },
      });
    }

    const jwtPayload = { sub: user.id, role: user.role };
    const accessToken = await this.jwtService.signAsync(jwtPayload);

    return {
      userId: user.id,
      name: user.name,
      role: user.role,
      accessToken,
    };
  }
}
