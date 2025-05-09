// RequestChatMessageService.java
package com.example.rentree.service;

import com.example.rentree.domain.RequestChatMessage;
import com.example.rentree.domain.RequestChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RequestChatMessageRequestDTO;
import com.example.rentree.dto.RequestChatMessageResponseDTO;
import com.example.rentree.dto.RequestChatMessageDeleteResponseDTO;
import com.example.rentree.repository.RequestChatMessageRepository;
import com.example.rentree.repository.RequestChatRoomRepository;
import com.example.rentree.repository.StudentRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RequestChatMessageService {

    private final RequestChatMessageRepository messageRepo;
    private final RequestChatRoomRepository roomRepo;
    private final StudentRepository studentRepo;

    @Transactional
    public RequestChatMessageResponseDTO sendMessage(RequestChatMessageRequestDTO dto) {
        RequestChatRoom room = roomRepo.findById(dto.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("채팅방 없음"));

        Student sender = studentRepo.findByStudentNum(dto.getSenderStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("발신자 없음"));

        Student receiver = studentRepo.findByStudentNum(dto.getReceiverStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("수신자 없음"));

        RequestChatMessage message = RequestChatMessage.builder()
                .chatRoom(room)
                .sender(sender)
                .receiver(receiver)
                .message(dto.getMessage())
                .build();

        RequestChatMessage saved = messageRepo.save(message);

        return RequestChatMessageResponseDTO.builder()
                .messageId(saved.getId())
                .chatRoomId(room.getId())
                .senderStudentNum(sender.getStudentNum())
                .senderNickname(sender.getNickname())
                .receiverStudentNum(receiver.getStudentNum())
                .receiverNickname(receiver.getNickname())
                .message(saved.getMessage())
                .sentAt(saved.getSentAt())
                .build();
    }

    @Transactional
    public RequestChatMessageDeleteResponseDTO deleteMessage(Long messageId, String senderStudentNum) {
        messageRepo.deleteByIdAndSender_StudentNum(messageId, senderStudentNum);
        return new RequestChatMessageDeleteResponseDTO(messageId, "요청 채팅 메시지 삭제 완료");
    }

    @Transactional
    public List<RequestChatMessageResponseDTO> getMessages(Long chatRoomId) {
        return messageRepo.findByChatRoom_IdOrderBySentAtAsc(chatRoomId).stream()
                .map(msg -> RequestChatMessageResponseDTO.builder()
                        .messageId(msg.getId())
                        .chatRoomId(chatRoomId)
                        .senderStudentNum(msg.getSender().getStudentNum())
                        .senderNickname(msg.getSender().getNickname())
                        .receiverStudentNum(msg.getReceiver().getStudentNum())
                        .receiverNickname(msg.getReceiver().getNickname())
                        .message(msg.getMessage())
                        .sentAt(msg.getSentAt())
                        .build())
                .collect(Collectors.toList());
    }
}
