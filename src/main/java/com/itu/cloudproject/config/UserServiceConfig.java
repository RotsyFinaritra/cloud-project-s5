package com.itu.cloudproject.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import com.google.firebase.FirebaseApp;
import com.itu.cloudproject.service.UserService;
import com.itu.cloudproject.service.impl.FirebaseUserService;
import com.itu.cloudproject.service.impl.PostgresUserService;

@Configuration
public class UserServiceConfig {

    @Bean
    @Primary
    public UserService userService(PostgresUserService pg,@Autowired(required = false) FirebaseUserService fb) {
        // If Firebase is initialized in the app, prefer it.
        try {
            if (fb != null && FirebaseApp.getApps().size() > 0) {
                return fb;
            }
        } catch (Exception e) {
            // continue to fallback
        }
        return pg;
    }
}
