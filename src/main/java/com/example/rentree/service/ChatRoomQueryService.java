package com.example.rentree.service;

import com.example.rentree.domain.RentalChatRoom;
import com.example.rentree.domain.RequestChatRoom;
import com.example.rentree.dto.ChatRoomSummaryDTO;
import com.example.rentree.repository.RentalChatRoomRepository;
import com.example.rentree.repository.RequestChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

        return List.copyOf(rentalRooms).stream()
                .collect(Collectors.toCollection(() -> {
                    List<ChatRoomSummaryDTO> all = new java.util.ArrayList<>();
                    all.addAll(rentalRooms);
                    all.addAll(requestRooms);
                    return all;
                }));
    }

    private ChatRoomSummaryDTO toRentalSummary(RentalChatRoom chatRoom) {
        return ChatRoomSummaryDTO.builder()
                .roomId(chatRoom.getId())
                .type("rental")
                .relatedItemId(chatRoom.getRentalItem().getId())
                .relatedItemTitle(chatRoom.getRentalItem().getTitle())
                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .responderNickname(chatRoom.getResponder().getNickname())

                .writerStudentNum(chatRoom.getRentalItem().getStudent().getStudentNum())
                .writerNickname(chatRoom.getRentalItem().getStudent().getNickname())

                .createdAt(chatRoom.getCreatedAt())
                .build();
    }

    private ChatRoomSummaryDTO toRequestSummary(RequestChatRoom chatRoom) {
        return ChatRoomSummaryDTO.builder()
                .roomId(chatRoom.getId())
                .type("request")
                .relatedItemId(chatRoom.getItemRequest().getId())
                .relatedItemTitle(chatRoom.getItemRequest().getTitle())
                .requesterStudentNum(chatRoom.getRequester().getStudentNum())
                .responderStudentNum(chatRoom.getResponder().getStudentNum())
                .requesterNickname(chatRoom.getRequester().getNickname())
                .responderNickname(chatRoom.getResponder().getNickname())

                .writerStudentNum(chatRoom.getItemRequest().getStudent().getStudentNum())
                .writerNickname(chatRoom.getItemRequest().getStudent().getNickname())

                .createdAt(chatRoom.getCreatedAt())
                .build();
    }
}

