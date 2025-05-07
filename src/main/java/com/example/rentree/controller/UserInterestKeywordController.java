package com.example.rentree.controller;

import com.example.rentree.domain.Student;
import com.example.rentree.dto.UserInterestKeywordDto;
import com.example.rentree.repository.StudentRepository;
import com.example.rentree.service.UserInterestKeywordService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/keywords")
public class UserInterestKeywordController {

    private final UserInterestKeywordService keywordService;
    private final StudentRepository studentRepository;

    // 키워드 등록 (studentNum을 직접 파라미터로 받음)
    @PostMapping
    public void addKeyword(
            @RequestParam String studentNum,
            @RequestParam String keyword) {
        Student student = getStudentByStudentNum(studentNum);
        keywordService.addKeyword(student, keyword);
    }

    // 키워드 목록 조회
    @GetMapping
    public List<UserInterestKeywordDto> getKeywords(
            @RequestParam String studentNum) {
        Student student = getStudentByStudentNum(studentNum);
        return keywordService.getKeywordsByStudent(student);
    }

    // 키워드 삭제
    @DeleteMapping("/{id}")
    public void deleteKeyword(@PathVariable Long id) {
        keywordService.deleteKeyword(id);
    }

    // studentNum으로 Student 조회
    private Student getStudentByStudentNum(String studentNum) {
        return studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with studentNum: " + studentNum));
    }
}
