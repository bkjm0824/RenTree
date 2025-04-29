package com.example.rentree.controller;

import com.example.rentree.dto.ChatMessageRequestDTO;
import com.example.rentree.dto.ChatMessageResponseDTO;
import com.example.rentree.service.ChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatMessageService chatMessageService;

    @MessageMapping("/chat/send")         // 클라이언트는 "/app/chat/send"로 메시지를 보냄
    @SendTo("/topic/chatroom")            // 구독 중인 클라이언트가 "/topic/chatroom"으로 메시지 수신
    public ChatMessageResponseDTO sendMessage(ChatMessageRequestDTO requestDTO) {
        return chatMessageService.sendMessage(requestDTO);
    }
}
