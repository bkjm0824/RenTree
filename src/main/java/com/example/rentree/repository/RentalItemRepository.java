package com.example.rentree.repository;

import com.example.rentree.domain.RentalItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface RentalItemRepository extends JpaRepository<RentalItem, Long> {

    Optional<RentalItem> findByTitle(String title);

    List<RentalItem> findByStudentId(String studentId);
}
