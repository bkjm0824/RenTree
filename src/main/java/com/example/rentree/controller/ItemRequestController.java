package com.example.rentree.controller;

import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.service.ItemRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/ItemRequest")
@RequiredArgsConstructor
public class ItemRequestController {

    private final ItemRequestService itemRequestService;

    // 글 등록하기
    @PostMapping
    public ResponseEntity<String> saveItemRequest(@RequestBody ItemRequestDTO itemRequestDTO) {
        itemRequestService.saveItemRequest(itemRequestDTO);
        return ResponseEntity.ok("ItemRequest saved");
    }

    // 학번(studentNum)에 맞게 게시글 가져오기
    @GetMapping("/student/{studentNum}")
    public ResponseEntity<List<ItemRequestDTO>> getItemRequestByStudentNum(@PathVariable String studentNum) {
        List<ItemRequest> itemRequests = itemRequestService.getItemRequestByStudentNum(studentNum);
        List<ItemRequestDTO> dtos = itemRequests.stream()
                .map(ItemRequestDTO::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    // 제목에 포함된 단어로 게시글 검색
    @GetMapping("/title/{title}")
    public ResponseEntity<List<ItemRequestDTO>> getItemRequestByTitle(@PathVariable String title) {
        List<ItemRequestDTO> dtos = itemRequestService.getItemRequestByTitleContaining(title)
                .stream()
                .map(ItemRequestDTO::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    // 게시글 수정
    @PutMapping("/{id}")
    public ResponseEntity<ItemRequest> updateItemRequest(
            @PathVariable Long id,
            @RequestBody ItemRequestDTO itemRequestDTO
    ) {
        Optional<ItemRequest> existingItemRequest = itemRequestService.findById(id);
        if (existingItemRequest.isPresent()) {
            ItemRequest itemRequest = existingItemRequest.get();
            itemRequest.setTitle(itemRequestDTO.getTitle());
            itemRequest.setDescription(itemRequestDTO.getDescription());
            itemRequest.setStartTime(itemRequestDTO.getStartTime());
            itemRequest.setEndTime(itemRequestDTO.getEndTime());
            itemRequest.setPerson(itemRequestDTO.isPerson());

            // student는 수정하지 않음 (필요 시 로직 추가 가능)

            ItemRequest updated = itemRequestService.updateItemRequest(itemRequest);
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // 게시글 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteItemRequest(@PathVariable Long id) {
        itemRequestService.deleteItemRequest(id);
        return ResponseEntity.ok("ItemRequest deleted");
    }
}
