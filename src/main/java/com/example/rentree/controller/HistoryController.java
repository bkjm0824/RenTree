package com.example.rentree.controller;

import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalHistoryDTO;
import com.example.rentree.dto.RequestHistoryDTO;
import com.example.rentree.service.HistoryService;
import com.example.rentree.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/history")
@RequiredArgsConstructor
public class HistoryController {

    private final HistoryService historyService;
    private final StudentService studentService;

    // 내가 대여한 내역
    @GetMapping("/rentals/my")
    public List<RentalHistoryDTO> getMyRentals(@RequestParam String studentNum) {
        Student student = studentService.getStudentByStudentNum(studentNum).toEntity();
        return historyService.getMyRentals(student);
    }

    // 내가 대여해준 내역
    @GetMapping("/rentals/given")
    public List<RentalHistoryDTO> getRentalsIGave(@RequestParam String studentNum) {
        Student student = studentService.getStudentByStudentNum(studentNum).toEntity();
        return historyService.getRentalsIGave(student);
    }

    // 내가 요청한 내역
    @GetMapping("/requests/my")
    public List<RequestHistoryDTO> getMyRequestHistories(@RequestParam String studentNum) {
        Student student = studentService.getStudentByStudentNum(studentNum).toEntity();
        return historyService.getMyRequestHistories(student);
    }

    // 내가 응답한 요청 내역
    @GetMapping("/requests/got")
    public List<RequestHistoryDTO> getRequestsIGot(@RequestParam String studentNum) {
        Student student = studentService.getStudentByStudentNum(studentNum).toEntity();
        return historyService.getRequestsIGot(student);
    }
}
