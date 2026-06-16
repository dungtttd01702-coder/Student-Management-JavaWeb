package model;

/**
 * FILE: Score.java
 * PACKAGE: model
 *
 * MỤC ĐÍCH:
 *   Model đại diện cho bảng Scores trong cơ sở dữ liệu.
 */
public class Score {
    private int id;
    private int studentId;
    private String studentCode; // Trường hiển thị thêm từ việc JOIN bảng Students
    private String studentName; // Trường hiển thị thêm từ việc JOIN bảng Students
    private String subjectName;
    private double midtermScore;
    private double finalScore;
    private double gpa;
    private String semester;

    public Score() {}

    public Score(int studentId, String subjectName, double midtermScore, double finalScore, double gpa, String semester) {
        this.studentId = studentId;
        this.subjectName = subjectName;
        this.midtermScore = midtermScore;
        this.finalScore = finalScore;
        this.gpa = gpa;
        this.semester = semester;
    }

    public Score(int id, int studentId, String studentCode, String studentName, String subjectName, double midtermScore, double finalScore, double gpa, String semester) {
        this.id = id;
        this.studentId = studentId;
        this.studentCode = studentCode;
        this.studentName = studentName;
        this.subjectName = subjectName;
        this.midtermScore = midtermScore;
        this.finalScore = finalScore;
        this.gpa = gpa;
        this.semester = semester;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getStudentCode() {
        return studentCode;
    }

    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public double getMidtermScore() {
        return midtermScore;
    }

    public void setMidtermScore(double midtermScore) {
        this.midtermScore = midtermScore;
    }

    public double getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(double finalScore) {
        this.finalScore = finalScore;
    }

    public double getGpa() {
        return gpa;
    }

    public void setGpa(double gpa) {
        this.gpa = gpa;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    /**
     * Tự động tính toán điểm GPA dựa trên trọng số: Midterm * 0.3 + Final * 0.7
     */
    public void calculateGpa() {
        this.gpa = Math.round((this.midtermScore * 0.3 + this.finalScore * 0.7) * 100.0) / 100.0;
    }

    @Override
    public String toString() {
        return "Score{id=" + id + ", studentId=" + studentId + ", subjectName='" + subjectName + "', gpa=" + gpa + "}";
    }
}
