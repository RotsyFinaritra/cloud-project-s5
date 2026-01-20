package com.itu.cloudproject.service.dto;

public class AuthDtos {
    public static record RegisterRequest(String email, String password, String fullName) {}
    public static record LoginRequest(String email, String password, String idToken) {}
    public static record UpdateUserRequest(String fullName) {}
    public static record AuthResponse(String token, String tokenType) {}
}
