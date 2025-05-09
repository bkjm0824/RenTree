package com.example.rentree.controller;

import com.example.rentree.dto.RentalChatMessageRequestDTO;
import com.example.rentree.dto.RentalChatMessageResponseDTO;
import com.example.rentree.dto.RentalChatMessageDeleteResponseDTO;
import com.example.rentree.service.RentalChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatmessages/rental")
@RequiredArgsConstructor
public class RentalChatMessageController {

    private final RentalChatMessageService messageService;

    // 메시지 전송 (REST 기반)
    @PostMapping
    public ResponseEntity<RentalChatMessageResponseDTO> sendMessage(@RequestBody RentalChatMessageRequestDTO dto) {
        return ResponseEntity.ok(messageService.sendMessage(dto));
    }

    // 메시지 목록 조회
    @GetMapping("/{chatRoomId}")
    public ResponseEntity<List<RentalChatMessageResponseDTO>> getMessages(@PathVariable Long chatRoomId) {
        return ResponseEntity.ok(messageService.getMessages(chatRoomId));
    }

    // 특정 메시지 삭제 (작성자 본인만 가능)
    @DeleteMapping("/{messageId}")
    public ResponseEntity<RentalChatMessageDeleteResponseDTO> deleteMessage(
            @PathVariable Long messageId,
            @RequestParam String senderStudentNum) {
        RentalChatMessageDeleteResponseDTO result = messageService.deleteMessage(messageId, senderStudentNum);
        return ResponseEntity.ok(result);
    }
}
