package com.example.rentree.dto;

import com.example.rentree.domain.Student;
import lombok.Data;

@Data // getter, setter, toString, equals, hashCode 메서드 자동 생성
public class StudentDTO {
    private int id; // 학생 식별자
    private String studentNum; // 학번
    private String password; // 비밀번호
    private String nickname; // 닉네임

    static public StudentDTO fromEntity(Student student) {
        StudentDTO studentDTO = new StudentDTO(); // StudentDTO 객체 생성
        studentDTO.setId(student.getId()); // Student 객체의 id 값을 DTO에 설정
        studentDTO.setStudentNum(student.getStudentNum()); // Student 객체의 studentNum 값을 DTO에 설정
        studentDTO.setPassword(student.getPassword()); // Student 객체의 password 값을 DTO에 설정
        studentDTO.setNickname(student.getNickname()); // Student 객체의 nickname 값을 DTO에 설정
        return studentDTO; // StudentDTO 객체 반환
    }
}