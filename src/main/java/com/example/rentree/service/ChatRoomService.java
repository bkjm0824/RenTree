package com.example.rentree.service;

import com.example.rentree.domain.ChatRoom;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.ChatRoomCreateRequestDTO;
import com.example.rentree.dto.ChatRoomResponseDTO;
import com.example.rentree.dto.ChatRoomDeleteResponseDTO;
import com.example.rentree.repository.ChatRoomRepository;
import com.example.rentree.repository.RentalItemRepository;
import com.example.rentree.repository.StudentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final StudentRepository studentRepository;
    private final RentalItemRepository rentalItemRepository;

    public ChatRoomService(ChatRoomRepository chatRoomRepository, StudentRepository studentRepository, RentalItemRepository rentalItemRepository) {
        this.chatRoomRepository = chatRoomRepository;
        this.studentRepository = studentRepository;
        this.rentalItemRepository = rentalItemRepository;
    }

    // 채팅방 생성
    @Transactional
    public ChatRoomResponseDTO createChatRoom(ChatRoomCreateRequestDTO request) {
        // 요청자 조회
        Student requester = studentRepository.findByStudentNum(request.getRequesterStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다."));

        // 물품 조회
        RentalItem rentalItem = rentalItemRepository.findById(request.getRentalItemId())
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 렌탈 아이템을 찾을 수 없습니다."));

        // 요청자가 물품의 소유자인지 확인
        Student responder = rentalItem.getResponder();

        // 중복 채팅방 여부 확인
        Optional<ChatRoom> existingChatRoom = chatRoomRepository
                .findByRequester_IdAndRentalItem_Id(requester.getId(), rentalItem.getId());

        if (existingChatRoom.isPresent()) {
            throw new IllegalStateException("이미 해당 물품에 대해 채팅방이 존재합니다.");
        }

        // 새 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .rentalItem(rentalItem)
                .requester(requester)
                .responder(responder)
                .createdAt(java.time.LocalDateTime.now())
                .build();

        ChatRoom savedChatRoom = chatRoomRepository.save(chatRoom);

        return ChatRoomResponseDTO.builder()
                .roomId(savedChatRoom.getId())
                .rentalItemId(rentalItem.getId())
                .rentalItemTitle(rentalItem.getTitle())
                .requesterNickname(requester.getNickname())
                .responderNickname(responder.getNickname())
                .responderStudentNum(responder.getStudentNum())
                .createdAt(savedChatRoom.getCreatedAt())
                .build();
    }


    // 채팅방 조회
    @Transactional(readOnly = true)
    public ChatRoomResponseDTO getChatRoom(Long roomId) {
        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 채팅방을 찾을 수 없습니다: " + roomId));

        // 요청자의 닉네임 조회
        String requesterNickname = chatRoom.getRequester().getNickname();

        // 응답자의 닉네임 조회
        String responderNickname = chatRoom.getResponder().getNickname();

        // 채팅방 응답 DTO 생성
        RentalItem rentalItem = chatRoom.getRentalItem(); // rentalItem 객체 가져오기
        return ChatRoomResponseDTO.builder()
                .roomId(chatRoom.getId())
                .rentalItemId(rentalItem.getId()) // rentalItem ID 반환
                .rentalItemTitle(rentalItem.getTitle()) // 물품 제목 반환
                .requesterNickname(requesterNickname)
                .responderNickname(responderNickname)
                .createdAt(chatRoom.getCreatedAt())
                .build();
    }

    // 채팅방 삭제
    @Transactional
    public ChatRoomDeleteResponseDTO deleteChatRoom(Long roomId) {
        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 채팅방을 찾을 수 없습니다: " + roomId));

        // 채팅방 삭제
        chatRoomRepository.deleteById(roomId);

        // 삭제 응답 DTO 반환
        return new ChatRoomDeleteResponseDTO(roomId, "채팅방이 성공적으로 삭제되었습니다.");
    }

    // 학번으로 요청자가 생성한 채팅방 목록 조회
    @Transactional(readOnly = true)
    public List<ChatRoomResponseDTO> getChatRoomsByStudentNum(String studentNum) {
        List<ChatRoom> chatRooms = chatRoomRepository.findByRequester_StudentNumOrResponder_StudentNum(studentNum, studentNum);
        return chatRooms.stream()
                .map(chatRoom -> {
                    RentalItem rentalItem = chatRoom.getRentalItem();
                    String requesterNickname = chatRoom.getRequester().getNickname();
                    String responderNickname = chatRoom.getResponder().getNickname();
                    return ChatRoomResponseDTO.builder()
                            .roomId(chatRoom.getId())
                            .rentalItemId(rentalItem.getId())
                            .rentalItemTitle(rentalItem.getTitle())
                            .requesterNickname(requesterNickname)
                            .responderNickname(responderNickname)
                            .createdAt(chatRoom.getCreatedAt())
                            .build();
                })
                .collect(Collectors.toList());
    }
}
