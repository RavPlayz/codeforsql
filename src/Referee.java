import java.sql.*;
import java.util.Scanner;

public class Referee {
    static final Scanner sc = new Scanner(System.in);

    public static void refereelog(String[] args) throws ClassNotFoundException, SQLException {
        System.out.println("请登录");
        Connection conn = login();
        while (true) {
            System.out.println("请选择你要进行的操作");
            System.out.println("1.添加成绩");
            System.out.println("2.查看运动员成绩");
            System.out.println("3.查看学院成绩");
            System.out.println("4.退出");
            int choice = sc.nextInt();
            switch (choice) {
                case 1:
                    addScore(conn);
                    break;
                case 2:
                    selectJockScore(conn);
                    break;
                case 3:
                    selectdepartmentScore(conn);
                    break;
                case 4:
                    conn.close();
                    System.exit(0);
                    break;
                default:
                    System.out.println("输入错误");
            }
        }
    }

    private static Connection login() throws ClassNotFoundException, SQLException {
        String url = "jdbc:sqlserver://localhost;databaseName=fwy;encrypt=false;";
        String user;
        String password;
        System.out.println("请输入用户名");
        user = sc.next();
        System.out.println("请输入密码");
        password = sc.next();

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection conn = DriverManager.getConnection(url, user, password);
        if (conn != null)
            System.out.println("登录成功");
        else
            System.out.println("登录失败");
        return conn;
    }

    private static void addScore(Connection conn) throws SQLException {
        System.out.println("请输入成绩ID");
        int scoreid = sc.nextInt();
        System.out.println("请输入运动员ID");
        int jockid = sc.nextInt();
        System.out.println("请输入项目ID");
        int eventid = sc.nextInt();
        System.out.println("请输入成绩");
        double score = sc.nextDouble();
        System.out.println("请输入排名");
        int rank = sc.nextInt();
        String sql = "insert into marks values(?,?,?,?,?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, scoreid);
            pstmt.setInt(2, jockid);
            pstmt.setInt(3, eventid);
            pstmt.setDouble(4, score);
            pstmt.setInt(5, rank);
            int rowAffect = pstmt.executeUpdate();
            if (rowAffect > 0)
                System.out.println("添加成功");
            else
                System.out.println("添加失败");
        }
        conn.close();

    }

    private static void selectJockScore(Connection conn) throws SQLException {
        System.out.println("请输入运动员ID");
        int jockid = sc.nextInt();
        String sql = "select * from marks where jockid = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, jockid);
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.println("成绩序号为" + rs.getInt(1) + "运动员编号为" + rs.getInt(2) + "项目编号为" + rs.getInt(3) + "分数为" + rs.getDouble(4) + "排名为" + rs.getInt(5));
            }
        }
        conn.close();
        pstmt.close();
    }


    private static void selectdepartmentScore(Connection conn) throws SQLException {
        System.out.println("请输入学院ID");
        int departmentid = sc.nextInt();
        String sql = "select * from departmentpoints where departmentid = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, departmentid);
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.println("学院编号为" + rs.getInt(1) + "排名为" + rs.getInt(2) + "分数为" + rs.getInt(3));
            }
        }
        conn.close();
        pstmt.close();
    }
}


