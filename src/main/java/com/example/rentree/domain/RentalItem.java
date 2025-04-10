package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
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

    @Column(nullable = false, length = 100)
    private String studentId;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Boolean isFaceToFace;

    private LocalDate rentalDate;

    @Column(nullable = false)
    private Integer viewCount = 0;

    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @OneToMany(mappedBy = "rentalItem", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ItemImage> images = new ArrayList<>();

    protected RentalItem() {}

    public RentalItem(String studentId, String title, String description, Boolean isFaceToFace,
                      LocalDate rentalDate, Category category,
                      LocalDateTime rentalStartTime, LocalDateTime rentalEndTime) {
        this.studentId = studentId;
        this.title = title;
        this.description = description;
        this.isFaceToFace = isFaceToFace;
        this.rentalDate = rentalDate;
        this.category = category;
        this.rentalStartTime = rentalStartTime;
        this.rentalEndTime = rentalEndTime;
    }

    public void incrementViewCount() {
        this.viewCount++;
    }

    public void addImage(String url) {
        ItemImage image = new ItemImage();
        image.setUrl(url);
        image.setRentalItem(this);
        this.images.add(image);
    }
}
