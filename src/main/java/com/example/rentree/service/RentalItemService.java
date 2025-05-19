package com.example.rentree.service;

import com.example.rentree.domain.Category;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.repository.*;
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
    private final LikeRepository likeRepository;
    private final ItemImageService itemImageService;
    private final ItemImageRepository itemImageRepository;
    private final NotificationService notificationService;
    private final RentalChatRoomRepository rentalChatRoomRepository;
    private final RentalHistoryRepository rentalHistoryRepository;

    public RentalItemService(RentalItemRepository rentalItemRepository, CategoryRepository categoryRepository, StudentRepository studentRepository, LikeRepository likeRepository, ItemImageService itemImageService, ItemImageRepository itemImageRepository, NotificationService notificationService, RentalChatRoomRepository rentalChatRoomRepository, RentalHistoryRepository rentalHistoryRepository) {
        this.rentalItemRepository = rentalItemRepository;
        this.categoryRepository = categoryRepository;
        this.studentRepository = studentRepository;
        this.likeRepository = likeRepository;
        this.itemImageService = itemImageService;
        this.itemImageRepository = itemImageRepository;
        this.notificationService = notificationService;
        this.rentalChatRoomRepository = rentalChatRoomRepository;
        this.rentalHistoryRepository = rentalHistoryRepository;
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getAllRentalItemsSorted(Sort sort) {
        return rentalItemRepository.findAll(sort); // 페이징 없이 전체 데이터 정렬된 리스트 반환
    }

    // LikeController
    @Transactional(readOnly = true)
    public RentalItem getRentalItemById(Long id) {
        return rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 렌탈 아이템을 찾을 수 없습니다: " + id));
    }

    @Transactional
    public RentalItem saveRentalItem(RentalItemCreateRequest request) {
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
                request.getRentalEndTime(),
                request.getPassword()
        );

        RentalItem saved = rentalItemRepository.save(item);

        // 자동 알림 생성
        notificationService.createNotificationsForMatchingKeywords(request.getTitle() + " " + request.getDescription());

        return saved;
    }


    @Transactional(readOnly = true)
    public List<RentalItem> searchRentalItemsByTitle(String keyword) {
        return rentalItemRepository.findByTitleContaining(keyword);
    }

    @Transactional(readOnly = true)
    public List<RentalItem> getRentalItemsByStudentNum(String studentNum) {
        return rentalItemRepository.findByStudent_StudentNum(studentNum);
    }

    @Transactional
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
        rentalItem.setRentalStartTime(request.getRentalStartTime());
        rentalItem.setRentalEndTime(request.getRentalEndTime());
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
                .orElseThrow(() -> new RuntimeException("해당 ID의 물품을 찾을 수 없습니다: " + id));

        rentalChatRoomRepository.updateRentalItemIdToNull(id);

        rentalHistoryRepository.updateRentalItemIdToNull(id);

        likeRepository.deleteByRentalItem(rentalItem);

        itemImageRepository.deleteByRentalItemId(id);

        rentalItemRepository.delete(rentalItem);
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

    @Transactional
    public String generatePassword(Long id, String password) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Item with ID " + id + " not found"));

        rentalItem.setPassword(password);

        rentalItemRepository.save(rentalItem);

        return password; // 비밀번호 반환
    }

    public String getPassword(Long id) {
        RentalItem rentalItem = rentalItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Item with ID " + id + " not found"));

        return rentalItem.getPassword();
    }
}
