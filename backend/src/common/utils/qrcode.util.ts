export class QrCodeUtil {
  static generateToken(orderId: string) {
    return orderId;
  }

  static validateToken(token: string, orderId: string) {
    if (!token || !orderId) {
      return false;
    }

    return token === orderId;
  }
}
