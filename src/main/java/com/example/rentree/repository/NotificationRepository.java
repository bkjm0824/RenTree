package com.example.rentree.repository;

import com.example.rentree.domain.Notification;
import com.example.rentree.domain.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // 특정 학생의 알림 목록 조회
    List<Notification> findByUser(Student user);

    // 읽지 않은 알림만 조회
    List<Notification> findByUserAndIsReadFalse(Student user);
}
