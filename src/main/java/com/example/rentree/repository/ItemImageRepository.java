package com.example.rentree.repository;

import com.example.rentree.domain.ItemImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ItemImageRepository extends JpaRepository<ItemImage, Long> {
    List<ItemImage> findByRentalItemId(Long rentalItemId);
}

