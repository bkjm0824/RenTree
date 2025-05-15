package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "request_chat_room")
public class RequestChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_request_id", nullable = false)
    private ItemRequest itemRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private Student requester;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "responder_id", nullable = false)
    private Student responder;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RequestChatMessage> messages = new ArrayList<>();

    // 추가된 퇴장 여부 필드
    @Column(nullable = false)
    private boolean requesterExited = false;

    @Column(nullable = false)
    private boolean responderExited = false;

    public List<Student> getParticipants() {
        return List.of(requester, responder);
    }
}
