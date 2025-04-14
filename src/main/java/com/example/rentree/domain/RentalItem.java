package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
public class RentalItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // studentNum을 외래키로 연결
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_num", referencedColumnName = "student_num", nullable = false)
    private Student student;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Boolean isFaceToFace;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Timestamp createdAt;

    @Column(nullable = false)
    private Integer viewCount = 0;

    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(nullable = false)
    private Boolean isAvailable = true;

    protected RentalItem() {}

    public RentalItem(Student student, String title, String description, Boolean isFaceToFace,
                      Timestamp createdAt, Category category,
                      LocalDateTime rentalStartTime, LocalDateTime rentalEndTime) {
        this.student = student;
        this.title = title;
        this.description = description;
        this.isFaceToFace = isFaceToFace;
        this.createdAt = createdAt;
        this.category = category;
        this.rentalStartTime = rentalStartTime;
        this.rentalEndTime = rentalEndTime;
    }

    public void incrementViewCount() {
        this.viewCount++;
    }

    public void markAsRented() {
        this.isAvailable = false;
    }

    public void markAsAvailable() {
        this.isAvailable = true;
    }

}
