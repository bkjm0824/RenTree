package com.example.rentree.service;

import com.example.rentree.domain.Category;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.repository.CategoryRepository;
import com.example.rentree.repository.RentalItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class RentalItemService {

    private final RentalItemRepository rentalItemRepository;
    private final CategoryRepository categoryRepository;

    public RentalItemService(RentalItemRepository rentalItemRepository,CategoryRepository categoryRepository) {
        this.rentalItemRepository = rentalItemRepository;
        this.categoryRepository = categoryRepository;
    }

    @Transactional
    public void saveRentalItem(RentalItemCreateRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 카테고리 ID입니다."));

        RentalItem item = new RentalItem(
                request.getStudentId(),
                request.getTitle(),
                request.getDescription(),
                request.getIsFaceToFace(),
                request.getRentalDate(),
                category,
                request.getRentalStartTime(),
                request.getRentalEndTime()
        );

        if (request.getPhotoUrls() != null) {
            for (String url : request.getPhotoUrls()) {
                item.addImage(url);
            }
        }

        rentalItemRepository.save(item);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> searchRentalItemsByTitle(String keyword) {
        return rentalItemRepository.findByTitleContaining(keyword);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getRentalItemsByStudentId(String studentId) {
        return rentalItemRepository.findByStudentId(studentId);
    }

    @Transactional(readOnly = true)
    public RentalItem getRentalItemDetails(Long id) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 물품을 찾을 수 없습니다: " + id));
        rentalItem.incrementViewCount(); // 조회수 증가
        rentalItemRepository.save(rentalItem);
        return rentalItem;
    }


    @Transactional
    public void updateRentalItem(Long id, RentalItemUpdateRequest request) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 물품을 찾을 수 없습니다: " + id));

        if (request.getTitle() != null) rentalItem.setTitle(request.getTitle());
        if (request.getDescription() != null) rentalItem.setDescription(request.getDescription());
        if (request.getIsFaceToFace() != null) rentalItem.setIsFaceToFace(request.getIsFaceToFace());
        if (request.getRentalDate() != null) rentalItem.setRentalDate(request.getRentalDate());
        if (request.getRentalStartTime() != null) rentalItem.setRentalStartTime(request.getRentalStartTime());
        if (request.getRentalEndTime() != null) rentalItem.setRentalEndTime(request.getRentalEndTime());

        // 변경된 부분 시작
        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 카테고리 ID입니다."));
            rentalItem.setCategory(category);
        }

        // 이미지 URL 업데이트 (예: 덮어쓰기 방식)
        if (request.getPhotoUrls() != null) {
            rentalItem.getImages().clear(); // 기존 이미지 제거
            for (String url : request.getPhotoUrls()) {
                rentalItem.addImage(url);
            }
        }
        // 변경된 부분 끝

        rentalItemRepository.save(rentalItem);
    }


    @Transactional
    public void deleteRentalItem(Long id) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 물품을 찾을 수 없습니다: " + id));
        rentalItemRepository.deleteById(id);
    }

}
