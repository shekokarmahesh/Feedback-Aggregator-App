import 'package:serverpod/serverpod.dart';
import 'grouping_service.dart';

class GroupingFutureCall extends FutureCall {
  Future<void> process(Session session, int workspaceId) =>
      GroupingService().processBatch(session, workspaceId);
}
