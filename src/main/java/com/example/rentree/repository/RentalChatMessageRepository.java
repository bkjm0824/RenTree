package com.example.rentree.repository;

import com.example.rentree.domain.RentalChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RentalChatMessageRepository extends JpaRepository<RentalChatMessage, Long> {

    // 채팅방 내 모든 메시지 조회 (예: 채팅방 입장 시)
    List<RentalChatMessage> findByChatRoom_IdOrderBySentAtAsc(Long chatRoomId);
}
