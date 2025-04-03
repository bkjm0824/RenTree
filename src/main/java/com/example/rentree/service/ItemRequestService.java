package com.example.rentree.service;

import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.repository.ItemRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/*
게시글 정보를 관리하는 서비스 클래스
게시글 정보를 가져오거나 수정, 삭제하는 기능을 제공
 */

@Service // 서비스 클래스임을 명시
@RequiredArgsConstructor // final 필드를 파라미터로 받는 생성자 생성
public class ItemRequestService {

    private final ItemRequestRepository itemRequestRepository; // ItemRequestRepository 객체 주입

    // 게시글 등록
    // @param itemRequestDTO : 게시글 정보
    // @return : 없음
    @Transactional
    public void saveItemRequest(ItemRequestDTO itemRequestDTO) {
        ItemRequest itemRequest = new ItemRequest(
                itemRequestDTO.getId(),
                itemRequestDTO.getStudentId(),
                itemRequestDTO.getTitle(),
                itemRequestDTO.getDescription(),
                itemRequestDTO.getStartTime(),
                itemRequestDTO.getEndTime(),
                itemRequestDTO.isPerson(),
                itemRequestDTO.getCreatedAt()
        );
        itemRequestRepository.save(itemRequest);
    }

    @Transactional(readOnly = true)
    // 제목에 맞게 게시글 가져오기
    public List<ItemRequest> getItemRequestByTitleContaining(String title) {
        return itemRequestRepository.findByTitleContaining(title);
    }

    @Transactional(readOnly = true)
    // 학번에 맞게 게시글 가져오기
    public List<ItemRequest> getItemRequestByStudentId(int studentId) {
        return itemRequestRepository.findByStudentId(studentId);
    }

    @Transactional
    // 게시글 수정
    public ItemRequest updateItemRequest(ItemRequest itemRequest) {
        return itemRequestRepository.save(itemRequest);
        // 예외 처리 추가 (아직 진행X)
    }

    @Transactional
    // 게시글 삭제
    public void deleteItemRequest(Long Id) {
        itemRequestRepository.findById(Id).ifPresent(itemRequestRepository::delete); // 게시글 ID로 게시글 찾아 삭제
    }

    @Transactional(readOnly = true)
    // 게시글 ID로 게시글 가져오기
    public Optional<ItemRequest> findById(Long id) {
        return itemRequestRepository.findById(id);
    }
}