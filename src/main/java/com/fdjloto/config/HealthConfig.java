package com.fdjloto.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class HealthConfig {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private MongoTemplate mongoTemplate;

    @Bean
    public HealthIndicator postgresHealthIndicator() {
        return () -> {
            try {
                jdbcTemplate.queryForObject("SELECT 1", Integer.class);
                return Health.up()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("status", "Connected")
                    .build();
            } catch (Exception e) {
                return Health.down()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("error", e.getMessage())
                    .build();
            }
        };
    }

    @Bean
    public HealthIndicator mongoHealthIndicator() {
        return () -> {
            try {
                // Vérifier la connexion en listant les collections
                mongoTemplate.getCollectionNames();
                return Health.up()
                    .withDetail("database", "MongoDB")
                    .withDetail("status", "Connected")
                    .build();
            } catch (Exception e) {
                return Health.down()
                    .withDetail("database", "MongoDB")
                    .withDetail("error", e.getMessage())
                    .build();
            }
        };
    }

    @Bean
    public HealthIndicator applicationHealthIndicator() {
        return () -> {
            return Health.up()
                .withDetail("application", "LOTO API")
                .withDetail("version", "1.0")
                .withDetail("environment", System.getenv("SPRING_PROFILES_ACTIVE"))
                .withDetail("java.version", System.getProperty("java.version"))
                .build();
        };
    }
}
