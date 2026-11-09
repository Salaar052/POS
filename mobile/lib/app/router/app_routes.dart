import 'package:flutter/material.dart';

/// Named routes and paths for GoRouter.
abstract final class AppRoutes {
  static const dashboard = '/';
  static const pos = '/pos';
  static const products = '/products';
  static const inventory = '/inventory';
  static const customers = '/customers';
  static const suppliers = '/suppliers';
  static const purchases = '/purchases';
  static const expenses = '/expenses';
  static const reports = '/reports';
  static const settings = '/settings';

  static const dashboardName = 'dashboard';
  static const posName = 'pos';
  static const productsName = 'products';
  static const inventoryName = 'inventory';
  static const customersName = 'customers';
  static const suppliersName = 'suppliers';
  static const purchasesName = 'purchases';
  static const expensesName = 'expenses';
  static const reportsName = 'reports';
  static const settingsName = 'settings';
}

class AppNavDestination {
  const AppNavDestination({
    required this.path,
    required this.name,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String name;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<AppNavDestination> appNavDestinations = [
  AppNavDestination(
    path: AppRoutes.dashboard,
    name: AppRoutes.dashboardName,
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  AppNavDestination(
    path: AppRoutes.pos,
    name: AppRoutes.posName,
    label: 'Point of Sale',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
  ),
  AppNavDestination(
    path: AppRoutes.products,
    name: AppRoutes.productsName,
    label: 'Products',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  AppNavDestination(
    path: AppRoutes.inventory,
    name: AppRoutes.inventoryName,
    label: 'Inventory',
    icon: Icons.warehouse_outlined,
    selectedIcon: Icons.warehouse,
  ),
  AppNavDestination(
    path: AppRoutes.customers,
    name: AppRoutes.customersName,
    label: 'Customers',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  AppNavDestination(
    path: AppRoutes.suppliers,
    name: AppRoutes.suppliersName,
    label: 'Suppliers',
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping,
  ),
  AppNavDestination(
    path: AppRoutes.purchases,
    name: AppRoutes.purchasesName,
    label: 'Purchases',
    icon: Icons.shopping_cart_outlined,
    selectedIcon: Icons.shopping_cart,
  ),
  AppNavDestination(
    path: AppRoutes.expenses,
    name: AppRoutes.expensesName,
    label: 'Expenses',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  AppNavDestination(
    path: AppRoutes.reports,
    name: AppRoutes.reportsName,
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
  ),
  AppNavDestination(
    path: AppRoutes.settings,
    name: AppRoutes.settingsName,
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];
