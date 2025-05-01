package com.example.rentree.repository;

import com.example.rentree.domain.ItemImage;
import com.example.rentree.domain.RentalItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ItemImageRepository extends JpaRepository<ItemImage, Long> {
    List<ItemImage> findByRentalItemId(Long rentalItemId);

    void deleteByRentalItemId(Long rentalItemId); // RentalItem에 대한 이미지 삭제 메서드 추가
}

