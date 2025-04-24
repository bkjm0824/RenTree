package com.example.rentree.controller;

import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.dto.ItemRequestResponseDTO;
import com.example.rentree.service.ItemRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/*
게시글 정보를 관리하는 컨트롤러 클래스
컨트롤러 클래스는 HTTP 요청을 처리하고 응답을 반환하는 역할
 */

@RestController
@RequestMapping("/ItemRequest")
@RequiredArgsConstructor
public class ItemRequestController {

    private final ItemRequestService itemRequestService;

    // 전체 게시글 가져오기
    @GetMapping("/all")
    public ResponseEntity<List<ItemRequestDTO>> getAllItemRequests(
            @RequestParam(required = false, defaultValue = "createdAt") String sortBy,
            @RequestParam(required = false, defaultValue = "desc") String sortDirection) {

        // 정렬 기준을 받아서 Sort 객체 생성
        Sort sort = Sort.by(Sort.Order.by(sortBy).with(Sort.Direction.fromString(sortDirection)));

        // 서비스에서 정렬된 데이터를 가져옴
        List<ItemRequest> itemRequests = itemRequestService.getAllItemRequestsSorted(sort);
        List<ItemRequestDTO> dtos = itemRequests.stream()
                .map(ItemRequestDTO::fromEntity)
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    // 글 등록하기
    @PostMapping
    public ResponseEntity<String> saveItemRequest(@RequestBody ItemRequestDTO itemRequestDTO) {
        String studentNum = itemRequestDTO.getStudentNum(); // DTO에서 추출
        itemRequestService.saveItemRequest(studentNum, itemRequestDTO);
        return ResponseEntity.ok("ItemRequest saved");
    }

    // 학번(studentNum)에 맞게 게시글 가져오기
    @GetMapping("/student/{studentNum}")
    public ResponseEntity<List<ItemRequestResponseDTO>> getItemRequestByStudentNum(@PathVariable String studentNum) {
        List<ItemRequest> itemRequests = itemRequestService.getItemRequestByStudentNum(studentNum);
        List<ItemRequestResponseDTO> dtos = itemRequests.stream()
                .map(ItemRequestResponseDTO::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    // 제목에 포함된 단어로 게시글 검색
    @GetMapping("/search")
    public ResponseEntity<List<ItemRequestResponseDTO>> getItemRequestByTitle(@RequestParam String keyword) {
        //System.out.println("검색어: " + title);
        List<ItemRequestResponseDTO> dtos = itemRequestService.getItemRequestByTitleContaining(keyword)
                .stream() // List<ItemRequest>를 stream으로 변환
                .map(ItemRequestResponseDTO::fromEntity) // 각 ItemRequest를 ItemRequestResponseDTO로 변환
                .collect(Collectors.toList()); // 변환된 결과를 List로 수집
        return ResponseEntity.ok(dtos); // 200 OK 응답
    }

    // 게시글 수정
    @PutMapping("/{id}")
    public ResponseEntity<ItemRequestResponseDTO> updateItemRequest(
            @PathVariable Long id,
            @RequestBody ItemRequestDTO itemRequestDTO
    ) {
        Optional<ItemRequest> existingItemRequest = itemRequestService.findById(id);
        if (existingItemRequest.isPresent()) {
            ItemRequest itemRequest = existingItemRequest.get();
            itemRequest.setTitle(itemRequestDTO.getTitle());
            itemRequest.setDescription(itemRequestDTO.getDescription());
            itemRequest.setRentalStartTime(itemRequestDTO.getRentalStartTime());
            itemRequest.setRentalEndTime(itemRequestDTO.getRentalEndTime());
            itemRequest.setIsFaceToFace(itemRequestDTO.getIsFaceToFace());

            // student는 수정하지 않음

            ItemRequest updated = itemRequestService.updateItemRequest(itemRequest);
            return ResponseEntity.ok(ItemRequestResponseDTO.fromEntity(updated));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getRentalItemDetails(@PathVariable Long id) {
        if (id <= 0) {
            return ResponseEntity.badRequest().body("ID는 1 이상의 양수여야 합니다.");
        }

        try {
            ItemRequestResponseDTO dto = itemRequestService.getItemRequestDetail(id);
            return ResponseEntity.ok(dto);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteItemRequest(@PathVariable Long id) {
        // 존재 여부 확인
        if (!itemRequestService.findById(id).isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("ItemRequest not found");
        }
        // 존재하면 삭제
        itemRequestService.deleteItemRequest(id);
        return ResponseEntity.ok("ItemRequest deleted");
    }
}