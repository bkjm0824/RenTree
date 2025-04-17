package com.example.rentree.service;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.dto.ItemRequestResponseDTO;
import com.example.rentree.repository.ItemRequestRepository;
import com.example.rentree.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/*
게시글 정보를 관리하는 서비스 클래스
서비스는 비즈니스 로직을 처리하는 계층으로, 데이터베이스와의 상호작용을 담당하는 리포지토리와 연결됨
 */

@Service // 서비스 클래스임을 명시
@RequiredArgsConstructor // final 필드를 파라미터로 받는 생성자 생성
public class ItemRequestService {

    private final ItemRequestRepository itemRequestRepository; // ItemRequestRepository 객체 주입
    private final StudentRepository studentRepository;

    // 전체 게시글 가져오기 (createdAt이 최신순인 순서로 정렬)
    @Transactional(readOnly = true)
    public List<ItemRequest> getAllItemRequestsSorted(Sort sort) {
        return itemRequestRepository.findAll(sort); // 페이징 없이 전체 데이터 정렬된 리스트 반환
    }

    // 게시글 등록
    @Transactional
    public void saveItemRequest(String studentNum, ItemRequestDTO itemRequestDTO) {
        // 학번으로 학생 엔티티 조회
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다: " + studentNum));

        // ItemRequest 엔티티 생성 (DTO에서 받은 정보는 DB에 직접 저장이 불가해 DTO를 엔티티로 변환)
        ItemRequest itemRequest = new ItemRequest(
                student,
                itemRequestDTO.getTitle(),
                itemRequestDTO.getDescription(),
                itemRequestDTO.isFaceToFace(),
                itemRequestDTO.getCreatedAt(),
                itemRequestDTO.getRentalStartTime(),
                itemRequestDTO.getRentalEndTime()
        );
        itemRequestRepository.save(itemRequest);
    }

    @Transactional
    public ItemRequestResponseDTO getItemRequestDetail(Long id) {
        ItemRequest itemRequest = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(" : " + id));
        itemRequest.incrementViewCount(); // 조회수 증가
        itemRequestRepository.save(itemRequest); // 수정된 객체 저장

        return ItemRequestResponseDTO.fromEntity(itemRequest);
    }


    @Transactional(readOnly = true)
    // 제목에 맞게 게시글 가져오기
    public List<ItemRequest> getItemRequestByTitleContaining(String title) {
        return itemRequestRepository.findByTitleContaining(title);
    }

    @Transactional(readOnly = true)
    // 학번에 맞게 게시글 가져오기
    public List<ItemRequest> getItemRequestByStudentNum(String studentNum) {
        return itemRequestRepository.findByStudent_StudentNum(studentNum);
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