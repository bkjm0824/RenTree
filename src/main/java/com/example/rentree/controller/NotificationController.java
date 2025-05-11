package com.example.rentree.controller;

import com.example.rentree.domain.Student;
import com.example.rentree.dto.NotificationDto;
import com.example.rentree.service.NotificationService;
import com.example.rentree.repository.StudentRepository;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final StudentRepository studentRepository;

    // 전체 알림 조회
    @GetMapping
    public List<NotificationDto> getAllNotifications(@RequestParam String studentNum) {
        Student student = getStudentByStudentNum(studentNum);
        return notificationService.getAllNotifications(student);
    }

    // 읽지 않은 알림만 조회
    @GetMapping("/unread")
    public List<NotificationDto> getUnreadNotifications(@RequestParam String studentNum) {
        Student student = getStudentByStudentNum(studentNum);
        return notificationService.getUnreadNotifications(student);
    }

    // 알림 읽음 처리
    @PostMapping("/{id}/read")
    public void markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
    }

    // 키워드 기반 자동 알림 생성
    @PostMapping("/auto")
    public void createAutoNotification(@RequestBody AutoNotificationRequest request) {
        notificationService.createNotificationsForMatchingKeywords(request.getMessage());
    }

    // studentNum으로 Student 조회
    private Student getStudentByStudentNum(String studentNum) {
        return studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("Student not found"));
    }

    // DTO 클래스
    @Getter
    @Setter
    public static class AutoNotificationRequest {
        private String message;
    }
}
