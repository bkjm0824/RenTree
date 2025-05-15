package com.example.rentree.service;

import com.example.rentree.domain.RentalChatRoom;
import com.example.rentree.domain.RequestChatRoom;
import com.example.rentree.dto.ChatRoomSummaryDTO;
import com.example.rentree.repository.RentalChatRoomRepository;
import com.example.rentree.repository.RequestChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatRoomQueryService {

    private final RentalChatRoomRepository rentalRepo;
    private final RequestChatRoomRepository requestRepo;

    @Transactional(readOnly = true)
    public List<ChatRoomSummaryDTO> getChatRoomsByStudentNum(String studentNum) {
        List<ChatRoomSummaryDTO> rentalRooms = rentalRepo
                .findByRequester_StudentNumOrResponder_StudentNum(studentNum, studentNum)
                .stream()
                .map(this::toRentalSummary)
                .toList();

        List<ChatRoomSummaryDTO> requestRooms = requestRepo
                .findByRequester_StudentNumOrResponder_StudentNum(studentNum, studentNum)
                .stream()
                .map(this::toRequestSummary)
                .toList();

        // 가변 리스트를 사용하여 중복 제거
        List<ChatRoomSummaryDTO> allRooms = new ArrayList<>();
        allRooms.addAll(rentalRooms);
        allRooms.addAll(requestRooms);

        // distinct()를 사용하여 중복 제거
        return allRooms.stream()
                .distinct()
                .toList();
    }

    private ChatRoomSummaryDTO toRentalSummary(RentalChatRoom chatRoom) {
        return ChatRoomSummaryDTO.builder()
                .roomId(chatRoom.getId())
                .type("rental")
                .relatedItemId(chatRoom.getRentalItem() != null ? chatRoom.getRentalItem().getId() : null)
                .relatedItemTitle(chatRoom.getRentalItem() != null ? chatRoom.getRentalItem().getTitle() : null)
                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .responderNickname(chatRoom.getResponder().getNickname())
                .writerStudentNum(chatRoom.getRentalItem() != null ? chatRoom.getRentalItem().getStudent().getStudentNum() : null)
                .writerNickname(chatRoom.getRentalItem() != null ? chatRoom.getRentalItem().getStudent().getNickname() : null)
                .requesterProfileImage(chatRoom.getRequester().getProfileImage())
                .responderProfileImage(chatRoom.getResponder().getProfileImage())
                .createdAt(chatRoom.getCreatedAt())
                .build();
    }

    private ChatRoomSummaryDTO toRequestSummary(RequestChatRoom chatRoom) {
        return ChatRoomSummaryDTO.builder()
                .roomId(chatRoom.getId())
                .type("request")
                .relatedItemId(chatRoom.getItemRequest() != null ? chatRoom.getItemRequest().getId() : null)
                .relatedItemTitle(chatRoom.getItemRequest() != null ? chatRoom.getItemRequest().getTitle() : null)
                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .responderNickname(chatRoom.getResponder().getNickname())
                .writerStudentNum(chatRoom.getItemRequest() != null ? chatRoom.getItemRequest().getStudent().getStudentNum() : null)
                .writerNickname(chatRoom.getItemRequest() != null ? chatRoom.getItemRequest().getStudent().getNickname() : null)
                .requesterProfileImage(chatRoom.getRequester().getProfileImage())
                .responderProfileImage(chatRoom.getResponder().getProfileImage())
                .createdAt(chatRoom.getCreatedAt())
                .build();
    }}

