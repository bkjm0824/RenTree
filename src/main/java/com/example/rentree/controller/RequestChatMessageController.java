package com.example.rentree.controller;

import com.example.rentree.dto.RequestChatMessageRequestDTO;
import com.example.rentree.dto.RequestChatMessageResponseDTO;
import com.example.rentree.dto.RequestChatMessageDeleteResponseDTO;
import com.example.rentree.service.RequestChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatmessages/request")
@RequiredArgsConstructor
public class RequestChatMessageController {

    private final RequestChatMessageService messageService;

    // 요청글 채팅 메시지 전송 (REST 기반)
    @PostMapping
    public ResponseEntity<RequestChatMessageResponseDTO> sendMessage(@RequestBody RequestChatMessageRequestDTO dto) {
        return ResponseEntity.ok(messageService.sendMessage(dto));
    }

    // 요청글 채팅방의 메시지 목록 조회
    @GetMapping("/{chatRoomId}")
    public ResponseEntity<List<RequestChatMessageResponseDTO>> getMessages(@PathVariable Long chatRoomId) {
        return ResponseEntity.ok(messageService.getMessages(chatRoomId));
    }

    // 특정 메시지 삭제 (작성자 본인만 가능)
    @DeleteMapping("/{messageId}")
    public ResponseEntity<RequestChatMessageDeleteResponseDTO> deleteMessage(
            @PathVariable Long messageId,
            @RequestParam String senderStudentNum) {
        RequestChatMessageDeleteResponseDTO result = messageService.deleteMessage(messageId, senderStudentNum);
        return ResponseEntity.ok(result);
    }
}
