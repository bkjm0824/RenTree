package com.example.rentree.controller;

import com.example.rentree.dto.ChatMessageRequestDTO;
import com.example.rentree.dto.ChatMessageResponseDTO;
import com.example.rentree.service.ChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatmessages")
@RequiredArgsConstructor
public class ChatMessageController {

    private final ChatMessageService chatMessageService;

    // 메시지 전송
    @PostMapping
    public ResponseEntity<ChatMessageResponseDTO> sendMessage(@RequestBody ChatMessageRequestDTO requestDTO) {
        ChatMessageResponseDTO responseDTO = chatMessageService.sendMessage(requestDTO);
        return ResponseEntity.ok(responseDTO);
    }

    // 특정 채팅방의 메시지 목록 조회
    @GetMapping("/room/{chatRoomId}")
    public ResponseEntity<List<ChatMessageResponseDTO>> getMessagesByChatRoomId(@PathVariable Long chatRoomId) {
        List<ChatMessageResponseDTO> messageList = chatMessageService.getMessagesByChatRoomId(chatRoomId);
        return ResponseEntity.ok(messageList);
    }
}
