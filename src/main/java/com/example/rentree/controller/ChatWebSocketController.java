package com.example.rentree.controller;

import com.example.rentree.dto.RentalChatMessageRequestDTO;
import com.example.rentree.dto.RequestChatMessageRequestDTO;
import com.example.rentree.service.RentalChatSocketService;
import com.example.rentree.service.RequestChatSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final RentalChatSocketService rentalChatSocketService;
    private final RequestChatSocketService requestChatSocketService;

    // 대여글 기반 채팅 전송
    @MessageMapping("/chat/rental/send")
    public void sendRentalMessage(RentalChatMessageRequestDTO dto) {
        rentalChatSocketService.handle(dto);
    }

    // 요청글 기반 채팅 전송
    @MessageMapping("/chat/request/send")
    public void sendRequestMessage(RequestChatMessageRequestDTO dto) {
        requestChatSocketService.handle(dto);
    }
}
