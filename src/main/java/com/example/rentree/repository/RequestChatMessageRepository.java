package com.example.rentree.repository;

import com.example.rentree.domain.RequestChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RequestChatMessageRepository extends JpaRepository<RequestChatMessage, Long> {

    // 채팅방 내 모든 메시지 조회
    List<RequestChatMessage> findByChatRoom_IdOrderBySentAtAsc(Long chatRoomId);

    void deleteByIdAndSender_StudentNum(Long id, String senderStudentNum);
}
