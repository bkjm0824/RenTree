package com.example.rentree.security;

import com.example.rentree.domain.Student;
import com.example.rentree.repository.StudentRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class StudentDetailsService implements UserDetailsService {

    private final StudentRepository studentRepository;

    public StudentDetailsService(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String studentNum) throws UsernameNotFoundException {
        Student student = studentRepository.findByStudentNum(studentNum)
                .orElseThrow(() -> new UsernameNotFoundException("해당 학번의 학생을 찾을 수 없습니다: " + studentNum));
        return new StudentDetails(student);
    }
}
