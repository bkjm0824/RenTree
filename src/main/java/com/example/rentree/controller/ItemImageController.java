package com.example.rentree.controller;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.dto.ImageUploadRequest;
import com.example.rentree.service.ItemImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/images")
@RequiredArgsConstructor
public class ItemImageController {

    private final ItemImageService itemImageService;

    @PostMapping
    public ResponseEntity<String> uploadImage(@RequestBody ImageUploadRequest request) {
        itemImageService.saveImage(request);
        return ResponseEntity.ok("Image saved");
    }

    @GetMapping("/{rentalItemId}")
    public ResponseEntity<List<ItemImage>> getImages(@PathVariable Long rentalItemId) {
        List<ItemImage> images = itemImageService.getImagesByRentalItemId(rentalItemId);
        return ResponseEntity.ok(images);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteImage(@PathVariable Long id) {
        itemImageService.deleteImage(id);
        return ResponseEntity.ok("Image deleted");
    }

}
