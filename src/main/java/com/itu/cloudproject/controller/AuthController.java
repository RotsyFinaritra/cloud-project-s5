package com.itu.cloudproject.controller;

import com.itu.cloudproject.model.User;
import com.itu.cloudproject.service.UserService;
import com.itu.cloudproject.service.dto.AuthDtos;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody AuthDtos.RegisterRequest req) throws Exception {
        User u = userService.register(req);
        return ResponseEntity.ok(u);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthDtos.LoginRequest req) throws Exception {
        var res = userService.authenticate(req);
        return ResponseEntity.ok(res);
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateMe(Authentication authentication, @RequestBody AuthDtos.UpdateUserRequest req) throws Exception {
        String principal = (String) authentication.getPrincipal();
        var updated = userService.updateUser(principal, req);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/unblock/{email}")
    public ResponseEntity<?> unblockUser(@PathVariable String email) throws Exception {
        userService.unblockUser(email);
        return ResponseEntity.ok().body("User unblocked");
    }
}
