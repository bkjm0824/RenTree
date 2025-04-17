package com.example.rentree.repository;

import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RentalItem;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RentalItemRepository extends JpaRepository<RentalItem, Long> {

    // 전체 게시글 가져오기 (createdAt이 최신순인 순서로 정렬)
    List<RentalItem> findAll(Sort sort);  // Sort를 파라미터로 받아 정렬된 데이터를 반환

    List<RentalItem> findByTitleContaining(String keyword);

    List<RentalItem> findByStudent_StudentNum(String studentNum);

    List<RentalItem> findByIsAvailableTrue(); // 대여 가능한 물품만

    // 카테고리 ID로 대여 가능한 물품 조회
    List<RentalItem> findByCategory_IdAndIsAvailableTrue(Long categoryId);

    void deleteById(Long id);
}