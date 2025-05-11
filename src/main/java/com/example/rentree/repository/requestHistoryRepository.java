package com.example.rentree.repository;

import com.example.rentree.domain.RequestHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository  // ✅ 필수 어노테이션
public interface requestHistoryRepository extends JpaRepository<RequestHistory, Long> {

    // 저장
    RequestHistory save(RequestHistory requestHistory);
}
