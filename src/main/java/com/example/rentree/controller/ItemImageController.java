package com.example.rentree.controller;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.service.ItemImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/images/api")
@RequiredArgsConstructor
public class ItemImageController {

    private final ItemImageService itemImageService;

    // 이미지 업로드
    @PostMapping
    public ResponseEntity<String> uploadImage(
            @RequestParam("rentalItemId") Long rentalItemId,
            @RequestParam("image") MultipartFile imageFile
    ) {
        String imageUrl = itemImageService.saveImage(rentalItemId, imageFile);
        return ResponseEntity.ok("Image saved at URL: " + imageUrl);
    }

    // 특정 아이템의 이미지 조회
    @GetMapping("/item/{rentalItemId}")
    public ResponseEntity<List<ItemImage>> getImages(@PathVariable Long rentalItemId) {
        List<ItemImage> images = itemImageService.getImagesByRentalItemId(rentalItemId);
        return ResponseEntity.ok(images);
    }

    // 이미지 삭제
    @DeleteMapping("/{imageId}")
    public ResponseEntity<String> deleteImage(@PathVariable Long imageId) {
        itemImageService.deleteImage(imageId);
        return ResponseEntity.ok("Image deleted");
    }
}
