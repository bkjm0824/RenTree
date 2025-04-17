package com.example.rentree.service;

import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.HomeDTO;
import com.example.rentree.dto.ItemRequestDTO;
import com.example.rentree.dto.RentalItemCreateRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class HomeService {
    private final ItemRequestService itemRequestService;
    private final RentalItemService rentalItemService;

    @Autowired
    public HomeService(ItemRequestService itemRequestService, RentalItemService rentalItemService) {
        this.itemRequestService = itemRequestService;
        this.rentalItemService = rentalItemService;
    }

    // 전체 게시글 가져오기 (최신순으로 정렬)
    public List<HomeDTO> getAllItems() {
        // 전체 게시글을 저장할 리스트
        List<HomeDTO> result = new ArrayList<>();

        // 내림차순으로 조회
        List<ItemRequest> itemRequests = itemRequestService.getAllItemRequestsSorted(Sort.by(Sort.Order.desc("createdAt")));
        List<?> rentalItems = rentalItemService.getAllRentalItemsSorted(Sort.by(Sort.Order.desc("createdAt")));

        // HomeDTO로 변환하여 리스트에 추가
        result.addAll(createHomeDTOList(itemRequests));
        result.addAll(createHomeDTOList(rentalItems));

        // 모든 항목을 createdAt 기준으로 정렬
        result.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));

        return result;
    }

    // 다양한 타입의 객체 리스트를 받아 각 객체를 HomeDTO로 변환 후 리스트로 반환하는 메서드 (ItemRequest, ItemRequestDTO, REntalItemCreateRequest, RentalItem)
    private <T> List<HomeDTO> createHomeDTOList(List<T> items) {
        // 결과를 저장할 HomeDTO 리스트
        List<HomeDTO> homeDTOs = new ArrayList<>();

        for (T item : items) {
            try {
                if (item instanceof ItemRequest) {
                    homeDTOs.add(new HomeDTO((ItemRequest) item));
                } else if (item instanceof ItemRequestDTO) {
                    homeDTOs.add(new HomeDTO((ItemRequestDTO) item));
                } else if (item instanceof RentalItemCreateRequest) {
                    homeDTOs.add(new HomeDTO((RentalItemCreateRequest) item));
                } else if (item instanceof RentalItem) {  // RentalItem 엔티티도 처리
                    homeDTOs.add(new HomeDTO((RentalItem) item));
                } else {
                    // 지원하지 않는 타입인 경우
                    System.out.println("Unknown type: " + item.getClass().getName());
                }
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
                e.printStackTrace();
            }
        }

        return homeDTOs;
    }
}