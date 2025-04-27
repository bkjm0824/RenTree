package com.example.rentree.service;

import com.example.rentree.domain.Like;
import com.example.rentree.domain.RentalItem;
import com.example.rentree.domain.Student;
import com.example.rentree.dto.LikeDTO;
import com.example.rentree.repository.LikeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LikeService {

    private final LikeRepository likeRepository;

    @Autowired
    public LikeService(LikeRepository likeRepository) {
        this.likeRepository = likeRepository;
    }

    // 좋아요 토글
    public LikeDTO toggleLike(Student student, RentalItem rentalItem) {
        Optional<Like> existingLike = likeRepository.findByStudentAndRentalItem(student, rentalItem);

        if (existingLike.isPresent()) {
            // 기존 좋아요 삭제
            likeRepository.delete(existingLike.get());
            return LikeDTO.builder()
                    .liked(false)
                    .studentNum(student.getStudentNum())
                    .rentalItemId(rentalItem.getId())
                    .id(existingLike.get().getId())
                    .build();
        } else {
            // 새로운 좋아요 추가
            Like newLike = new Like(student, rentalItem);
            Like savedLike = likeRepository.save(newLike);
            return LikeDTO.builder()
                    .liked(true)
                    .studentNum(student.getStudentNum())
                    .rentalItemId(rentalItem.getId())
                    .id(savedLike.getId())
                    .build();
        }
    }

    // 학생의 좋아요 목록 조회
    public List<LikeDTO> getLikesByStudent(String studentNum) {
        List<Like> likes = likeRepository.findByStudent_StudentNum(studentNum);
        return likes.stream()
                .map(LikeDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // 렌탈 아이템 별 좋아요 개수 조회
    public long countLikesByRentalItem(RentalItem rentalItemId) {
        return likeRepository.countByRentalItem(rentalItemId);
    }
}
