package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "rental_chat_room")
public class RentalChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rental_item_id", nullable = false)
    private RentalItem rentalItem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private Student requester;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "responder_id", nullable = false)
    private Student responder;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // 추가된 퇴장 여부 필드
    @Column(nullable = false)
    private boolean requesterExited = false;

    @Column(nullable = false)
    private boolean responderExited = false;

    public List<Student> getParticipants() {
        return List.of(requester, responder);
    }
}
