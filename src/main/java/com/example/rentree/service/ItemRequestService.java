package com.example.rentree.service;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.RequestChatRoom;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.domain.ItemRequest;
import com.example.rentree.dto.ItemRequestResponseDTO;
import com.example.rentree.repository.ItemRequestRepository;
import com.example.rentree.repository.RequestChatRoomRepository;
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

    private final NotificationService notificationService;

    private final RequestChatRoomRepository requestChatRoomRepository;

    // 전체 게시글 가져오기 (createdAt이 최신순인 순서로 정렬)
    @Transactional(readOnly = true)
    public List<ItemRequest> getAllItemRequestsSorted(Sort sort) {
        return itemRequestRepository.findAll(sort); // 페이징 없이 전체 데이터 정렬된 리스트 반환
    }

    // 게시글 등록
    @Transactional
    public void saveItemRequest(String studentNum, ItemRequestDTO itemRequestDTO) {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("해당 학번의 학생을 찾을 수 없습니다: " + studentNum));

        ItemRequest itemRequest = new ItemRequest(
                student,
                itemRequestDTO.getTitle(),
                itemRequestDTO.getDescription(),
                itemRequestDTO.getIsFaceToFace(),
                itemRequestDTO.getCreatedAt(),
                itemRequestDTO.getRentalStartTime(),
                itemRequestDTO.getRentalEndTime(),
                itemRequestDTO.getPassword()
        );
        itemRequestRepository.save(itemRequest);

        // 자동 알림 생성
        notificationService.createNotificationsForMatchingKeywords(itemRequestDTO.getTitle() + " " + itemRequestDTO.getDescription());
    }

    @Transactional
    public ItemRequest getItemRequestDetail(Long id) {
        ItemRequest itemRequest = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(" : " + id));
        itemRequest.incrementViewCount(); // 조회수 증가
        itemRequestRepository.save(itemRequest); // 수정된 객체 저장

        return itemRequest;
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
    public void markAsRequested(Long id) {
        ItemRequest item = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 물품이 존재하지 않습니다."));
        item.markAsRequested();
    }

    @Transactional
    public void markAsAvailable(Long id) {
        ItemRequest item = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 물품이 존재하지 않습니다."));
        item.markAsAvailable();
    }

    @Transactional
    // 게시글 삭제
    public void deleteItemRequest(Long Id) {
        ItemRequest itemRequest = itemRequestRepository.findById(Id)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 게시글을 찾을 수 없습니다: " + Id));

        requestChatRoomRepository.updateItemRequestIdToNull(Id);

        itemRequestRepository.delete(itemRequest);
    }

    @Transactional(readOnly = true)
    // 게시글 ID로 게시글 가져오기
    public Optional<ItemRequest> findById(Long id) {
        return itemRequestRepository.findById(id);
    }

    public String generatePassword(Long id, String password) {
        ItemRequest itemRequest = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Item with ID " + id + " not found"));

        itemRequest.setPassword(password);

        itemRequestRepository.save(itemRequest);

        return password; // 비밀번호 반환
    }

    public String getPassword(Long id) {
        ItemRequest itemRequest = itemRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Item with ID " + id + " not found"));

        return itemRequest.getPassword(); // 비밀번호 반환
    }
}