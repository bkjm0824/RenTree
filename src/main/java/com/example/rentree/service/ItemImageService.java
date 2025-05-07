package com.example.rentree.service;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.repository.ItemImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ItemImageService {

    private final ItemImageRepository itemImageRepository;
    private final S3Client s3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public String saveImage(Long rentalItemId, MultipartFile imageFile) {
        try {
            String originalFilename = imageFile.getOriginalFilename();
            String fileName = UUID.randomUUID() + "_" + originalFilename;

            // S3에 업로드
            s3Client.putObject(
                    PutObjectRequest.builder()
                            .bucket(bucket)
                            .key(fileName)
                            .acl(ObjectCannedACL.PUBLIC_READ) // 공개 URL 허용
                            .build(),
                    RequestBody.fromInputStream(imageFile.getInputStream(), imageFile.getSize())
            );

            String imageUrl = "https://" + bucket + ".s3.amazonaws.com/" + fileName;

            // DB 저장
            ItemImage image = ItemImage.builder()
                    .rentalItemId(rentalItemId)
                    .imageUrl(imageUrl)
                    .build();
            itemImageRepository.save(image);

            return imageUrl;
        } catch (IOException e) {
            throw new RuntimeException("S3 업로드 실패", e);
        }
    }

    public List<ItemImage> getImagesByRentalItemId(Long rentalItemId) {
        return itemImageRepository.findByRentalItemId(rentalItemId);
    }

    public void deleteImage(Long id) {
        ItemImage image = itemImageRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("이미지 없음"));

        String fileName = new File(image.getImageUrl()).getName();

        // S3에서 삭제
        s3Client.deleteObject(builder -> builder.bucket(bucket).key(fileName));

        itemImageRepository.deleteById(id);
    }
}
