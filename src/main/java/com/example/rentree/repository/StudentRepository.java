package com.example.rentree.repository;

import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/*
Student 엔티티를 관리하는 레포지토리
JpaRepository를 상속받아 CRUD 메서드를 사용할 수 있음
Student 엔티티와 데이터베이스 간 상호작용을 담당하는 레포지토리
 */

public interface StudentRepository extends JpaRepository<Student, Integer> {
    //public Optional<Student> findById(int id); // id로 학생 정보 가져오기

    /*
    학번으로 학생 정보 가져오기
    @param studentNum : 학번
    @return : 학생 정보
    Optional<Student>를 반환하여 null 체크를 할 수 있음
     */
    public Optional<Student> findByStudentNum(String studentNum); // 학번으로 학생 정보 가져오기
}