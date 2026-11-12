import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';

class ProductCategoriesPage extends ConsumerStatefulWidget {
  const ProductCategoriesPage({super.key});

  @override
  ConsumerState<ProductCategoriesPage> createState() =>
      _ProductCategoriesPageState();
}

class _ProductCategoriesPageState extends ConsumerState<ProductCategoriesPage> {
  List<CategoryListEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categoryRepo = ref.read(productCategoryRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final categories = await categoryRepo.listCategories();
      final entries = <CategoryListEntry>[];
      for (final category in categories) {
        final count = await productRepo.countProducts(
          ProductListQuery(
            categoryId: category.id,
            archiveFilter: ProductArchiveFilter.all,
          ),
        );
        entries.add(CategoryListEntry(category: category, productCount: count));
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final name = await _promptForName(context, title: 'New category');
    if (name == null) {
      return;
    }
    try {
      await ref
          .read(productCategoryRepositoryProvider)
          .createCategory(name: name);
      await _reload();
    } on CatalogConflictException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _renameCategory(ProductCategoryRow category) async {
    final name = await _promptForName(
      context,
      title: 'Rename category',
      initial: category.name,
    );
    if (name == null) {
      return;
    }
    try {
      await ref
          .read(productCategoryRepositoryProvider)
          .updateCategory(id: category.id, name: name);
      await _reload();
    } on CatalogConflictException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _archiveCategory(CategoryListEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive category?'),
        content: Text(
          entry.productCount > 0
              ? '${entry.productCount} product(s) are linked to "${entry.category.name}". '
                    'Archiving will not delete products; they remain readable and can be reassigned.'
              : 'Archive "${entry.category.name}"?',
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
    await ref
        .read(productCategoryRepositoryProvider)
        .archiveCategory(entry.category.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return CatalogAccessGate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _entries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return ListTile(
                        title: Text(entry.category.name),
                        subtitle: Text('${entry.productCount} product(s)'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'rename') {
                              await _renameCategory(entry.category);
                            } else if (value == 'archive') {
                              await _archiveCategory(entry);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text('Archive'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryListEntry {
  const CategoryListEntry({required this.category, required this.productCount});

  final ProductCategoryRow category;
  final int productCount;
}

Future<String?> _promptForName(
  BuildContext context, {
  required String title,
  String? initial,
}) async {
  final controller = TextEditingController(text: initial ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  final trimmed = result?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
