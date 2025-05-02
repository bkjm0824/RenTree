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

    // 채팅방 조회
    @GetMapping("/{roomId}")
    public ResponseEntity<ChatRoomResponseDTO> getChatRoom(@PathVariable Long roomId) {
        ChatRoomResponseDTO responseDTO = chatRoomService.getChatRoom(roomId);
        return ResponseEntity.ok(responseDTO);
    }

    // 채팅방 나가기
    @DeleteMapping("/{roomId}")
    public ResponseEntity<ChatRoomDeleteResponseDTO> deleteChatRoom(@PathVariable Long roomId) {
        ChatRoomDeleteResponseDTO responseDTO = chatRoomService.deleteChatRoom(roomId);
        return ResponseEntity.ok(responseDTO);
    }

    // 학번으로 채팅방 목록 조회
    @GetMapping("/student/{studentNum}")
    public ResponseEntity<List<ChatRoomResponseDTO>> getChatRoomsByStudentNum(@PathVariable String studentNum) {
        List<ChatRoomResponseDTO> responseList = chatRoomService.getChatRoomsByStudentNum(studentNum);
        return ResponseEntity.ok(responseList);
    }
}
