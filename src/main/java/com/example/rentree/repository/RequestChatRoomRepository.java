package com.example.rentree.repository;

import com.example.rentree.domain.RequestChatRoom;
import org.apache.coyote.Request;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.security.core.parameters.P;

import javax.swing.text.html.Option;
import java.util.List;
import java.util.Optional;

public interface RequestChatRoomRepository extends JpaRepository<RequestChatRoom, Long> {

    // 특정 요청자와 요청글 기준으로 채팅방 존재 여부 확인
    Optional<RequestChatRoom> findByRequester_IdAndItemRequest_Id(Long requesterId, Long itemRequestId);

    // 학생 번호로 관련된 모든 채팅방 가져오기
    List<RequestChatRoom> findByRequester_StudentNumOrResponder_StudentNum(String requester, String responder);

    // 채팅방 존재 여부
    boolean existsByRequester_IdAndItemRequest_Id(Long requesterId, Long itemRequestId);

    // 아이템 요청 ID와 참여자 ID로 채팅방 찾기
    @Query("SELECT c FROM RequestChatRoom c " +
            "WHERE (c.requester.studentNum = :studentNum OR c.responder.studentNum = :studentNum) " +
            "AND c.itemRequest.id = :itemRequestId")
    Optional<RequestChatRoom> findByParticipantStudentNumAndItemRequestId(@Param("studentNum") String studentNum,
                                                                          @Param("itemRequestId") Long itemRequestId);

    @Query("SELECT c FROM RequestChatRoom c WHERE c.itemRequest.id = :itemRequestId")
    Optional<RequestChatRoom> findByItemRequestId(@Param("itemRequestId") Long itemRequestId);

    // 요청 아이템 null 처리 (예: 삭제 시)
    @Modifying
    @Query("UPDATE RequestChatRoom c SET c.itemRequest = NULL WHERE c.itemRequest.id = :itemRequestId")
    void updateItemRequestIdToNull(@Param("itemRequestId") Long itemRequestId);

    // 요청 아이템 기준 채팅방 조회
    @Query("SELECT c FROM RequestChatRoom c WHERE c.itemRequest.id = :itemRequestId")
    Optional<RequestChatRoom> findByRequestItemId(@Param("itemRequestId") Long itemRequestId);

    // 요청 아이템 ID와 채팅방 ID로 조회
    Optional<RequestChatRoom> findByItemRequestIdAndId(Long itemId, Long chatRoomId);

    // ID와 학생 번호로 채팅방 존재 확인
    @Query("SELECT c FROM RequestChatRoom c " +
            "WHERE c.id = :chatRoomId AND (c.requester.studentNum = :studentNum OR c.responder.studentNum = :studentNum)")
    Optional<RequestChatRoom> findByIdAndParticipant(@Param("chatRoomId") Long chatRoomId,
                                                     @Param("studentNum") String studentNum);
}
