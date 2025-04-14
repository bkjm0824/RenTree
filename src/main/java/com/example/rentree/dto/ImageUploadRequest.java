package com.example.rentree.dto;

import lombok.Data;

// DTO 클래스 추가
@Data
public class ImageUploadRequest {
    private Long rentalItemId;
    private String imageUrl;
}

