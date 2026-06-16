package utils;

import model.Student;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * FILE: ExcelHelper.java
 * PACKAGE: utils
 *
 * MỤC ĐÍCH:
 *   Hỗ trợ nhập (Import) và xuất (Export) dữ liệu sinh viên từ/ra file Excel (XLSX).
 *   ĐÃ ĐƯỢC CẬP NHẬT để khớp với cấu trúc 5 thuộc tính của model.Student và Database.
 */
public class ExcelHelper {

    // Cập nhật lại tiêu đề cột cho khớp với 5 thuộc tính mới
    private static final String[] HEADERS = {
        "ID", "Họ Tên", "Email", "Chuyên Ngành", "Điểm Trung Bình"
    };

    /**
     * Xuất danh sách sinh viên ra OutputStream dưới định dạng Excel.
     */
    public static void exportStudentsToExcel(List<Student> students, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Danh sách Sinh viên");

            // Tạo style cho Header
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());

            CellStyle headerCellStyle = workbook.createCellStyle();
            headerCellStyle.setFont(headerFont);
            headerCellStyle.setFillForegroundColor(IndexedColors.CORNFLOWER_BLUE.getIndex());
            headerCellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerCellStyle.setAlignment(HorizontalAlignment.CENTER);
            headerCellStyle.setBorderBottom(BorderStyle.THIN);

            // Ghi header row
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < HEADERS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(HEADERS[i]);
                cell.setCellStyle(headerCellStyle);
            }

            // Ghi dữ liệu từng sinh viên
            int rowIdx = 1;
            for (Student student : students) {
                Row row = sheet.createRow(rowIdx++);

                row.createCell(0).setCellValue(student.getId());
                row.createCell(1).setCellValue(student.getHoTen());
                row.createCell(2).setCellValue(student.getEmail());
                row.createCell(3).setCellValue(student.getChuyenNganh());
                row.createCell(4).setCellValue(student.getDiemTB());
            }

            // Tự động căn chỉnh độ rộng cột
            for (int i = 0; i < HEADERS.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
        }
    }

    /**
     * Nhập danh sách sinh viên từ file Excel (InputStream).
     */
    public static List<Student> importStudentsFromExcel(InputStream is) throws Exception {
        List<Student> students = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rows = sheet.iterator();

            // Bỏ qua dòng tiêu đề (Header)
            if (rows.hasNext()) {
                rows.next();
            }

            while (rows.hasNext()) {
                Row currentRow = rows.next();

                // Kiểm tra nếu dòng trống (cột Họ Tên ở index 1 trống) thì bỏ qua
                Cell nameCell = currentRow.getCell(1);
                if (nameCell == null || getCellValueAsString(nameCell).trim().isEmpty()) {
                    continue;
                }

                Student student = new Student();

                // 1. ID (Cột 0)
                Cell idCell = currentRow.getCell(0);
                if (idCell != null && idCell.getCellType() == CellType.NUMERIC) {
                    student.setId((int) idCell.getNumericCellValue());
                }

                // 2. Họ Tên (Cột 1)
                student.setHoTen(getCellValueAsString(currentRow.getCell(1)).trim());
                
                // 3. Email (Cột 2)
                student.setEmail(getCellValueAsString(currentRow.getCell(2)).trim());
                
                // 4. Chuyên Ngành (Cột 3)
                student.setChuyenNganh(getCellValueAsString(currentRow.getCell(3)).trim());

                // 5. Điểm Trung Bình (Cột 4)
                Cell diemCell = currentRow.getCell(4);
                if (diemCell != null) {
                    if (diemCell.getCellType() == CellType.NUMERIC) {
                        student.setDiemTB(diemCell.getNumericCellValue());
                    } else {
                        String diemStr = getCellValueAsString(diemCell).trim();
                        if (!diemStr.isEmpty()) {
                            student.setDiemTB(Double.parseDouble(diemStr));
                        }
                    }
                }

                students.add(student);
            }
        }
        return students;
    }

    /**
     * Helper: Đọc giá trị của một ô Excel dưới dạng String.
     */
    private static String getCellValueAsString(Cell cell) {
        if (cell == null) {
            return "";
        }
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return new java.text.SimpleDateFormat("yyyy-MM-dd").format(cell.getDateCellValue());
                }
                double num = cell.getNumericCellValue();
                if (num == (long) num) {
                    return String.valueOf((long) num);
                } else {
                    return String.valueOf(num);
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }
}