package com.example.rentree.service;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.dto.ImageUploadRequest;
import com.example.rentree.repository.ItemImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ItemImageService {

    private final ItemImageRepository itemImageRepository;

    public void saveImage(ImageUploadRequest request) {
        ItemImage image = ItemImage.builder()
                .rentalItemId(request.getRentalItemId())
                .imageUrl(request.getImageUrl())
                .build();
        itemImageRepository.save(image);
    }

    public List<ItemImage> getImagesByRentalItemId(Long rentalItemId) {
        return itemImageRepository.findByRentalItemId(rentalItemId);
    }

    public void deleteImage(Long id) {
        itemImageRepository.deleteById(id);
    }
}
