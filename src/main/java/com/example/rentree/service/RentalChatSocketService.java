package com.example.rentree.service;

import com.example.rentree.domain.RentalChatMessage;
import com.example.rentree.domain.RentalChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalChatMessageRequestDTO;
import com.example.rentree.dto.RentalChatMessageResponseDTO;
import com.example.rentree.repository.RentalChatMessageRepository;
import com.example.rentree.repository.RentalChatRoomRepository;
import com.example.rentree.repository.StudentRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RentalChatSocketService {

    private final RentalChatRoomRepository roomRepo;
    private final RentalChatMessageRepository messageRepo;
    private final StudentRepository studentRepo;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public RentalChatMessageResponseDTO handle(RentalChatMessageRequestDTO dto) {
        RentalChatRoom room = roomRepo.findById(dto.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("채팅방 없음"));

        Student sender = studentRepo.findByStudentNum(dto.getSenderStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("발신자 없음"));

        Student receiver = studentRepo.findByStudentNum(dto.getReceiverStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("수신자 없음"));

        RentalChatMessage message = RentalChatMessage.builder()
                .chatRoom(room)
                .sender(sender)
                .receiver(receiver)
                .message(dto.getMessage())
                .build();

        messageRepo.save(message);

        RentalChatMessageResponseDTO response = RentalChatMessageResponseDTO.builder()
                .messageId(message.getId())
                .chatRoomId(room.getId())
                .senderStudentNum(sender.getStudentNum())
                .senderNickname(sender.getNickname())
                .receiverStudentNum(receiver.getStudentNum())
                .receiverNickname(receiver.getNickname())
                .message(message.getMessage())
                .sentAt(message.getSentAt())
                .build();

        messagingTemplate.convertAndSendToUser(sender.getStudentNum(), "/queue/messages", response);
        messagingTemplate.convertAndSendToUser(receiver.getStudentNum(), "/queue/messages", response);

        return response;
    }
}

