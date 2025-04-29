package com.example.rentree.repository;

import com.example.rentree.domain.ChatMessage;
import com.example.rentree.domain.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    // 특정 채팅방의 모든 메시지 조회 (보통 시간순 정렬 필요)
    List<ChatMessage> findByChatRoomOrderBySentAtAsc(ChatRoom chatRoom);

    // 또는 chatRoomId로 직접 조회할 수도 있음
    List<ChatMessage> findByChatRoom_IdOrderBySentAtAsc(Long chatRoomId);
}
