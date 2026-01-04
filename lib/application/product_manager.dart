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
    File? imageFile,
  }) async {
    if (name.isEmpty || brand.isEmpty) {
      return ProductResponse(
        success: false,
        message: 'Nama dan brand wajib diisi',
        products: [],
      );
    }

    return await _repo.createProduct(
      name: name,
      categoryId: categoryId,
      brand: brand,
      imageFile: imageFile,
    );
  }

  Future<ProductResponse> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required String brand,
    File? imageFile,
  }) {
    if (id <= 0) {
      return Future.value(
        ProductResponse(
          success: false,
          message: 'ID produk tidak valid',
          products: [],
        ),
      );
    }

    if (name.isEmpty || brand.isEmpty) {
      return Future.value(
        ProductResponse(
          success: false,
          message: 'Nama dan brand wajib diisi',
          products: [],
        ),
      );
    }

    return _repo.updateProduct(
      id: id,
      name: name,
      categoryId: categoryId,
      brand: brand,
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
