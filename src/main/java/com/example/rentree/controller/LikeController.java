package com.example.rentree.controller;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.LikeDTO;
import com.example.rentree.dto.StudentDTO;
import com.example.rentree.repository.StudentRepository;
import com.example.rentree.service.LikeService;
import com.example.rentree.service.RentalItemService;
import com.example.rentree.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/likes")
public class LikeController {

    private final LikeService likeService;
    private final RentalItemService rentalItemService;
    private final StudentService studentService;
    private final StudentRepository studentRepository;

    @Autowired
    public LikeController(LikeService likeService, RentalItemService rentalItemService, StudentService studentService, StudentRepository studentRepository) {
        this.likeService = likeService;
        this.rentalItemService = rentalItemService;
        this.studentService = studentService;
        this.studentRepository = studentRepository;
    }

    // 좋아요 토글
    @PostMapping
    public LikeDTO toggleLike(@RequestParam("studentNum") String studentNum,
                              @RequestParam("rentalItemId") Long rentalItemId) {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new RuntimeException("Student not found"));
        RentalItem rentalItem = rentalItemService.getRentalItemById(rentalItemId);

        return likeService.toggleLike(student, rentalItem);
    }

    // 학번으로 좋아요 목록 조회
    @GetMapping("/student/{studentNum}")
    public ResponseEntity<List<LikeDTO>> getLikesByStudent(@PathVariable String studentNum) {
        List<LikeDTO> likeDTOs = likeService.getLikesByStudent(studentNum);
        return ResponseEntity.ok(likeDTOs);
    }

    // 렌탈 아이템 ID로 좋아요 개수 조회
    @GetMapping("/rentalItem/{rentalItemId}/count")
    public long countLikesByRentalItem(@PathVariable RentalItem rentalItemId) {
        return likeService.countLikesByRentalItem(rentalItemId);
    }
}
