package com.example.rentree.controller;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.service.RentalItemService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/rental-item")
public class RentalItemController {

    private final RentalItemService rentalItemService;

    public RentalItemController(RentalItemService rentalItemService) {
        this.rentalItemService = rentalItemService;
    }

    @PostMapping //물품 등록
    public void saveRentalItem(@RequestBody RentalItemCreateRequest request) {
        rentalItemService.saveRentalItem(request);
    }

    @GetMapping("/search") //물품 검색
    public List<RentalItem> searchRentalItemsByTitle(@RequestParam String keyword) {
        return rentalItemService.searchRentalItemsByTitle(keyword);
    }

    @GetMapping("/student/{studentNum}") //학번을 통해 목록 보기
    public List<RentalItem> getRentalItemsByStudentNum(@PathVariable String studentNum) {
        return rentalItemService.getRentalItemsByStudentNum(studentNum);
    }

    @GetMapping("/{id}") // 상세 페이지
    public RentalItem getRentalItemDetails(@PathVariable Long id) {
        return rentalItemService.getRentalItemDetails(id);
    }

    @PutMapping("/{id}") //물품 수정
    public void updateRentalItem(@PathVariable Long id, @RequestBody RentalItemUpdateRequest request) {
        rentalItemService.updateRentalItem(id, request);
    }

    @DeleteMapping("/{id}") //물품 삭제
    public void deleteRentalItem(@PathVariable Long id) {
        rentalItemService.deleteRentalItem(id);
    }

    // 대여 가능한 물품 리스트 조회
    @GetMapping("/available")
    public ResponseEntity<List<RentalItem>> getAvailableItems() {
        return ResponseEntity.ok(rentalItemService.getAvailableItems());
    }

    // 대여 완료 처리
    @PatchMapping("/{id}/rent")
    public ResponseEntity<String> markAsRented(@PathVariable Long id) {
        rentalItemService.markAsRented(id);
        return ResponseEntity.ok("물품 대여 완료 처리됨");
    }

    // 다시 대여 가능하게 변경
    @PatchMapping("/{id}/return")
    public ResponseEntity<String> markAsAvailable(@PathVariable Long id) {
        rentalItemService.markAsAvailable(id);
        return ResponseEntity.ok("물품을 다시 대여 가능 상태로 변경");
    }

    // 특정 카테고리의 대여 가능한 물품 목록 조회
    @GetMapping("/available/category/{categoryId}")
    public ResponseEntity<List<RentalItem>> getAvailableItemsByCategory(@PathVariable Long categoryId) {
        return ResponseEntity.ok(rentalItemService.getAvailableItemsByCategory(categoryId));
    }
}
