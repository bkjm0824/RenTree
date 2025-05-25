// 웹소켓 연결 로직

import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;

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
        url: 'http://54.79.35.255:8080/ws-chat',
        onConnect: (frame) {
          print('✅ WebSocket 연결 성공');

          final destination = '/user/$myStudentNum/queue/messages'; // 👈 변경된 경로
          print('📡 구독 시작: $destination');
          _unsubscribe = stompClient.subscribe(
            destination: destination,
            callback: (frame) {
              print('📩 메시지 수신함!');
              print('📨 수신된 메시지 내용: ${frame.body}');

              try {
                if (frame.body != null && isMounted()) {
                  onMessageReceived(frame.body!);
                }
              } catch (e) {
                print('❌ onMessageReceived 처리 중 오류 발생: $e');
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

  static void sendMessage(int chatRoomId, String senderStudentNum,
      String receiverStudentNum, String message,
      {required String type}) {
    final dto = {
      'chatRoomId': chatRoomId,
      'senderStudentNum': senderStudentNum,
      'receiverStudentNum': receiverStudentNum,
      'message': message,
    };

    final endpoint =
        type == 'rental' ? '/app/chat/rental/send' : '/app/chat/request/send';

    // ✅ WebSocket 전송만 수행 (HTTP 저장 제거)
    stompClient.send(
      destination: endpoint,
      body: jsonEncode(dto),
    );

    print('🚀 메시지 WebSocket으로 전송됨: $dto');
  }
}
