package com.example.rentree.service;

import com.example.rentree.domain.Category;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.repository.CategoryRepository;
import com.example.rentree.repository.RentalItemRepository;
import com.example.rentree.repository.StudentRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class RentalItemService {

    private final RentalItemRepository rentalItemRepository;
    private final CategoryRepository categoryRepository;
    private final StudentRepository studentRepository;

    public RentalItemService(RentalItemRepository rentalItemRepository, CategoryRepository categoryRepository, StudentRepository studentRepository) {
        this.rentalItemRepository = rentalItemRepository;
        this.categoryRepository = categoryRepository;
        this.studentRepository = studentRepository;
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getAllRentalItemsSorted(Sort sort) {
        return rentalItemRepository.findAll(sort); // 페이징 없이 전체 데이터 정렬된 리스트 반환
    }

    @Transactional
    public void saveRentalItem(RentalItemCreateRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 카테고리 ID입니다."));
        Student student = studentRepository.findByStudentNum(request.getStudentNum())
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다"));


        RentalItem item = new RentalItem(
                student,
                request.getTitle(),
                request.getDescription(),
                request.getIsFaceToFace(),
                request.getCreatedAt(),
                category,
                request.getRentalStartTime(),
                request.getRentalEndTime()
        );

        rentalItemRepository.save(item);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> searchRentalItemsByTitle(String keyword) {
        return rentalItemRepository.findByTitleContaining(keyword);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getRentalItemsByStudentNum(String studentNum) {
        return rentalItemRepository.findByStudent_StudentNum(studentNum);
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
        if (request.getCreatedAt() != null) rentalItem.setCreatedAt(request.getCreatedAt());
        if (request.getRentalStartTime() != null) rentalItem.setRentalStartTime(request.getRentalStartTime());
        if (request.getRentalEndTime() != null) rentalItem.setRentalEndTime(request.getRentalEndTime());

        // 변경된 부분 시작
        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 카테고리 ID입니다."));
            rentalItem.setCategory(category);
        }

        rentalItemRepository.save(rentalItem);
    }


    @Transactional
    public void deleteRentalItem(Long id) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 물품을 찾을 수 없습니다: " + id));
        rentalItemRepository.deleteById(id);
    }

    // 전체 대여 가능한 아이템만 조회
    public List<RentalItem> getAvailableItems() {
        return rentalItemRepository.findByIsAvailableTrue();
    }

    // 특정 아이템을 대여 완료 처리
    @Transactional
    public void markAsRented(Long id) {
        RentalItem item = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 물품이 존재하지 않습니다."));
        item.markAsRented();
    }

    // (선택) 다시 대여 가능하게
    @Transactional
    public void markAsAvailable(Long id) {
        RentalItem item = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 물품이 존재하지 않습니다."));
        item.markAsAvailable();
    }

    // 카테고리별 대여 가능한 아이템 조회
    @Transactional(readOnly = true)
    public List<RentalItem> getAvailableItemsByCategory(Long categoryId) {
        return rentalItemRepository.findByCategory_IdAndIsAvailableTrue(categoryId);
    }
}
