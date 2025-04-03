package com.example.rentree.service;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.repository.RentalItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class RentalItemService {

    private final RentalItemRepository rentalItemRepository;

    public RentalItemService(RentalItemRepository rentalItemRepository) {
        this.rentalItemRepository = rentalItemRepository;
    }

    @Transactional
    public void saveRentalItem(RentalItemCreateRequest request) {
        RentalItem rentalItem = new RentalItem(
                request.getStudentId(),
                request.getTitle(),
                request.getDescription(),
                request.getIsFaceToFace(),
                request.getPhotoUrl(),
                request.getRentalDate(),
                request.getCategoryId(),
                request.getRentalStartTime(),
                request.getRentalEndTime()
        );
        rentalItemRepository.save(rentalItem);
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

        // 수정 가능한 필드들 업데이트 (널이 아닐 경우에만 변경)
        if (request.getTitle() != null) rentalItem.setTitle(request.getTitle());
        if (request.getDescription() != null) rentalItem.setDescription(request.getDescription());
        if (request.getIsFaceToFace() != null) rentalItem.setIsFaceToFace(request.getIsFaceToFace());
        if (request.getPhotoUrl() != null) rentalItem.setPhotoUrl(request.getPhotoUrl());
        if (request.getRentalDate() != null) rentalItem.setRentalDate(request.getRentalDate());
        if (request.getCategoryId() != null) rentalItem.setCategoryId(request.getCategoryId());
        if (request.getRentalStartTime() != null) rentalItem.setRentalStartTime(request.getRentalStartTime());
        if (request.getRentalEndTime() != null) rentalItem.setRentalEndTime(request.getRentalEndTime());

        rentalItemRepository.save(rentalItem);
    }

    @Transactional
    public void deleteRentalItem(Long id) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 물품을 찾을 수 없습니다: " + id));
        rentalItemRepository.deleteById(id);
    }

}
