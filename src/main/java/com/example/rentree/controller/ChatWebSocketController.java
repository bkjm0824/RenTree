package com.example.rentree.controller;

import com.example.rentree.dto.ChatMessageRequestDTO;
import com.example.rentree.service.ChatSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatSocketService chatSocketService;

    @MessageMapping("/chat/send")
    public void sendMessage(ChatMessageRequestDTO requestDTO) {
        chatSocketService.handleChatMessage(requestDTO);
    }
}
