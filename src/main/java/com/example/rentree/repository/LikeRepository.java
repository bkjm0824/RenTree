package com.example.rentree.repository;

import com.example.rentree.domain.Like;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {

    // 좋아요 목록
    List<Like> findByStudent_StudentNum(String studentNum);

    // 아이템의 좋아요 개수
    long countByRentalItem(RentalItem rentalItem);

    // 학생과 아이템에 대한 좋아요 조회
    Optional<Like> findByStudentAndRentalItem(Student studentNum, RentalItem rentalItemId);

    // 삭제
    void deleteByRentalItem(RentalItem rentalItem);
}
