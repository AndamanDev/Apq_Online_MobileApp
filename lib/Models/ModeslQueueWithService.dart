import 'ModelsQueueBinding.dart';
import 'ModelsServiceQueueBinding.dart';

class QueueWithService {
  final ModelsQueueBinding queue;
  final ModelsServiceQueueBinding service;

  QueueWithService({
    required this.queue,
    required this.service,
  });
}
