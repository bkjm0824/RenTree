package com.example.rentree.repository;

import com.example.rentree.domain.RentalHistory;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository  // ✅ 필수 어노테이션
public interface RentalHistoryRepository extends JpaRepository<RentalHistory, Long> {

    // 저장
    RentalHistory save(RentalHistory rentalHistory);

    List<RentalHistory> findByRequester(Student requester);
    List<RentalHistory> findByResponder(Student responder);
}
