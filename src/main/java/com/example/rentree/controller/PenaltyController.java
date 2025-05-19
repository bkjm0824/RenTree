package com.example.rentree.controller;

import com.example.rentree.domain.Student;
import com.example.rentree.repository.StudentRepository;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/penalties")
@RequiredArgsConstructor
public class PenaltyController {

    private final StudentRepository studentRepository;

    // 특정 학생의 페널티 점수 조회
    @GetMapping("/{studentNum}")
    public PenaltyResponse getPenaltyStatus(@PathVariable String studentNum) {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다."));

        return new PenaltyResponse(student.getPenaltyScore(), student.isBanned());
    }

    // 페널티 점수 수동 증가 (관리자 용도)
    @PostMapping("/{studentNum}/add")
    public PenaltyResponse addPenalty(@PathVariable String studentNum) {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다."));

        student.addPenalty();
        studentRepository.save(student);

        return new PenaltyResponse(student.getPenaltyScore(), student.isBanned());
    }

    // DTO for response
    public static class PenaltyResponse {
        @Getter
        private final int penaltyScore;
        private final boolean isBanned;

        public PenaltyResponse(int penaltyScore, boolean isBanned) {
            this.penaltyScore = penaltyScore;
            this.isBanned = isBanned;
        }

        public boolean isBanned() {
            return isBanned;
        }
    }
}
