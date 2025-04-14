package com.example.rentree.repository;

import com.example.rentree.domain.RentalItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RentalItemRepository extends JpaRepository<RentalItem, Long> {

    List<RentalItem> findByTitleContaining(String keyword);

    List<RentalItem> findByStudent_StudentNum(String studentNum);

    List<RentalItem> findByIsAvailableTrue(); // 대여 가능한 물품만

    // 카테고리 ID로 대여 가능한 물품 조회
    List<RentalItem> findByCategory_IdAndIsAvailableTrue(Long categoryId);

    void deleteById(Long id);
}