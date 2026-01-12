import 'package:apq_m1/Models/ModelsServiceQueueBinding.dart'
    show ModelsServiceQueueBinding;
import 'package:socket_io_client/socket_io_client.dart' as IO;
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

  void _connect() {
    _socket = IO.io(
      'https://apq.andamandev.com',
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

    const toSocket = 'queue:call';
    
    print(callerId);
    _socket?.emit(toSocket, {'data': callerId , 'action': 'call' , 'branch': queue.branchId,});

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
    });

    const toSocket = 'queue:call';

    _socket?.emit(toSocket, {'data': queue.callerId, 'action': 'call'});

  }

  Future<void> recallQueue(ModelsQueueBinding queue) async {
    await initializeWebSocket();

    const toSocket = 'queue:call';

    _socket?.emit(toSocket, {
      'queue': queue.queueNo,
      'serviceId': queue.serviceId,
      'action': 'recall',
    });

    print('RECALL QUEUE: ${queue.queueNo}');
  }

  Future<void> createQueue(ModelsServiceQueueBinding queue) async {
    await initializeWebSocket();

    const toSocket = 'queue:register';

    _socket?.emit(toSocket, {
      'queue': queue.queueNo,
      'serviceId': queue.serviceId,
      'action': 'create queue',
    });

    print('CREATECALL QUEUE: ${queue.queueNo}');
  }
}
