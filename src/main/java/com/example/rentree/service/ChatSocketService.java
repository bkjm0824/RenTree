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


        Student receiver = chatRoom.getParticipants().stream()
                .filter(p -> p instanceof Student && !((Student)p).getStudentNum().equals(sender.getStudentNum())) // Student 타입으로 캐스팅
                .map(p -> (Student)p)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("상대방을 찾을 수 없습니다."));

        ChatMessage chatMessage = ChatMessage.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .receiver(receiver) // 채팅방에서 유추한 수신자
                .message(requestDTO.getMessage())
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);

        ChatMessageResponseDTO responseDTO = ChatMessageResponseDTO.builder()
                .messageId(savedMessage.getId())
                .chatRoomId(chatRoom.getId())
                .senderStudentNum(sender.getStudentNum())
                .senderNickname(sender.getNickname())
                .receiverStudentNum(receiver.getStudentNum())
                .receiverNickname(receiver.getNickname())
                .message(savedMessage.getMessage())
                .sentAt(savedMessage.getSentAt())
                .build();

        // 발신자와 수신자에게 메시지 전송
        messagingTemplate.convertAndSend("/user/" + sender.getStudentNum() + "/queue/messages", responseDTO); // 발신자에게도 전송
        messagingTemplate.convertAndSend("/user/" + receiver.getStudentNum() + "/queue/messages", responseDTO); // 수신자에게 전송

        return responseDTO;
    }
}