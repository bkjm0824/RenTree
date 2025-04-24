package com.example.rentree.controller;

import com.example.rentree.dto.ChatRoomCreateRequestDTO;
import com.example.rentree.dto.ChatRoomResponseDTO;
import com.example.rentree.dto.ChatRoomDeleteResponseDTO;
import com.example.rentree.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatrooms")
@RequiredArgsConstructor
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 채팅방 생성
    @PostMapping
    public ResponseEntity<ChatRoomResponseDTO> createChatRoom(@RequestBody ChatRoomCreateRequestDTO requestDTO) {
        ChatRoomResponseDTO responseDTO = chatRoomService.createChatRoom(requestDTO);
        return ResponseEntity.ok(responseDTO);
    }

    // 채팅방 단건 조회
    @GetMapping("/{roomId}")
    public ResponseEntity<ChatRoomResponseDTO> getChatRoom(@PathVariable Long roomId) {
        ChatRoomResponseDTO responseDTO = chatRoomService.getChatRoom(roomId);
        return ResponseEntity.ok(responseDTO);
    }

    // 채팅방 삭제
    @DeleteMapping("/{roomId}")
    public ResponseEntity<ChatRoomDeleteResponseDTO> deleteChatRoom(@PathVariable Long roomId) {
        ChatRoomDeleteResponseDTO responseDTO = chatRoomService.deleteChatRoom(roomId);
        return ResponseEntity.ok(responseDTO);
    }

    // 특정 물품 ID로 채팅방 목록 조회
    @GetMapping("/rentalItem/{rentalItemId}")
    public ResponseEntity<List<ChatRoomResponseDTO>> getChatRoomsByRentalItemId(@PathVariable Long rentalItemId) {
        List<ChatRoomResponseDTO> responseList = chatRoomService.getChatRoomsByRentalItemId(rentalItemId);
        return ResponseEntity.ok(responseList);
    }
}
