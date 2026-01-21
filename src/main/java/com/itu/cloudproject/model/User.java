package com.itu.cloudproject.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    private String password;

    @Column(name = "full_name")
    private String fullName;

    private String provider; // LOCAL or FIREBASE

    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @Column(name = "login_attempts", nullable = false)
    private int loginAttempts = 0;

    @Column(name = "is_blocked", nullable = false)
    private boolean isBlocked = false;

    @Column(name = "blocked_at")
    private OffsetDateTime blockedAt;

    @Column(name = "last_login")
    private OffsetDateTime lastLogin;

    @PrePersist
    public void prePersist() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = OffsetDateTime.now();
        if (provider == null) provider = "LOCAL";
        if (blockedAt == null) blockedAt = null;
        if (lastLogin == null) lastLogin = null;
    }

    // getters and setters

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

    public int getLoginAttempts() { return loginAttempts; }
    public void setLoginAttempts(int loginAttempts) { this.loginAttempts = loginAttempts; }

    public boolean isBlocked() { return isBlocked; }
    public void setBlocked(boolean blocked) { isBlocked = blocked; }

    public OffsetDateTime getBlockedAt() { return blockedAt; }
    public void setBlockedAt(OffsetDateTime blockedAt) { this.blockedAt = blockedAt; }

    public OffsetDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(OffsetDateTime lastLogin) { this.lastLogin = lastLogin; }
}
