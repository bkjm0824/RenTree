package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "chat_message")
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 메시지가 속한 채팅방
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_room_id", nullable = false)
    private ChatRoom chatRoom;

    // 발신자: studentNum으로 외래키 연결
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_student_num", referencedColumnName = "student_num", nullable = false)
    private Student sender;

    // 메시지 내용
    @Column(columnDefinition = "TEXT", nullable = false)
    private String message;

    // 보낸 시각
    @Builder.Default
    @Column(nullable = false)
    private LocalDateTime sentAt = LocalDateTime.now();
}
