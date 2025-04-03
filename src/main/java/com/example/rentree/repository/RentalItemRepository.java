package com.example.rentree.repository;

import com.example.rentree.domain.RentalItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RentalItemRepository extends JpaRepository<RentalItem, Long> {

    List<RentalItem> findByTitleContaining(String keyword);

    List<RentalItem> findByStudentId(String studentId);

    void deleteById(Long id);
}