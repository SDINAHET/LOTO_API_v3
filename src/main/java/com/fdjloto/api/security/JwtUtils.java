package com.fdjloto.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.security.SignatureException;
import io.jsonwebtoken.security.WeakKeyException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import javax.crypto.SecretKey;

/**
 * JWT Utility Class for handling JSON Web Tokens.
 * Provides methods for token generation, validation, and claims extraction.
 */
@Component
public class JwtUtils {

    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

    @Value("${app.jwtSecret}")
    private String jwtSecret;

    @Value("${app.jwtExpirationMs}")
    private int jwtExpirationMs;

    private static final String SECRET_KEY = "your_super_secret_key_that_should_be_at_least_32_characters_long";
    private final SecretKey key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes(StandardCharsets.UTF_8));
    private static final long EXPIRATION_TIME = 86400000; // 24 hours in milliseconds

    /**
     * Generates a new JWT token for the authenticated user.
     *
     * @param authentication the authentication object containing user details
     * @return the generated JWT token
     */
    public String generateJwtToken(Authentication authentication) {
        List<String> roles = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());

        return Jwts.builder()
                .setSubject(authentication.getName())
                .claim("roles", roles)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key)
                .compact();
    }

    /**
     * Extracts the username from a JWT token.
     * This is the primary method used by filters and controllers.
     *
     * @param token the JWT token
     * @return the username stored in the token
     * @throws JwtException if the token is invalid
     */
    public String getUserFromJwtToken(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .getSubject();
        } catch (JwtException e) {
            logger.error("Failed to extract username from token: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Extracts the roles from a JWT token.
     *
     * @param token the JWT token
     * @return list of roles stored in the token
     * @throws JwtException if the token is invalid
     */
    @SuppressWarnings("unchecked")
    public List<String> getRolesFromJwtToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            return claims.get("roles", List.class);
        } catch (JwtException e) {
            logger.error("Failed to extract roles from token: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Validates a JWT token.
     *
     * @param token the JWT token to validate
     * @return true if the token is valid, false otherwise
     */
    public boolean validateJwtToken(String token) {
        try {
            Jwts.parser()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (SignatureException e) {
            logger.error("Invalid JWT signature: {}", e.getMessage());
        } catch (WeakKeyException e) {
            logger.error("JWT key is too weak: {}", e.getMessage());
        } catch (JwtException e) {
            logger.error("JWT token validation failed: {}", e.getMessage());
        }
        return false;
    }

    /**
     * Alternative method to extract username using the application's secret key.
     * This method exists for legacy support but getUserFromJwtToken is preferred.
     *
     * @param token the JWT token
     * @return the username stored in the token
     * @throws JwtException if the token is invalid
     * @deprecated Use getUserFromJwtToken instead
     */
    @Deprecated
    public String getUserNameFromJwtToken(String token) {
        return getUserFromJwtToken(token);
    }
}
