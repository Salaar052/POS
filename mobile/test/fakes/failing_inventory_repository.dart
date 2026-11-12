import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/inventory/domain/inventory_exceptions.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';

class FailingInventoryRepository extends InventoryRepository {
  FailingInventoryRepository(
    super.runner, {
    this.failOnMovementType,
    this.failAfterSuccessfulMovements = 0,
  });

  final StockMovementType? failOnMovementType;
  final int failAfterSuccessfulMovements;
  var _successfulMovements = 0;

  @override
  Future<StockMovementRow> applyMovementInTransaction(
    ApplyStockMovementRequest request,
  ) async {
    if (failOnMovementType != null && request.type == failOnMovementType) {
      if (_successfulMovements >= failAfterSuccessfulMovements) {
        throw InventoryConflictException(
          InventoryConflictCode.invalidQuantity,
          'Injected inventory failure for test',
        );
      }
    }
    _successfulMovements++;
    return super.applyMovementInTransaction(request);
  }
}
