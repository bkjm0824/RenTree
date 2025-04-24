package com.example.rentree.service;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.dto.ImageUploadRequest;
import com.example.rentree.repository.ItemImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ItemImageService {

    private final ItemImageRepository itemImageRepository;

    private final String uploadDir = "C:/rentree_upload"; // 저장 폴더

    public String saveImage(Long rentalItemId, MultipartFile imageFile) {
        try {
            // 저장 폴더 없으면 생성
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            // 고유 파일명 생성
            String originalFilename = imageFile.getOriginalFilename();
            String fileName = UUID.randomUUID() + "_" + originalFilename;
            String filePath = uploadDir + "/" + fileName;

            // 실제 파일 저장
            imageFile.transferTo(new File(filePath));

            // URL 저장 (예: /images/파일명 또는 정적 리소스 URL)
            String imageUrl = "/images/" + fileName;

            ItemImage image = ItemImage.builder()
                    .rentalItemId(rentalItemId)
                    .imageUrl(imageUrl)
                    .build();

            itemImageRepository.save(image);

            return imageUrl;

        } catch (IOException e) {
            throw new RuntimeException("이미지 저장 실패", e);
        }
    }

    public List<ItemImage> getImagesByRentalItemId(Long rentalItemId) {
        return itemImageRepository.findByRentalItemId(rentalItemId);
    }

    public void deleteImage(Long id) {
        ItemImage image = itemImageRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("이미지 없음"));

        // 실제 파일 삭제
        String filePath = uploadDir + "/" + new File(image.getImageUrl()).getName();
        new File(filePath).delete();

        itemImageRepository.deleteById(id);
    }
}
