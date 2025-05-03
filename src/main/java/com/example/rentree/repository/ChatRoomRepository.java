package com.example.rentree.repository;

import com.example.rentree.domain.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    Optional<ChatRoom> findById(Long roomId);

    List<ChatRoom> findByRequester_StudentNum(String studentNum);

    // 요청자 ID + 렌탈 아이템 ID 조합으로 중복 채팅방 여부 확인
    Optional<ChatRoom> findByRequester_IdAndRentalItem_Id(int requesterId, Long rentalItemId);
}
