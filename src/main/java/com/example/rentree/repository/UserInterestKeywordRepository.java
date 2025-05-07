package com.example.rentree.repository;

import com.example.rentree.domain.UserInterestKeyword;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserInterestKeywordRepository extends JpaRepository<UserInterestKeyword, Long> {

    // 특정 학생의 관심 키워드 조회
    List<UserInterestKeyword> findByStudent(Student student);
}
