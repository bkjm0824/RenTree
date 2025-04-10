package com.example.rentree.dto;

import com.example.rentree.domain.Student;
import lombok.Data;

/*
학생 정보를 담는 DTO 클래스
클라이언트와 서버 간 데이터 교환을 위해 사용
필요한 데이터만 담아 전송
 */

@Data // getter, setter, toString, equals, hashCode 메서드 자동 생성
public class StudentDTO {
    private int id; // 학생 식별자
    private String studentNum; // 학번
    private String password; // 비밀번호
    private String nickname; // 닉네임

    /*
    Student 객체를 StudentDTO 객체로 변환하는 메서드
    @param student : Student 객체
    @return : StudentDTO 객체
     */

    static public StudentDTO fromEntity(Student student) {
        StudentDTO studentDTO = new StudentDTO(); // StudentDTO 객체 생성
        studentDTO.setId(student.getId()); // Student 객체의 id 값을 DTO에 설정
        studentDTO.setStudentNum(student.getStudentNum()); // Student 객체의 studentNum 값을 DTO에 설정
        studentDTO.setPassword(student.getPassword()); // Student 객체의 password 값을 DTO에 설정
        studentDTO.setNickname(student.getNickname()); // Student 객체의 nickname 값을 DTO에 설정
        return studentDTO; // StudentDTO 객체 반환
    }
}