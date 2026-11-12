import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/products/application/product_catalog_controller.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/products/presentation/product_form_sheet.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatalogAccessGate(child: const _ProductsCatalogBody());
  }
}

class _ProductsCatalogBody extends ConsumerStatefulWidget {
  const _ProductsCatalogBody();

  @override
  ConsumerState<_ProductsCatalogBody> createState() =>
      _ProductsCatalogBodyState();
}

class _ProductsCatalogBodyState extends ConsumerState<_ProductsCatalogBody> {
  final _searchController = TextEditingController();
  List<ProductCategoryRow> _categories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref
          .read(productCategoryRepositoryProvider)
          .listCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        _categoriesLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _categoriesLoading = false);
      }
    }
  }

  Future<void> _openProductForm({ProductRow? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          ProductFormSheet(existing: existing, categoryOptions: _categories),
    );
    if (saved == true) {
      await ref.read(productCatalogControllerProvider.notifier).refresh();
      await _loadCategories();
    }
  }

  Future<void> _archiveProduct(ProductRow product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive product?'),
        content: Text(
          'Archive "${product.name}"? It will be hidden from active lists '
          'but kept for future transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(productRepositoryProvider).archiveProduct(product.id);
    await ref.read(productCatalogControllerProvider.notifier).refresh();
  }

  String _productSubtitle(ProductRow product, String? categoryName) {
    final parts = <String>[];
    final sku = product.sku;
    if (sku != null) {
      parts.add('SKU $sku');
    }
    if (categoryName != null) {
      parts.add(categoryName);
    }
    parts.add(
      'Sell ${MoneyAmount.formatPkrFromMinor(product.sellingPriceMinor)} PKR',
    );
    return parts.join(' · ');
  }

  String? _categoryName(String? id) {
    if (id == null) {
      return null;
    }
    for (final category in _categories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(productCatalogControllerProvider);
    final notifier = ref.read(productCatalogControllerProvider.notifier);

    return SizedBox.expand(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Product catalog',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.productCategories),
                    icon: const Icon(Icons.category_outlined),
                    label: const Text('Categories'),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton.icon(
                    onPressed: () => _openProductForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add product'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () =>
                        notifier.setSearchQuery(_searchController.text),
                  ),
                ),
                onSubmitted: notifier.setSearchQuery,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  FilterChip(
                    label: const Text('Active'),
                    selected:
                        catalog.archiveFilter ==
                        ProductArchiveFilter.activeOnly,
                    onSelected: (_) => notifier.setArchiveFilter(
                      ProductArchiveFilter.activeOnly,
                    ),
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected:
                        catalog.archiveFilter ==
                        ProductArchiveFilter.archivedOnly,
                    onSelected: (_) => notifier.setArchiveFilter(
                      ProductArchiveFilter.archivedOnly,
                    ),
                  ),
                  FilterChip(
                    label: const Text('All'),
                    selected: catalog.archiveFilter == ProductArchiveFilter.all,
                    onSelected: (_) =>
                        notifier.setArchiveFilter(ProductArchiveFilter.all),
                  ),
                  if (!_categoriesLoading)
                    DropdownMenu<String?>(
                      label: const Text('Category'),
                      initialSelection: catalog.categoryId,
                      dropdownMenuEntries: [
                        const DropdownMenuEntry<String?>(
                          value: null,
                          label: 'All categories',
                        ),
                        ..._categories.map(
                          (c) => DropdownMenuEntry<String?>(
                            value: c.id,
                            label: c.name,
                          ),
                        ),
                      ],
                      onSelected: notifier.setCategoryFilter,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${catalog.totalCount} product(s)',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildList(context, catalog, notifier)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ProductCatalogState catalog,
    ProductCatalogController notifier,
  ) {
    if (catalog.isLoading && catalog.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.errorMessage != null && catalog.products.isEmpty) {
      return Center(child: Text(catalog.errorMessage!));
    }
    if (catalog.products.isEmpty) {
      return const Center(
        child: Text('No products yet. Add your first product to get started.'),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 120) {
          notifier.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        itemCount: catalog.products.length + (catalog.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= catalog.products.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final product = catalog.products[index];
          final categoryName = _categoryName(product.categoryId);
          return ListTile(
            title: Text(product.name),
            subtitle: Text(_productSubtitle(product, categoryName)),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _openProductForm(existing: product);
                } else if (value == 'archive') {
                  await _archiveProduct(product);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'archive', child: Text('Archive')),
              ],
            ),
          );
        },
      ),
    );
  }
}
