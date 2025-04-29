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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatMessageService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final StudentRepository studentRepository;

    // 메시지 저장
    @Transactional
    public ChatMessageResponseDTO sendMessage(ChatMessageRequestDTO requestDTO) {
        // 채팅방 찾기
        ChatRoom chatRoom = chatRoomRepository.findById(requestDTO.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("해당 채팅방을 찾을 수 없습니다."));

        // 발신자(학생) 찾기
        Student sender = studentRepository.findByStudentNum(requestDTO.getSenderStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다."));

        // 메시지 엔티티 생성
        ChatMessage chatMessage = ChatMessage.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .message(requestDTO.getMessage())
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);

        // 응답 DTO 생성
        return ChatMessageResponseDTO.builder()
                .messageId(savedMessage.getId())
                .chatRoomId(chatRoom.getId())
                .senderStudentNum(sender.getStudentNum())
                .senderNickname(sender.getNickname())
                .message(savedMessage.getMessage())
                .sentAt(savedMessage.getSentAt())
                .build();
    }

    // 채팅방의 메시지 목록 조회
    @Transactional(readOnly = true)
    public List<ChatMessageResponseDTO> getMessagesByChatRoomId(Long chatRoomId) {
        List<ChatMessage> messages = chatMessageRepository.findByChatRoom_IdOrderBySentAtAsc(chatRoomId);

        return messages.stream()
                .map(msg -> ChatMessageResponseDTO.builder()
                        .messageId(msg.getId())
                        .chatRoomId(msg.getChatRoom().getId())
                        .senderStudentNum(msg.getSender().getStudentNum())
                        .senderNickname(msg.getSender().getNickname())
                        .message(msg.getMessage())
                        .sentAt(msg.getSentAt())
                        .build())
                .collect(Collectors.toList());
    }
}
