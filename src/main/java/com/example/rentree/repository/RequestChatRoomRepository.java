package com.example.rentree.repository;

import com.example.rentree.domain.RequestChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RequestChatRoomRepository extends JpaRepository<RequestChatRoom, Long> {

    // 특정 요청자와 요청글 기준으로 채팅방 존재 여부 확인
    Optional<RequestChatRoom> findByRequester_IdAndItemRequest_Id(Long requesterId, Long itemRequestId);

    List<RequestChatRoom> findByRequester_StudentNumOrResponder_StudentNum(String requester, String responder);

    boolean existsByRequester_IdAndItemRequest_Id(Long requesterId, Long itemRequestId);

    Optional<RequestChatRoom> findByRequester_IdAndItemRequest_IdOrResponder_IdAndItemRequest_Id(Long requesterId, Long itemRequestId, Long responderId, Long itemRequestId2);
}
