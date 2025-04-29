package com.example.rentree.dto;

import com.example.rentree.domain.Like;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class LikeDTO {

    private Long id;
    private String studentNum;
    private Long rentalItemId;
    private boolean liked;
    private String rentalItemTitle;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;


    public static LikeDTO fromEntity(Like like) {
        return LikeDTO.builder()
                .id(like.getId())
                .studentNum(like.getStudent().getStudentNum())
                .rentalItemId(like.getRentalItem().getId())
                .liked(true)
                .rentalItemTitle(like.getRentalItem().getTitle())
                .rentalStartTime(like.getRentalItem().getRentalStartTime())
                .rentalEndTime(like.getRentalItem().getRentalEndTime())
                .build();
    }
}