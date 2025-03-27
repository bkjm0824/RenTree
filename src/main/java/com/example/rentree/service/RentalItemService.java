package com.example.rentree.service;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
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
    public Optional<RentalItem> getRentalItemByTitle(String title) {
        return rentalItemRepository.findByTitle(title);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getRentalItemsByStudentId(String studentId) {
        return rentalItemRepository.findByStudentId(studentId);
    }
}
