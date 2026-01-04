import '../data/repositories/category_repository.dart';
import '../data/models/category_response.dart';

class CategoryManager {
  final CategoryRepository _repo = CategoryRepository();

  Future<CategoryResponse> getCategories() async {
    return await _repo.getCategories();
  }

  Future<CategoryResponse> createCategory({
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      return CategoryResponse(
        success: false,
        message: 'Nama kategori wajib diisi',
        categories: [],
      );
    }

    return await _repo.createCategory(name: name);
  }

  Future<CategoryResponse> updateCategory({
    required String id,
    required String name,
  }) async {
    final parsedId = int.tryParse(id) ?? 0;

    if (parsedId <= 0) {
      return CategoryResponse(
        success: false,
        message: 'ID kategori tidak valid',
        categories: [],
      );
    }

    if (name.trim().isEmpty) {
      return CategoryResponse(
        success: false,
        message: 'Nama kategori wajib diisi',
        categories: [],
      );
    }

    return await _repo.updateCategory(
      id: parsedId,
      name: name,
    );
  }

  Future<CategoryResponse> deleteCategory({
    required String id,
  }) async {
    final parsedId = int.tryParse(id) ?? 0;

    if (parsedId <= 0) {
      return CategoryResponse(
        success: false,
        message: 'ID kategori tidak valid',
        categories: [],
      );
    }

    return await _repo.deleteCategory(id: parsedId);
  }

}
