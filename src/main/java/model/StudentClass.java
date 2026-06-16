package model;

import java.sql.Timestamp;

/**
 * FILE: StudentClass.java
 * PACKAGE: model
 *
 * MỤC ĐÍCH:
 *   Model đại diện cho bảng Classes trong cơ sở dữ liệu.
 */
public class StudentClass {
    private int id;
    private String className;
    private String description;
    private Timestamp createdAt;

    public StudentClass() {}

    public StudentClass(String className, String description) {
        this.className = className;
        this.description = description;
    }

    public StudentClass(int id, String className, String description, Timestamp createdAt) {
        this.id = id;
        this.className = className;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
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
        return "StudentClass{id=" + id + ", className='" + className + "'}";
    }
}
