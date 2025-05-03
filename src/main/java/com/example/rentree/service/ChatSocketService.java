package com.example.rentree.service;

import com.example.rentree.domain.ChatMessage;
import com.example.rentree.domain.ChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.ChatMessageRequestDTO;
import com.example.rentree.dto.ChatMessageResponseDTO;
import com.example.rentree.repository.ChatMessageRepository;
import com.example.rentree.repository.ChatRoomRepository;
import com.example.rentree.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ChatSocketService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final StudentRepository studentRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public ChatMessageResponseDTO handleChatMessage(ChatMessageRequestDTO requestDTO) {
        ChatRoom chatRoom = chatRoomRepository.findById(requestDTO.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("해당 채팅방을 찾을 수 없습니다."));

        Student sender = studentRepository.findByStudentNum(requestDTO.getSenderStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다."));

        ChatMessage chatMessage = ChatMessage.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .message(requestDTO.getMessage())
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);

        ChatMessageResponseDTO responseDTO = ChatMessageResponseDTO.builder()
                .messageId(savedMessage.getId())
                .chatRoomId(chatRoom.getId())
                .senderStudentNum(sender.getStudentNum())
                .senderNickname(sender.getNickname())
                .message(savedMessage.getMessage())
                .sentAt(savedMessage.getSentAt())
                .build();

        // 동적으로 특정 채팅방에 메시지 전송
        messagingTemplate.convertAndSend("/topic/chat/" + chatRoom.getId(), responseDTO);

        return responseDTO;
    }
}
