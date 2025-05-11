package com.example.rentree.service;

import com.example.rentree.dto.StudentDTO;
import com.example.rentree.domain.Student;
import com.example.rentree.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

@Service // 서비스 클래스임을 명시
@RequiredArgsConstructor // final 필드를 파라미터로 받는 생성자 생성
public class StudentService {

    private final StudentRepository studentRepository; // StudentRepository 객체 주입

    public StudentDTO getStudentByStudentNum(String StudentNum) {
        // 학번으로 학생 정보 가져오기
        Optional<Student> student = studentRepository.findByStudentNum(StudentNum);
        // StudentDTO로 변환하여 반환 (null일 경우 null 반환)
        return student.map(StudentDTO::fromEntity).orElse(null);
    }

    public Student authenticate(String studentNum, String password) throws NoSuchAlgorithmException {
        // 학번으로 학생 정보 가져오기
        Optional<Student> student = studentRepository.findByStudentNum(studentNum);
        // 입력된 평문 비밀번호를 SHA-2로 해시화하여 DB에 저장된 암호화된 비밀번호와 비교
        if(student.isPresent()) {
            // 비밀번호가 일치하면 학생 정보 반환
            if (student.get().getPassword().equals(hashPassword(password))) {
                return student.get(); // 로그인 성공
            }
        }
        return null; // 로그인 실패
    }

    private String hashPassword(String password) throws NoSuchAlgorithmException {
        // SHA-256 해시 알고리즘을 사용하는 MessageDigest 객체 생성
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        // 문자열 비밀번호를 바이트 배열로 변환 후 SHA-256 알고리즘으로 해시하여 해시값을 바이트 배열로 반환
        byte[] hash = digest.digest(password.getBytes());

        // 바이트 배열을 16진수 문자열로 변환
        StringBuilder hexString = new StringBuilder();
        // 해시 함수가 생성한 바이트 배열의 각 바이트를 순회 (256비트 = 32바이트 -> 32번 실행)
        for (byte b : hash) {
            // 각 바이트를 16진수 형식으로 반환 -> %x : 16진수 형식으로 출력, %02x : 2자리 16진수로 출력(빈자리는 0으로 채움)
            hexString.append(String.format("%02x", b));
        }
        // 해싱된 비밀번호 반환
        return hexString.toString();
    }

    // StudentService.java
    public void updateStudentNickname(String studentNum, String nickname) {
        // 학번으로 학생 정보 가져오기
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with studentNum: " + studentNum));

        // 닉네임 설정
        student.setNickname(nickname);

        // 변경 사항 저장
        studentRepository.save(student);
    }

    // 첫 로그인 시 랜덤으로 프로필 이미지 난수 배정(1~4)
    public void assignRandomProfileImage(Student student) {
        int randomImage = (int) (Math.random() * 4) + 1;
        student.setProfileImage(randomImage);
        studentRepository.save(student);
    }

    // 프로필 이미지 조회
    public Integer getProfileImage(String studentNum) {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with studentNum: " + studentNum));
        return student.getProfileImage();
    }

    public void updateProfileImage(String studentNum, Integer profileImage) {
        if (profileImage < 1 || profileImage > 4) {
            throw new IllegalArgumentException("Invalid profile image value: " + profileImage);
        }
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with studentNum: " + studentNum));

        student.setProfileImage(profileImage);

        studentRepository.save(student);
    }
}
