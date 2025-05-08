package com.example.rentree.controller;

import com.example.rentree.dto.RequestChatRoomResponseDTO;
import com.example.rentree.dto.RequestChatRoomDeleteResponseDTO;
import com.example.rentree.service.RequestChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chatrooms/request")
@RequiredArgsConstructor
public class RequestChatRoomController {

    private final RequestChatRoomService requestChatRoomService;

    @PostMapping("/{itemRequestId}")
    public ResponseEntity<RequestChatRoomResponseDTO> create(@PathVariable Long itemRequestId,
                                                             @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(requestChatRoomService.createChatRoom(itemRequestId, requesterStudentNum));
    }

    @GetMapping("/{itemRequestId}")
    public ResponseEntity<RequestChatRoomResponseDTO> get(@PathVariable Long itemRequestId,
                                                          @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(requestChatRoomService.getChatRoom(itemRequestId, requesterStudentNum));
    }

    @DeleteMapping("/{itemRequestId}")
    public ResponseEntity<RequestChatRoomDeleteResponseDTO> delete(@PathVariable Long itemRequestId,
                                                                   @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(requestChatRoomService.deleteChatRoom(itemRequestId, requesterStudentNum));
    }
}
