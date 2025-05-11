package com.example.rentree.service;

import com.example.rentree.domain.RentalChatRoom;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalChatRoomDeleteResponseDTO;
import com.example.rentree.dto.RentalChatRoomResponseDTO;
import com.example.rentree.repository.RentalChatRoomRepository;
import com.example.rentree.repository.RentalItemRepository;
import com.example.rentree.repository.StudentRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class RentalChatRoomService {

    private final RentalChatRoomRepository rentalChatRoomRepository;
    private final StudentRepository studentRepository;
    private final RentalItemRepository rentalItemRepository;

    @Transactional
    public RentalChatRoomResponseDTO createChatRoom(Long rentalItemId, String requesterStudentNum) {
        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        RentalItem item = rentalItemRepository.findById(rentalItemId)
                .orElseThrow(() -> new IllegalArgumentException("렌탈 아이템 없음"));

        if (rentalChatRoomRepository.existsByRequester_IdAndRentalItem_Id((long) requester.getId(), rentalItemId)) {
            throw new IllegalStateException("이미 채팅방 존재");
        }

        RentalChatRoom chatRoom = RentalChatRoom.builder()
                .rentalItem(item)
                .requester(requester)
                .responder(item.getStudent())
                .createdAt(LocalDateTime.now())
                .build();

        RentalChatRoom saved = rentalChatRoomRepository.save(chatRoom);
        return toDTO(saved);
    }

    @Transactional
    public RentalChatRoomResponseDTO getChatRoom(Long rentalItemId, String requesterStudentNum) {
        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        RentalChatRoom chatRoom = rentalChatRoomRepository
                .findByRequester_IdAndRentalItem_Id((long) requester.getId(), rentalItemId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 없음"));

        return toDTO(chatRoom);
    }

    @Transactional
    public RentalChatRoomDeleteResponseDTO deleteChatRoom(Long rentalItemId, String requesterStudentNum) {
        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        RentalChatRoom chatRoom = rentalChatRoomRepository
                .findByRequester_IdAndRentalItem_Id((long) requester.getId(), rentalItemId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 없음"));

        boolean isRequester = chatRoom.getRequester().getId() == requester.getId();

        if (isRequester) {
            chatRoom.setRequesterExited(true);
        } else if (chatRoom.getResponder().getId() == requester.getId()) {
            chatRoom.setResponderExited(true);
        } else {
            throw new IllegalStateException("채팅방 참여자가 아님");
        }

        if (chatRoom.isRequesterExited() && chatRoom.isResponderExited()) {
            rentalChatRoomRepository.delete(chatRoom);
            return new RentalChatRoomDeleteResponseDTO(chatRoom.getId(), "채팅방 완전히 삭제됨");
        }

        return new RentalChatRoomDeleteResponseDTO(chatRoom.getId(), "한 명만 나갔습니다. 상대도 나가야 삭제됩니다.");
    }

    private RentalChatRoomResponseDTO toDTO(RentalChatRoom chatRoom) {
        return RentalChatRoomResponseDTO.builder()
                .roomId(chatRoom.getId())
                .rentalItemId(chatRoom.getRentalItem().getId())
                .rentalItemTitle(chatRoom.getRentalItem().getTitle())
                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .responderNickname(chatRoom.getResponder().getNickname())
                .createdAt(chatRoom.getCreatedAt())
                .build();
    }
}
