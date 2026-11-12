import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';

class ProductCatalogState {
  const ProductCatalogState({
    this.products = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.categoryId,
    this.archiveFilter = ProductArchiveFilter.activeOnly,
  });

  final List<ProductRow> products;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final String? categoryId;
  final ProductArchiveFilter archiveFilter;

  bool get canLoadMore => products.length < totalCount;

  ProductCatalogState copyWith({
    List<ProductRow>? products,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? categoryId,
    bool clearCategory = false,
    ProductArchiveFilter? archiveFilter,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      archiveFilter: archiveFilter ?? this.archiveFilter,
    );
  }
}

final productCatalogControllerProvider =
    NotifierProvider<ProductCatalogController, ProductCatalogState>(
      ProductCatalogController.new,
    );

class ProductCatalogController extends Notifier<ProductCatalogState> {
  static const _pageSize = 40;

  @override
  ProductCatalogState build() {
    Future.microtask(refresh);
    return const ProductCatalogState(isLoading: true);
  }

  ProductRepository get _repo => ref.read(productRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final query = _currentQuery(offset: 0);
      final products = await _repo.listProducts(query);
      final total = await _repo.countProducts(query);
      state = state.copyWith(
        products: products,
        totalCount: total,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.canLoadMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final query = _currentQuery(offset: state.products.length);
      final next = await _repo.listProducts(query);
      state = state.copyWith(
        products: [...state.products, ...next],
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
    refresh();
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
    );
    refresh();
  }

  void setArchiveFilter(ProductArchiveFilter filter) {
    state = state.copyWith(archiveFilter: filter);
    refresh();
  }

  ProductListQuery _currentQuery({required int offset}) {
    return ProductListQuery(
      nameQuery: state.searchQuery,
      categoryId: state.categoryId,
      archiveFilter: state.archiveFilter,
      limit: _pageSize,
      offset: offset,
    );
  }
}
