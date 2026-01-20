package com.itu.cloudproject.service.impl;

import com.itu.cloudproject.model.User;
import com.itu.cloudproject.repository.UserRepository;
import com.itu.cloudproject.security.JwtUtil;
import com.itu.cloudproject.service.UserService;
import com.itu.cloudproject.service.dto.AuthDtos;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class PostgresUserService implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public PostgresUserService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @Override
    @Transactional
    public User register(AuthDtos.RegisterRequest request) throws Exception {
        Optional<User> exists = userRepository.findByEmail(request.email());
        if (exists.isPresent()) throw new IllegalArgumentException("Email already registered");
        User u = new User();
        u.setEmail(request.email());
        u.setPassword(passwordEncoder.encode(request.password()));
        u.setFullName(request.fullName());
        u.setProvider("LOCAL");
        return userRepository.save(u);
    }

    @Override
    public AuthDtos.AuthResponse authenticate(AuthDtos.LoginRequest request) throws Exception {
        Optional<User> uo = userRepository.findByEmail(request.email());
        if (uo.isEmpty()) throw new IllegalArgumentException("Invalid credentials");
        User u = uo.get();
        if (u.getPassword() == null || !passwordEncoder.matches(request.password(), u.getPassword())) {
            throw new IllegalArgumentException("Invalid credentials");
        }
        String token = jwtUtil.generateToken(u.getEmail());
        return new AuthDtos.AuthResponse(token, "Bearer");
    }

    @Override
    @Transactional
    public User updateUser(String email, AuthDtos.UpdateUserRequest request) throws Exception {
        User u = userRepository.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("User not found"));
        if (request.fullName() != null) u.setFullName(request.fullName());
        return userRepository.save(u);
    }
}
