package com.example.rentree.controller;

import com.example.rentree.dto.HomeDTO;
import com.example.rentree.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/home")
public class HomeController {
    private final HomeService homeService;

    @Autowired
    public HomeController(HomeService homeService) {
        this.homeService = homeService;
    }

    @GetMapping("/items")
    public ResponseEntity<List<HomeDTO>> getAllItems() {
        List<HomeDTO> items = homeService.getAllItems();
        if (items.isEmpty()) {
            return ResponseEntity.noContent().build(); // 데이터가 없을 경우 204 No Content 반환
        }
        return ResponseEntity.ok(items); // 데이터가 있을 경우 200 OK 반환
    }
}
