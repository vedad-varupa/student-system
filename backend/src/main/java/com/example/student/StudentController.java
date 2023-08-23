package com.example.student;
import org.springframework.web.bind.annotation.*;

@RestController
@CrossOrigin("http://localhost:80")
@RequestMapping("/api/students")

public class StudentController {
    private final StudentRepository studentRepository;

    public StudentController(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }
    @PostMapping
    public StudentEntity createStudent(@RequestBody StudentEntity student) {
        return studentRepository.save(student);
    }

}