package com.example.rentree.service;

import com.example.rentree.domain.Notification;
import com.example.rentree.domain.Student;
import com.example.rentree.domain.UserInterestKeyword;
import com.example.rentree.dto.NotificationDto;
import com.example.rentree.repository.NotificationRepository;
import com.example.rentree.repository.UserInterestKeywordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserInterestKeywordRepository keywordRepository;

    // 알림 전체 조회
    public List<NotificationDto> getAllNotifications(Student student) {
        List<Notification> notifications = notificationRepository.findByUser(student);

        return notifications.stream().map(this::toDto).collect(Collectors.toList());
    }

    // 읽지 않은 알림만 조회
    public List<NotificationDto> getUnreadNotifications(Student student) {
        return notificationRepository.findByUserAndIsReadFalse(student)
                .stream().map(this::toDto).collect(Collectors.toList());
    }

    // 알림 읽음 처리
    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("알림이 존재하지 않습니다."));
        notification.setRead(true);
        notificationRepository.save(notification);
    }

    // 자동 알림 생성 (메시지에 관심 키워드가 포함된 사용자에게 알림 생성)
    public void createNotificationsForMatchingKeywords(String message) {
        List<UserInterestKeyword> allKeywords = keywordRepository.findAll();

        // 학번별로 중복 생성 방지
        Set<String> notifiedStudentNums = new HashSet<>();

        for (UserInterestKeyword keyword : allKeywords) {
            String keywordStr = keyword.getKeyword();
            Student student = keyword.getStudent();

            if (!notifiedStudentNums.contains(student.getStudentNum()) &&
                    message.toLowerCase().contains(keywordStr.toLowerCase())) {

                Notification notification = new Notification();
                notification.setUser(student);
                notification.setMessage(message);
                notification.setRead(false);

                notificationRepository.save(notification);
                notifiedStudentNums.add(student.getStudentNum());
            }
        }
    }

    // DTO 변환
    private NotificationDto toDto(Notification n) {
        NotificationDto dto = new NotificationDto();
        dto.setId(n.getId());
        dto.setMessage(n.getMessage());
        dto.setRead(n.isRead());
        return dto;
    }
}
