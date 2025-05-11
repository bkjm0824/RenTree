package com.example.rentree.dto;

import com.example.rentree.domain.RentalItem;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RequestHistoryDTO {

    private Long id; // 대여 이력 식별자
    private RentalItem requestItem; // 대여된 물품
    private StudentDTO requester; // 요청자
    private StudentDTO responder; // 응답자

}
