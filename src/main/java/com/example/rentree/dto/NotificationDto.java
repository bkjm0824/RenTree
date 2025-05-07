package com.example.rentree.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NotificationDto {
    private Long id;
    private String message;
    private boolean isRead;
}
