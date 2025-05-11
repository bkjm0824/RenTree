package com.example.rentree.controller;

import com.example.rentree.domain.*;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.dto.RentalItemUpdateRequest;
import com.example.rentree.repository.*;
import com.example.rentree.service.ItemRequestService;
import com.example.rentree.service.RentalItemService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/rental-item")
public class RentalItemController {

    private final RentalItemService rentalItemService;
    private final StudentRepository studentRepository;
    private final RentalChatRoomRepository rentalchatRoomRepository;
    private final rentalHistoryRepository rentalHistoryRepository;


    public RentalItemController(RentalItemService rentalItemService, StudentRepository studentRepository, RentalChatRoomRepository rentalChatRoomRepository, rentalHistoryRepository rentalHistoryRepository) {
        this.rentalItemService = rentalItemService;
        this.studentRepository = studentRepository;
        this.rentalchatRoomRepository = rentalChatRoomRepository;
        this.rentalHistoryRepository = rentalHistoryRepository;
    }

    @PostMapping
    public ResponseEntity<RentalItem> saveRentalItem(@RequestBody RentalItemCreateRequest request) {
        RentalItem savedItem = rentalItemService.saveRentalItem(request);
        return ResponseEntity.ok(savedItem); // 또는 return new ResponseEntity<>(savedItem, HttpStatus.CREATED);
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

        RentalItem rentalItem = rentalItemService.getRentalItemDetails(id);

        RentalChatRoom rentalChatRoom = rentalchatRoomRepository.findByRentalItemId(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 대여 채팅방을 찾을 수 없습니다: " + id));

        Student responder = rentalChatRoom.getResponder(); // 대여 하는 사람
        Student requester = rentalChatRoom.getRequester(); // 대여 받는 사람

        RentalHistory rentalHistory = RentalHistory.builder()
                .rentalItem(rentalItem)
                .responder(responder)
                .requester(requester)
                .build();

        rentalHistoryRepository.save(rentalHistory);

        responder.incrementRentalCount(); // 대여한 사람의 대여 횟수 증가
        studentRepository.save(responder); // 대여한 사람의 정보 저장

        return ResponseEntity.ok("물품을 다시 대여 가능 상태로 변경");

    }

    // 특정 카테고리의 대여 가능한 물품 목록 조회
    @GetMapping("/available/category/{categoryId}")
    public ResponseEntity<List<RentalItem>> getAvailableItemsByCategory(@PathVariable Long categoryId) {
        return ResponseEntity.ok(rentalItemService.getAvailableItemsByCategory(categoryId));
    }
}
