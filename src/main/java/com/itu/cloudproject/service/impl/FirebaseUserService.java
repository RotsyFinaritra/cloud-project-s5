package com.itu.cloudproject.service.impl;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.itu.cloudproject.model.User;
import com.itu.cloudproject.security.JwtUtil;
import com.itu.cloudproject.service.UserService;
import com.itu.cloudproject.service.dto.AuthDtos;

@Service
@ConditionalOnProperty(name = "firebase.enabled", havingValue = "true")
public class FirebaseUserService implements UserService {

    private final FirebaseAuth firebaseAuth;
    private final JwtUtil jwtUtil;

    public FirebaseUserService(JwtUtil jwtUtil) {
        this.firebaseAuth = FirebaseAuth.getInstance();
        this.jwtUtil = jwtUtil;
    }

    @Override
    @Transactional
    public User register(AuthDtos.RegisterRequest request) throws Exception {
        UserRecord.CreateRequest cr = new UserRecord.CreateRequest()
                .setEmail(request.email())
                .setPassword(request.password())
                .setDisplayName(request.fullName());
        UserRecord ur = firebaseAuth.createUser(cr);
        User u = new User();
        u.setEmail(ur.getEmail());
        u.setFullName(ur.getDisplayName());
        u.setProvider("FIREBASE");
        // Note: we do not persist to Postgres here. This implementation creates the
        // user in Firebase.
        return u;
    }

    @Override
    public AuthDtos.AuthResponse authenticate(AuthDtos.LoginRequest request) throws Exception {
        // For Firebase, authentication should be done client-side (Firebase SDK) which
        // returns an idToken.
        // The client can then send the idToken to the server where we verify it and
        // optionally mint a local JWT.
        if (request.idToken() == null)
            throw new IllegalArgumentException("For Firebase login, send idToken");
        try {
            var decoded = firebaseAuth.verifyIdToken(request.idToken());
            String uid = decoded.getUid();
            // Create a local JWT with subject = uid (or email)
            String token = jwtUtil.generateToken(decoded.getEmail() != null ? decoded.getEmail() : uid);
            return new AuthDtos.AuthResponse(token, "Bearer");
        } catch (FirebaseAuthException e) {
            throw new IllegalArgumentException("Invalid Firebase idToken");
        }
    }

    @Override
    @Transactional
    public User updateUser(String email, AuthDtos.UpdateUserRequest request) throws Exception {
        // Find user by email in Firebase and update
        try {
            UserRecord ur = firebaseAuth.getUserByEmail(email);
            UserRecord.UpdateRequest urq = new UserRecord.UpdateRequest(ur.getUid());
            if (request.fullName() != null)
                urq.setDisplayName(request.fullName());
            UserRecord updated = firebaseAuth.updateUser(urq);
            User u = new User();
            u.setEmail(updated.getEmail());
            u.setFullName(updated.getDisplayName());
            u.setProvider("FIREBASE");
            return u;
        } catch (FirebaseAuthException e) {
            throw new IllegalArgumentException("Unable to update Firebase user");
        }
    }

    @Override
    public void unblockUser(String email) throws Exception {
        throw new UnsupportedOperationException("Unblock not supported for Firebase users");
    }
}
