package com.example.rentree.repository;

import com.example.rentree.domain.ItemRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/*
ItemRequest 엔티티를 관리하는 레포지토리
JpaRepository를 상속받아 CRUD 메서드를 사용할 수 있음
ItemRequest 엔티티와 데이터베이스 간 상호작용을 담당하는 레포지토리
 */

public interface ItemRequestRepository extends JpaRepository<ItemRequest, Long> {

    // 글 등록하기
    // public ItemRequest save(ItemRequest itemRequest);

    // 학번으로 게시글 가져오기
    List<ItemRequest> findByStudentId(int studentId);

    // 제목에 맞게 게시글 가져오기
    List<ItemRequest> findByTitleContaining(String keyword);

    // 제목으로 게시글 가져오기 (사용X)
    //Optional<ItemRequest> findByTitle(String Title);

}
