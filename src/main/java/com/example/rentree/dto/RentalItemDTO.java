package com.example.rentree.dto;

import com.example.rentree.domain.RentalItem;
import lombok.Data;

import java.sql.Timestamp;
import java.time.LocalDateTime;

@Data
public class RentalItemDTO {

    private Long id;
    private String studentNum;
    private String nickname;
    private String title;
    private String description;
    private Boolean isFaceToFace;
    private Timestamp createdAt;
    private Integer viewCount;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;
    private Long categoryId;
    private String categoryName;
    private Boolean isAvailable;
    private Integer profileImage;
    private String password;
    private LocalDateTime actualReturnTime;

    public static RentalItemDTO fromEntity(RentalItem item) {
        RentalItemDTO dto = new RentalItemDTO();
        dto.setId(item.getId());
        dto.setStudentNum(item.getStudent().getStudentNum());
        dto.setNickname(item.getStudent().getNickname());
        dto.setProfileImage(item.getStudent().getProfileImage());
        dto.setTitle(item.getTitle());
        dto.setDescription(item.getDescription());
        dto.setIsFaceToFace(item.getIsFaceToFace());
        dto.setCreatedAt(item.getCreatedAt());
        dto.setViewCount(item.getViewCount());
        dto.setRentalStartTime(item.getRentalStartTime());
        dto.setRentalEndTime(item.getRentalEndTime());
        if (item.getCategory() != null) {
            dto.setCategoryId(item.getCategory().getId());
            dto.setCategoryName(item.getCategory().getName());
        }
        dto.setIsAvailable(item.getIsAvailable());
        dto.setPassword(item.getPassword());
        dto.setActualReturnTime(item.getActualReturnTime());
        return dto;
    }
}
