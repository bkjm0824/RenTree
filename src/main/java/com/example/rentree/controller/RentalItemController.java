package com.example.rentree.controller;

import com.example.rentree.domain.RentalItem;
import com.example.rentree.dto.RentalItemCreateRequest;
import com.example.rentree.service.RentalItemService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/rental-item")
public class RentalItemController {

    private final RentalItemService rentalItemService;

    public RentalItemController(RentalItemService rentalItemService) {
        this.rentalItemService = rentalItemService;
    }

    @PostMapping
    public void saveRentalItem(@RequestBody RentalItemCreateRequest request) {
        rentalItemService.saveRentalItem(request);
    }

    @GetMapping("/title")
    public Optional<RentalItem> getRentalItemByTitle(@RequestParam String title) {
        return rentalItemService.getRentalItemByTitle(title);
    }

    @GetMapping("/student/{studentId}")
    public List<RentalItem> getRentalItemsByStudentId(@PathVariable String studentId) {
        return rentalItemService.getRentalItemsByStudentId(studentId);
    }
}
