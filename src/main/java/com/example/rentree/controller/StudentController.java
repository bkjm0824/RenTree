package com.example.rentree.controller;

import com.example.rentree.dto.StudentDTO;
import com.example.rentree.domain.Student;
import com.example.rentree.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.NoSuchAlgorithmException;

@RestController // RESTful 서비스임을 명시
@RequestMapping("/Rentree") // 이 컨트롤러의 모든 엔드포인트는 /Rentree로 시작
public class StudentController {

    @Autowired // Spring의 의존성 주입으로 StudentService 객체 주입
    private StudentService studentService;

    @PostMapping(value = "/login", produces = "application/json; charset=UTF-8") // '/Rentree/login' POST 요청 처리, JSON 응답에 UTF-8 인코딩
    public ResponseEntity<?> login(@RequestBody StudentDTO studentDTO) throws NoSuchAlgorithmException { // @RequestBody: HTTP 요청 본문의 JSON을 StudentDTO 객체로 변환 // NoSuchAlgorithmException는 SHA-256 암호화 알고리즘이 없을 경우 발생하는 예외
        // ResponseEntity<?> - 타입을 지정하지 않고 모든 타입을 받을 수 있도록 함 (성공 시 StudentDTO, 실패 시 String)
        // ResponseEntity 사용 이유는 HTTP 상태 코드와 함께 응답을 보내기 위함 (응답 코드, 헤더, 본문 등을 직접 설정 가능)
        Student student = studentService.authenticate(studentDTO.getStudentNum(), studentDTO.getPassword()); // StudentService를 통해 로그인 시도
        if (student != null) { // 로그인 성공 시
            StudentDTO responseStudentDTO = StudentDTO.fromEntity(student); // Student 객체를 StudentDTO 객체로 변환
            return ResponseEntity.ok(responseStudentDTO); // 로그인 성공 응답 (200 OK)
        } else { // 로그인 실패 시
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials"); // 로그인 실패 응답 (401 Unauthorized)
        }
    }

    @GetMapping("/{studentNum}") // '/Rentree/{studentNum}' GET 요청 처리 (경로 변수 사용)
    public ResponseEntity<StudentDTO> getStudentById(@PathVariable String studentNum) { // @PathVariable: 경로 변수 {studentNum} 를 메서드 파라미터로 전달 @PathVariable 애너테이션은 URL 경로에 있는 변수를 메서드 파라미터로 전달받을 때 사용
        // 학번으로 학생 정보 가져오기
        StudentDTO studentDTO = studentService.getStudentByStudentNum(studentNum);
        if (studentDTO != null) { // 학생 정보가 존재할 경우
            // 학생 정보 반환
            return ResponseEntity.ok(studentDTO); // 200 OK
        } else {
            return ResponseEntity.notFound().build(); // 404 Not Found
        }
    }
}