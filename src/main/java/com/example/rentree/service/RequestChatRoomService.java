package com.example.rentree.service;

import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RequestChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RequestChatRoomDeleteResponseDTO;
import com.example.rentree.dto.RequestChatRoomResponseDTO;
import com.example.rentree.repository.ItemRequestRepository;
import com.example.rentree.repository.RequestChatRoomRepository;
import com.example.rentree.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class RequestChatRoomService {

    private final RequestChatRoomRepository requestChatRoomRepository;
    private final StudentRepository studentRepository;
    private final ItemRequestRepository itemRequestRepository;

    @Transactional
    public RequestChatRoomResponseDTO createChatRoom(Long itemRequestId, String requesterStudentNum) {
        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        ItemRequest itemRequest = itemRequestRepository.findById(itemRequestId)
                .orElseThrow(() -> new IllegalArgumentException("요청글 없음"));

        if (requestChatRoomRepository.existsByRequester_IdAndItemRequest_Id((long) requester.getId(), itemRequestId)) {
            throw new IllegalStateException("이미 채팅방 존재");
        }

        RequestChatRoom chatRoom = RequestChatRoom.builder()
                .itemRequest(itemRequest)
                .requester(requester)
                .responder(itemRequest.getStudent())
                .createdAt(LocalDateTime.now())
                .build();

        RequestChatRoom saved = requestChatRoomRepository.save(chatRoom);
        return toDTO(saved);
    }

    @Transactional(readOnly = true)
    public RequestChatRoomResponseDTO getChatRoom(Long itemRequestId, String requesterStudentNum) {


        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        RequestChatRoom chatRoom = requestChatRoomRepository
                .findByRequester_IdAndItemRequest_Id((long) requester.getId(), itemRequestId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 없음"));


        return toDTO(chatRoom);
    }

    @Transactional
    public RequestChatRoomDeleteResponseDTO deleteChatRoom(Long itemRequestId, String requesterStudentNum) {
        Student requester = studentRepository.findByStudentNum(requesterStudentNum)
                .orElseThrow(() -> new IllegalArgumentException("학생 없음"));

        RequestChatRoom chatRoom = requestChatRoomRepository
                .findByRequester_IdAndItemRequest_Id((long) requester.getId(), itemRequestId)
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
            requestChatRoomRepository.delete(chatRoom);
            return new RequestChatRoomDeleteResponseDTO(chatRoom.getId(), "채팅방 완전히 삭제됨");
        }

        return new RequestChatRoomDeleteResponseDTO(chatRoom.getId(), "한 명만 나갔습니다. 상대도 나가야 삭제됩니다.");
    }

    private RequestChatRoomResponseDTO toDTO(RequestChatRoom chatRoom) {
        return RequestChatRoomResponseDTO.builder()
                .roomId(chatRoom.getId())
                .itemRequestId(chatRoom.getItemRequest().getId())
                .itemRequestTitle(chatRoom.getItemRequest().getTitle())

                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .requesterProfileImage(chatRoom.getRequester().getProfileImage()) // ✅ 추가

                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .responderNickname(chatRoom.getResponder().getNickname())
                .responderProfileImage(chatRoom.getResponder().getProfileImage()) // ✅ 추가

                .requesterExited(chatRoom.isRequesterExited())
                .responderExited(chatRoom.isResponderExited())
                .createdAt(chatRoom.getCreatedAt())
                .build();
    }
}
