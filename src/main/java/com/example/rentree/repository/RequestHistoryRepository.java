package com.example.rentree.repository;

import com.example.rentree.domain.RequestHistory;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository  // ✅ 필수 어노테이션
public interface RequestHistoryRepository extends JpaRepository<RequestHistory, Long> {

    // 저장
    RequestHistory save(RequestHistory requestHistory);

    List<RequestHistory> findByRequester(Student requester);
    List<RequestHistory> findByResponder(Student responder);

    @Modifying
    @Query("UPDATE RequestHistory c SET c.itemRequest = NULL WHERE c.itemRequest.id = :itemRequestId")
    void updateItemRequestIdToNull(@Param("itemRequestId") Long itemRequestId);

}
