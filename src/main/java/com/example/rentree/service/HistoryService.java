package com.example.rentree.service;

import com.example.rentree.domain.RentalHistory;
import com.example.rentree.domain.RequestHistory;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.*;
import com.example.rentree.repository.RentalHistoryRepository;
import com.example.rentree.repository.RequestHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HistoryService {

    private final RentalHistoryRepository rentalHistoryRepository;
    private final RequestHistoryRepository requestHistoryRepository;

    // 내가 대여한 내역 조회
    public List<RentalHistoryDTO> getMyRentals(Student me) {
        return rentalHistoryRepository.findByRequester(me).stream()
                .map(this::convertToRentalHistoryDTO)
                .collect(Collectors.toList());
    }

    // 내가 대여해준 내역 조회
    public List<RentalHistoryDTO> getRentalsIGave(Student me) {
        return rentalHistoryRepository.findByResponder(me).stream()
                .map(this::convertToRentalHistoryDTO)
                .collect(Collectors.toList());
    }

    // 내가 요청한 내역 조회
    public List<RequestHistoryDTO> getMyRequestHistories(Student me) {
        return requestHistoryRepository.findByRequester(me).stream()
                .map(this::convertToRequestHistoryDTO)
                .collect(Collectors.toList());
    }

    // 내가 응답한 요청 내역 조회
    public List<RequestHistoryDTO> getRequestsIGot(Student me) {
        return requestHistoryRepository.findByResponder(me).stream()
                .map(this::convertToRequestHistoryDTO)
                .collect(Collectors.toList());
    }

    // DTO 변환 메서드
    private RentalHistoryDTO convertToRentalHistoryDTO(RentalHistory entity) {
        return RentalHistoryDTO.builder()
                .id(entity.getId())
                .rentalItem(RentalItemDTO.fromEntity(entity.getRentalItem()))
                .requester(StudentDTO.fromEntity(entity.getRequester()))
                .responder(StudentDTO.fromEntity(entity.getResponder()))
                .build();
    }

    private RequestHistoryDTO convertToRequestHistoryDTO(RequestHistory entity) {
        return RequestHistoryDTO.builder()
                .id(entity.getId())
                .requestItem(ItemRequestDTO.fromEntity(entity.getItemRequest()))
                .requester(StudentDTO.fromEntity(entity.getRequester()))
                .responder(StudentDTO.fromEntity(entity.getResponder()))
                .build();
    }
}
