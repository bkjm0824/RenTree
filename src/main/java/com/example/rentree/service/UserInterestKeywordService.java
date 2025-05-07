package com.example.rentree.service;

import com.example.rentree.domain.Student;
import com.example.rentree.domain.UserInterestKeyword;
import com.example.rentree.dto.UserInterestKeywordDto;
import com.example.rentree.repository.UserInterestKeywordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserInterestKeywordService {

    private final UserInterestKeywordRepository keywordRepository;

    // 관심 키워드 등록
    public void addKeyword(Student student, String keyword) {
        UserInterestKeyword userKeyword = new UserInterestKeyword();
        userKeyword.setKeyword(keyword);
        userKeyword.setStudent(student);
        keywordRepository.save(userKeyword);
    }

    // 관심 키워드 목록 조회
    public List<UserInterestKeywordDto> getKeywordsByStudent(Student student) {
        List<UserInterestKeyword> keywords = keywordRepository.findByStudent(student);

        return keywords.stream().map(k -> {
            UserInterestKeywordDto dto = new UserInterestKeywordDto();
            dto.setId(k.getId());
            dto.setKeyword(k.getKeyword());
            return dto;
        }).collect(Collectors.toList());
    }

    // 관심 키워드 삭제
    public void deleteKeyword(Long keywordId) {
        keywordRepository.deleteById(keywordId);
    }
}
