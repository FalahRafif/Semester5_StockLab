import 'dart:io';
import '../data/models/product_response.dart';
import '../data/repositories/product_repository.dart';

class ProductManager {
  final ProductRepository _repo = ProductRepository();

  Future<ProductResponse> getProducts() async {
    return await _repo.getProducts();
  }

  Future<ProductResponse> createProduct({
    required String name,
    required int categoryId,
    required String brand,
    required int price, // ✅ NEW
    File? imageFile,
  }) async {
    // Validasi nama dan brand
    if (name.isEmpty || brand.isEmpty) {
      return ProductResponse(
        success: false,
        message: 'Nama dan brand wajib diisi',
        products: [],
      );
    }

    // Validasi harga
    if (price < 0) {
      return ProductResponse(
        success: false,
        message: 'Harga tidak valid',
        products: [],
      );
    }

    // Validasi ukuran gambar (jika ada)
    if (imageFile != null) {
      final fileSize = await imageFile.length(); // dalam byte
      if (fileSize > 1 * 1024 * 1024) { // 1 MB
        return ProductResponse(
          success: false,
          message: 'Ukuran gambar maksimal 1 MB',
          products: [],
        );
      }
    }

    // Lanjut ke repository
    return await _repo.createProduct(
      name: name,
      categoryId: categoryId,
      brand: brand,
      price: price,
      imageFile: imageFile,
    );
  }

  Future<ProductResponse> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required String brand,
    required int price, // ✅ NEW
    File? imageFile,
  }) async {
    // Validasi ID
    if (id <= 0) {
      return ProductResponse(
        success: false,
        message: 'ID produk tidak valid',
        products: [],
      );
    }

    // Validasi nama dan brand
    if (name.isEmpty || brand.isEmpty) {
      return ProductResponse(
        success: false,
        message: 'Nama dan brand wajib diisi',
        products: [],
      );
    }

    // Validasi harga
    if (price < 0) {
      return ProductResponse(
        success: false,
        message: 'Harga tidak valid',
        products: [],
      );
    }

    // Validasi ukuran gambar (jika ada)
    if (imageFile != null) {
      final fileSize = await imageFile.length(); // dalam byte
      if (fileSize > 1 * 1024 * 1024) { // 1 MB
        return ProductResponse(
          success: false,
          message: 'Ukuran gambar maksimal 1 MB',
          products: [],
        );
      }
    }

    // Lanjut ke repository
    return await _repo.updateProduct(
      id: id,
      name: name,
      categoryId: categoryId,
      brand: brand,
      price: price,
      imageFile: imageFile,
    );
  }



  /// ✅ DELETE PRODUCT
  Future<ProductResponse> deleteProduct(int id) async {
    if (id <= 0) {
      return ProductResponse(
        success: false,
        message: 'ID produk tidak valid',
        products: [],
      );
    }

    return await _repo.deleteProduct(id);
  }
}
