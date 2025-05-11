package com.example.rentree.repository;

import com.example.rentree.domain.RentalChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RentalChatRoomRepository extends JpaRepository<RentalChatRoom, Long> {

    // 특정 요청자와 대여 아이템 기준으로 채팅방 존재 여부 확인
    Optional<RentalChatRoom> findByRequester_IdAndRentalItem_Id(Long requesterId, Long rentalItemId);

    List<RentalChatRoom> findByRequester_StudentNumOrResponder_StudentNum(String requester, String responder);

    boolean existsByRequester_IdAndRentalItem_Id(Long requesterId, Long rentalItemId);

    Optional<RentalChatRoom> findByRequester_IdAndRentalItem_IdOrResponder_IdAndRentalItem_Id(Long requesterId, Long rentalItemId, Long responderId, Long rentalItemId2);

    @Modifying
    @Query("UPDATE RentalChatRoom c SET c.rentalItem = NULL WHERE c.rentalItem.id = :rentalItemId")
    void updateRentalItemIdToNull(@Param("rentalItemId") Long rentalItemId);


    @Query("SELECT c FROM RentalChatRoom c WHERE c.rentalItem.id = :rentalItemId")
    Optional<RentalChatRoom> findByRentalItemId(@Param("rentalItemId") Long rentalItemId);

    Optional<RentalChatRoom> findByRequester_Id(long id);
}
