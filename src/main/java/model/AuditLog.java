package model;

import java.sql.Timestamp;

/**
 * FILE: AuditLog.java
 * PACKAGE: model
 *
 * MỤC ĐÍCH:
 *   Model đại diện cho bảng AuditLogs trong cơ sở dữ liệu.
 */
public class AuditLog {
    private int id;
    private String username;
    private String action;
    private String description;
    private Timestamp createdAt;

    public AuditLog() {}

    public AuditLog(String username, String action, String description) {
        this.username = username;
        this.action = action;
        this.description = description;
    }

    public AuditLog(int id, String username, String action, String description, Timestamp createdAt) {
        this.id = id;
        this.username = username;
        this.action = action;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "AuditLog{id=" + id + ", username='" + username + "', action='" + action + "'}";
    }
}
