package com.example.rentree.repository;

import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {

    Optional<Student> findByStudentNum(String studentNum); // 학번으로 학생 정보 가져오기

}