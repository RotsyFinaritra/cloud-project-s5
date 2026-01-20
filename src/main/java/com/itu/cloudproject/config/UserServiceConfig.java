package com.itu.cloudproject.config;

import com.google.firebase.FirebaseApp;
import com.itu.cloudproject.service.UserService;
import com.itu.cloudproject.service.impl.FirebaseUserService;
import com.itu.cloudproject.service.impl.PostgresUserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class UserServiceConfig {

    @Bean
    @Primary
    public UserService userService(PostgresUserService pg, FirebaseUserService fb) {
        // If Firebase is initialized in the app, prefer it.
        try {
            if (FirebaseApp.getApps().size() > 0) {
                return fb;
            }
        } catch (Exception e) {
            // continue to fallback
        }
        return pg;
    }
}
