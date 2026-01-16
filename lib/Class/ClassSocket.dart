import 'package:apq_m1/Models/ModelsServiceQueueBinding.dart'
    show ModelsServiceQueueBinding;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Api/ApiConfig.dart';
import '../Models/ModelsQueueBinding.dart';

class ClassSocket {
  ClassSocket._internal();
  static final ClassSocket _instance = ClassSocket._internal();
  factory ClassSocket() => _instance;

  IO.Socket? _socket;

  Future<void> initializeWebSocket() async {
    if (_socket == null || !_socket!.connected) {
      _connect();
    }
  }

  final uri = Uri.parse(ApiConfig.baseUrl);

  void _connect() {
    _socket = IO.io(
      uri.toString(),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/nodeapq/socket.io')
          .enableForceNew()
          .build(),
    );

    _socket?.onConnect((_) {
      print('Socket connected');
    });

    _socket?.onConnectError((err) {
      print('Connect Error: $err');
    });

    _socket?.onError((err) {
      print('Socket Error: $err');
    });

    _socket?.connect();
  }

  void close() {
    _socket?.disconnect();
    _socket = null;
  }

  Future<void> callQueue(ModelsServiceQueueBinding queue, int callerId) async {
    await initializeWebSocket();

    const ToSocket = 'queue:call';

   _socket?.emit(ToSocket, <String, dynamic>{
      'data': callerId,
      'queue': 'call',
      'branch': queue.branchId,
    });
  }

  Future<void> updateQueue(
    ModelsServiceQueueBinding queue,
    String statusQueue,
    String statusQueueNote,
  ) async {
    await initializeWebSocket();

    var ToSocket = '';

    if (statusQueue == 'Calling') {
      ToSocket = 'queue:call';
      // ToMsg = "กำลังเรียกคิว\nCall Queue";
    } else if (statusQueue == 'Holding') {
      ToSocket = 'queue:hold';
      // ToMsg = "กำลังพักคิว\nHold Queue";
    } else if (statusQueue == 'Ending') {
      ToSocket = 'queue:finish';
      // ToMsg = "กำลังยกเลิกคิว\nCancel Queue";
    } else if (statusQueue == 'Finishing') {
      ToSocket = 'queue:finish';
      // ToMsg = "กำลังจบคิว\nEnd Queue";
    } else if (statusQueue == 'Recalling') {
      ToSocket = 'queue:call';
      // ToMsg = "กำลังเรียกคิวซ้ำ\nRecalling";
    }

    _socket?.emit(ToSocket, <String, dynamic>{
      'queue': ToSocket,
      'data': queue.callerId,
      'branch': queue.branchId,
    });

  }

  Future<void> createQueue(ModelsServiceQueueBinding queue) async {
    await initializeWebSocket();

    const toSocket = 'queue:register';

    _socket?.emit(toSocket, {
      'queue': queue.queueNo,
      'serviceId': queue.serviceId,
      'action': 'create queue',
    });
  }
}
