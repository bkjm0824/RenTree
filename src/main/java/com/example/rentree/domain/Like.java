package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "Likes",
        uniqueConstraints = @UniqueConstraint(columnNames = {"student_num", "rental_item_id"})) // 데이터베이스의 Item_Request 테이블과 매핑
public class Like {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "student_num", referencedColumnName = "student_num", nullable = false)
    private Student student;

    @ManyToOne
    @JoinColumn(name = "rental_item_id")
    private RentalItem rentalItem;

    public Like(Student student, RentalItem rentalItem) {
        this.student = student;
        this.rentalItem = rentalItem;
    }
}
