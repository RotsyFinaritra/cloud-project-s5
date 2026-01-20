package com.itu.cloudproject.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.net.HttpURLConnection;
import java.net.URL;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.enabled:false}")
    private boolean firebaseEnabled;

    @Value("${firebase.service.account.path:}")
    private String serviceAccountPath;

    @PostConstruct
    public void init() {
        try {
            if (!firebaseEnabled) return;
            // quick network check: reach googleapis
            URL u = new URL("https://www.googleapis.com");
            HttpURLConnection conn = (HttpURLConnection) u.openConnection();
            conn.setConnectTimeout(3000);
            conn.setRequestMethod("HEAD");
            int code = conn.getResponseCode();
            if (code >= 200 && code < 400 && serviceAccountPath != null && !serviceAccountPath.isBlank()) {
                FileInputStream serviceAccount = new FileInputStream(serviceAccountPath);
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();
                FirebaseApp.initializeApp(options);
            } else {
                // Skip firebase initialization
            }
        } catch (Exception e) {
            // Failed to initialize Firebase — will fallback to Postgres service
        }
    }
}
