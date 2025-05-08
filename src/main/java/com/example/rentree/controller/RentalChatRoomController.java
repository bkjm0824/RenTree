package com.example.rentree.controller;

import com.example.rentree.dto.RentalChatRoomResponseDTO;
import com.example.rentree.dto.RentalChatRoomDeleteResponseDTO;
import com.example.rentree.service.RentalChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chatrooms/rental")
@RequiredArgsConstructor
public class RentalChatRoomController {

    private final RentalChatRoomService rentalChatRoomService;

    @PostMapping("/{rentalItemId}")
    public ResponseEntity<RentalChatRoomResponseDTO> create(@PathVariable Long rentalItemId,
                                                            @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(rentalChatRoomService.createChatRoom(rentalItemId, requesterStudentNum));
    }

    @GetMapping("/{rentalItemId}")
    public ResponseEntity<RentalChatRoomResponseDTO> get(@PathVariable Long rentalItemId,
                                                         @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(rentalChatRoomService.getChatRoom(rentalItemId, requesterStudentNum));
    }

    @DeleteMapping("/{rentalItemId}")
    public ResponseEntity<RentalChatRoomDeleteResponseDTO> delete(@PathVariable Long rentalItemId,
                                                                  @RequestParam String requesterStudentNum) {
        return ResponseEntity.ok(rentalChatRoomService.deleteChatRoom(rentalItemId, requesterStudentNum));
    }
}
