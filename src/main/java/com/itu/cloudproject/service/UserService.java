package com.itu.cloudproject.service;

import com.itu.cloudproject.model.User;
import com.itu.cloudproject.service.dto.AuthDtos;

public interface UserService {
    User register(AuthDtos.RegisterRequest request) throws Exception;
    AuthDtos.AuthResponse authenticate(AuthDtos.LoginRequest request) throws Exception;
    User updateUser(String email, AuthDtos.UpdateUserRequest request) throws Exception;
}
