package com.example.rentree.controller;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.service.RentalItemService;
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

    @GetMapping("/student/{studentId}") //학번을 통해 목록 보기
    public List<RentalItem> getRentalItemsByStudentId(@PathVariable String studentId) {
        return rentalItemService.getRentalItemsByStudentId(studentId);
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

}
