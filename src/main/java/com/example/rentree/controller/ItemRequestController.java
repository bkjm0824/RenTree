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
    public void saveItemRequestItem(@RequestBody ItemRequestDTO itemRequestDTO) {
        itemRequestService.saveItemRequest(itemRequestDTO);
    }

    // 학번에 맞게 게시글 가져옴
    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<ItemRequestDTO>> getItemRequestByStudentId(@PathVariable int studentId) {
        List<ItemRequest> itemRequests = itemRequestService.getItemRequestByStudentId(studentId);
        List<ItemRequestDTO> itemRequestDTOS = itemRequests.stream().map(ItemRequestDTO::fromEntity).collect(Collectors.toList());
        return ResponseEntity.ok(itemRequestDTOS);
    }

    // 제목에 맞게 게시글 가져옴
    @GetMapping("/title/{title}")
    public ResponseEntity<List<ItemRequestDTO>> getItemRequestByTitle(@PathVariable String title) {
        List<ItemRequestDTO> itemRequestDTOS = itemRequestService.getItemRequestByTitleContaining(title)
                .stream()
                .map(ItemRequestDTO::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(itemRequestDTOS);
    }

    // 게시글 수정
    @PutMapping("/{id}")
    public ResponseEntity<ItemRequest> updateItemRequest(@PathVariable Long id, @RequestBody ItemRequestDTO itemRequestDTO) {
        Optional<ItemRequest> existingItemRequest = itemRequestService.findById(id);
        if(existingItemRequest.isPresent()) {
            ItemRequest itemRequest = existingItemRequest.get();
            itemRequest.setTitle(itemRequestDTO.getTitle());
            itemRequest.setDescription(itemRequestDTO.getDescription());
            itemRequest.setStartTime(itemRequestDTO.getStartTime());
            itemRequest.setEndTime(itemRequestDTO.getEndTime());
            itemRequest.setPerson(itemRequestDTO.isPerson());
            ItemRequest updateItemRequest = itemRequestService.updateItemRequest(itemRequest);
            return ResponseEntity.ok(updateItemRequest);
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