package com.example.rentree.repository;

import com.example.rentree.domain.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    // 채팅방 ID로 채팅방을 조회하는 메서드
    Optional<ChatRoom> findById(Long roomId);

    // 물품 ID로 채팅방을 조회하는 메서드 (물품에 대한 여러 채팅방 조회)
    List<ChatRoom> findByRentalItemId(Long rentalItemId);

    // 채팅방 삭제를 위한 메서드 (이 경우, 기본적으로 JpaRepository의 deleteById를 사용하여 삭제 가능)
}
