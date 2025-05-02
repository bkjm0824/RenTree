// 웹소켓 연결 로직

import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatService {
  static late StompClient stompClient;

  static void connect({required Function(String) onMessageReceived}) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://10.0.2.2:8080/ws-chat',
        onConnect: (frame) {
          print('✅ WebSocket 연결 성공');
          stompClient.subscribe(
            destination: '/topic/chatroom',
            callback: (frame) {
              if (frame.body != null) {
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

  static void sendMessage(int chatRoomId, String senderStudentNum, String message) {
    final msg = {
      'chatRoomId': chatRoomId,
      'senderStudentNum': senderStudentNum,
      'message': message,
    };
    stompClient.send(
      destination: '/app/chat/send',
      body: jsonEncode(msg),
    );
  }

}