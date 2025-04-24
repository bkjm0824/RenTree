package com.example.rentree.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry
                .addResourceHandler("/images/**") // 클라이언트가 요청하는 URL
                .addResourceLocations("file:///C:/rentree_upload/"); // 실제 저장된 폴더 (file:/// 꼭 붙이기!)
    }
}