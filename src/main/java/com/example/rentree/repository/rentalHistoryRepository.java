package com.example.rentree.repository;

import com.example.rentree.domain.RentalHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository  // ✅ 필수 어노테이션
public interface rentalHistoryRepository extends JpaRepository<RentalHistory, Long> {

    // 저장
    RentalHistory save(RentalHistory rentalHistory);
}
