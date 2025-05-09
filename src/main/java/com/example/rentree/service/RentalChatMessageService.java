package com.example.rentree.service;

import com.example.rentree.domain.RentalChatMessage;
import com.example.rentree.domain.RentalChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalChatMessageRequestDTO;
import com.example.rentree.dto.RentalChatMessageResponseDTO;
import com.example.rentree.dto.RentalChatMessageDeleteResponseDTO;
import com.example.rentree.repository.RentalChatMessageRepository;
import com.example.rentree.repository.RentalChatRoomRepository;
import com.example.rentree.repository.StudentRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RentalChatMessageService {

    private final RentalChatMessageRepository messageRepo;
    private final RentalChatRoomRepository roomRepo;
    private final StudentRepository studentRepo;

    // REST 기반 메시지 전송 (저장 후 응답 반환)
    @Transactional
    public RentalChatMessageResponseDTO sendMessage(RentalChatMessageRequestDTO dto) {
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

        RentalChatMessage saved = messageRepo.save(message);

        return RentalChatMessageResponseDTO.builder()
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

    // 메시지 삭제
    @Transactional
    public RentalChatMessageDeleteResponseDTO deleteMessage(Long messageId, String senderStudentNum) {
        messageRepo.deleteByIdAndSender_StudentNum(messageId, senderStudentNum);
        return new RentalChatMessageDeleteResponseDTO(messageId, "렌탈 채팅 메시지 삭제 완료");
    }

    // 채팅방 메시지 목록 조회
    @Transactional
    public List<RentalChatMessageResponseDTO> getMessages(Long chatRoomId) {
        return messageRepo.findByChatRoom_IdOrderBySentAtAsc(chatRoomId).stream()
                .map(msg -> RentalChatMessageResponseDTO.builder()
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
