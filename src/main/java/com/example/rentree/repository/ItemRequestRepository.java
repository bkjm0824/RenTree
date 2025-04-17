package com.example.rentree.repository;

import com.example.rentree.domain.ItemRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/*
게시글 정보를 관리하는 레포지토리 인터페이스
리포지토리 인터페이스는 데이터베이스와의 상호작용을 담당
 */

public interface ItemRequestRepository extends JpaRepository<ItemRequest, Long> {

    // 전체 게시글 가져오기 (createdAt이 최신순인 순서로 정렬)
    List<ItemRequest> findAll(Sort sort);  // Sort를 파라미터로 받아 정렬된 데이터를 반환

    // 학번으로 게시글 가져오기
    List<ItemRequest> findByStudent_StudentNum(String studentNum);

    // 제목에 맞게 게시글 가져오기
    List<ItemRequest> findByTitleContaining(String keyword);

}
