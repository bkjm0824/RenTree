package com.example.rentree.repository;

import com.example.rentree.domain.RequestHistory;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository  // ✅ 필수 어노테이션
public interface RequestHistoryRepository extends JpaRepository<RequestHistory, Long> {

    // 저장
    RequestHistory save(RequestHistory requestHistory);

    List<RequestHistory> findByRequester(Student requester);
    List<RequestHistory> findByResponder(Student responder);
}
