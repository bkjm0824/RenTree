package com.example.rentree.controller;

import com.example.rentree.dto.ChatRoomSummaryDTO;
import com.example.rentree.service.ChatRoomQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatrooms")
@RequiredArgsConstructor
public class ChatRoomQueryController {

    private final ChatRoomQueryService chatRoomQueryService;

    @GetMapping("/student/{studentNum}")
    public ResponseEntity<List<ChatRoomSummaryDTO>> getChatRoomsByStudentNum(@PathVariable String studentNum) {
        List<ChatRoomSummaryDTO> responseList = chatRoomQueryService.getChatRoomsByStudentNum(studentNum);
        return ResponseEntity.ok(responseList);
    }
}
