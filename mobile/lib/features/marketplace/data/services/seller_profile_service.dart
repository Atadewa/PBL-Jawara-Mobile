import '../models/seller_profile.dart';

/*
SELLER PROFILE SERVICE (dummy API simulation)
1) This service still returns hard-coded data with a small delay to mimic network calls.
2) To plug a real HTTP client (Dio/http), inject it via constructor and call your endpoint:
   - GET /sellers/{sellerId}
3) Replace the dummy map with the parsed JSON -> SellerProfile.
4) Handle errors (no internet, timeout, server error) and surface useful messages.
5) Keep async signatures so the UI flow remains unchanged.
*/
class SellerProfileService {
  Future<SellerProfile> getSellerProfile(
    String sellerId, {
    String? fallbackName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    const profiles = {
      'user-1': SellerProfile(
        id: 'user-1',
        name: 'Sri Wijaya',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722asfd653e1?w=300',
        address: 'Jl. Melati No. 12, Banjarsari, Solo',
        family: 'Keluarga Wijaya',
      ),
      'user-2': SellerProfile(
        id: 'user-2',
        name: 'Rizky Pratama',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c172265afsd3e1?w=301',
        address: 'Jl. Ahmad Yani No. 45, Pekalongan',
        family: 'Keluarga Pratama',
      ),
      'user-3': SellerProfile(
        id: 'user-3',
        name: 'Dewi Anggraini',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c17226afd53e1?w=302',
        address: 'Jl. Diponegoro No. 8, Cirebon',
        family: 'Keluarga Anggraini',
      ),
    };

    return profiles[sellerId] ??
        SellerProfile(
          id: sellerId,
          name: fallbackName ?? 'Penjual',
          avatarUrl: null,
          address: 'Alamat belum diisi',
          family: 'Data keluarga belum diisi',
        );
  }
}
