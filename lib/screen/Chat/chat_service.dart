// 웹소켓 연결 로직

import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatService {
  static late StompClient stompClient;
  static bool Function()? _isMounted;
  static Function(String)? _onMessageReceived;
  static bool _isSubscribed = false;

  static void Function()? _unsubscribe;

  static void connect({
    required int chatRoomId,
    required String myStudentNum, // 👈 추가
    required Function(String) onMessageReceived,
    required bool Function() isMounted,
  }) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://10.0.2.2:8080/ws-chat',
        onConnect: (frame) {
          print('✅ WebSocket 연결 성공');

          final destination = '/user/$myStudentNum/queue/messages'; // 👈 변경된 경로
          print('📡 구독 시작: $destination');
          _unsubscribe = stompClient.subscribe(
            destination: destination,
            callback: (frame) {
              print('📩 메시지 수신함');
              if (frame.body != null && isMounted()) {
                onMessageReceived(frame.body!);
              }
            },
          );
        },
        onWebSocketError: (error) => print('❌ WebSocket 에러: $error'),
      ),
    );

    stompClient.activate();
  }


  static void disconnect() {
    print("🧹 ChatService.disconnect() 호출됨");
    try {
      _unsubscribe?.call(); // ✅ 구독 해제
    } catch (e) {
      print("❌ unsubscribe 중 오류: $e");
    }
    stompClient.deactivate();
  }


  static void sendMessage(
      int chatRoomId,
      String senderStudentNum,
      String receiverStudentNum, // 🔥 추가
      String message,
      ) {
    final msg = {
      'chatRoomId': chatRoomId,
      'senderStudentNum': senderStudentNum,
      'receiverStudentNum': receiverStudentNum, // 🔥 반드시 포함
      'message': message,
    };

    print('🚀 보낼 메시지: $msg');

    stompClient.send(
      destination: '/app/chat/send',
      body: jsonEncode(msg),
    );
  }
}
