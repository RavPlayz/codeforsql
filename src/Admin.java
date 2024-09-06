import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Scanner;
public class Admin {
    static final Scanner sc = new Scanner(System.in);
    public static void adminlog(String[] args) throws ClassNotFoundException, SQLException{
        System.out.println("请登录");
        Connection conn=login();
        while (true) {
            System.out.println("请选择你要进行的操作");
            System.out.println("1.添加新运动员");
            System.out.println("2.删除运动员");
            System.out.println("3.修改运动员信2息");
            System.out.println("4.添加比赛");
            System.out.println("5.删除比赛");
            System.out.println("6.修改比赛信息");
            System.out.println("7.添加学院");
            System.out.println("8.删除学院");
            System.out.println("9.修改学院信息");
            System.out.println("10.退出");
            int choice = sc.nextInt();
            switch (choice) {
                case 1:
                    addJock(conn);
                    break;
                    case 2:
                    deleteJock(conn);
                    break;
                case 3:
                    updateJock(conn);
                    break;
                case 4:
                    addCompetition(conn);
                    break;
                case 5:
                    deleteCompetition(conn);
                    break;
                case 6:
                    updateCompetition(conn);
                    break;
                case 7:
                    addCollege(conn);
                    break;
                    case 8:
                    deleteCollege(conn);
                    break;
                    case 9:
                    updateCollege(conn);
                    break;
                    case 10:
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
    private static void addJock(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入运动员ID");
        int id = sc.nextInt();
        System.out.println("请输入运动员姓名");
        String name = sc.next();
        System.out.println("请输入运动员性别");
        String sex = sc.next();
        System.out.println("请输入运动员年龄");
        int age = sc.nextInt();
        System.out.println("请输入运动员学院");
        String college = sc.next();
        String sql = "insert into jock values(?,?,?,?,?)";
       try(PreparedStatement pstmt=conn.prepareStatement(sql)){
           pstmt.setInt(1,id);
           pstmt.setString(2,name);
           pstmt.setString(3,sex);
           pstmt.setInt(4,age);
           pstmt.setString(5,college);

           int rowsAffected = pstmt.executeUpdate();
           if (rowsAffected > 0) {
               System.out.println("运动员添加成功！");
           } else {
               System.out.println("运动员添加失败，请检查输入数据。");
           }
       }

    }
    private static void deleteJock(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入运动员ID");
        int id = sc.nextInt();
        String sql = "delete from jock where jockid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)){
            pstmt.setInt(1,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("运动员删除成功！");
            } else {
                System.out.println("运动员删除失败，请检查输入数据。");
            }
        }

    }
    private static void updateJock(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入运动员ID");
        int id = sc.nextInt();
        System.out.println("请输入运动员姓名");
        String name = sc.next();
        System.out.println("请输入运动员性别");
        String sex = sc.next();
        System.out.println("请输入运动员年龄");
        int age = sc.nextInt();
        System.out.println("请输入运动员学院");
        String college = sc.next();
        String sql = "update jock set jockname=?,jocksex=?,jockage=?,departmentid=? where jockid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)) {
            pstmt.setString(1,name);
            pstmt.setString(2,sex);
            pstmt.setInt(3,age);
            pstmt.setString(4,college);
            pstmt.setInt(5,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("运动员修改成功！");
            } else {
                System.out.println("运动员修改失败，请检查输入数据。");
            }

        }

    }
    private static void addCompetition(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入比赛ID");
        int id = sc.nextInt();
        System.out.println("请输入比赛名称");
        String name = sc.next();
        System.out.println("请输入比赛类型");
        String type = sc.next();
        System.out.println("请输入比赛时间");
        String time = sc.next();
        System.out.println("请输入比赛地点");
        String place = sc.next();
        String sql = "insert into events values(?,?,?,?,?)";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)){
            pstmt.setInt(1,id);
            pstmt.setString(2,name);
            pstmt.setString(3,type);
            pstmt.setString(4,time);
            pstmt.setString(5,place);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("比赛添加成功！");
            } else {
                System.out.println("比赛添加失败，请检查输入数据。");
            }
        }

    }
    private static void deleteCompetition(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入比赛ID");
        int id = sc.nextInt();
        String sql = "delete from events where eventid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)){
            pstmt.setInt(1,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("比赛删除成功！");
            } else {
                System.out.println("比赛删除失败，请检查输入数据。");
            }
        }

    }
    private static void updateCompetition(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入比赛ID");
        int id = sc.nextInt();
        System.out.println("请输入比赛名称");
        String name = sc.next();
        System.out.println("请输入比赛类型");
        String type = sc.next();
        System.out.println("请输入比赛时间");
        String time = sc.next();
        System.out.println("请输入比赛地点");
        String place = sc.next();
        String sql = "update events set eventname=?,eventtype=?,eventtime=?,eventlocation=? where eventid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)) {
            pstmt.setString(1,name);
            pstmt.setString(2,type);
            pstmt.setString(3,time);
            pstmt.setString(4,place);
            pstmt.setInt(5,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("比赛修改成功！");
            }
            else {
                System.out.println("比赛修改失败，请检查输入数据。");
            }
        }

    }
    private static void addCollege(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入学院ID");
        int id = sc.nextInt();
        System.out.println("请输入学院名称");
        String name = sc.next();
        System.out.println("请输入学院领队");
        String leader = sc.next();
        String sql = "insert into department values(?,?,?)";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)){
            pstmt.setInt(1,id);
            pstmt.setString(2,name);
            pstmt.setString(3,leader);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("学院添加成功！");
            } else {
                System.out.println("学院添加失败，请检查输入数据。");
           }
       }

    }
    private static void deleteCollege(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入学院ID");
        int id = sc.nextInt();
        String sql = "delete from department where departmentid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)){
            pstmt.setInt(1,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("学院删除成功！");
            } else {
                System.out.println("学院删除失败，请检查输入数据。");
            }
        }

    }
    private static void updateCollege(Connection conn)throws SQLException,ClassNotFoundException
    {
        System.out.println("请输入学院ID");
        int id = sc.nextInt();
        System.out.println("请输入学院名称");
        String name = sc.next();
        System.out.println("请输入学院领队");
        String leader = sc.next();
        String sql = "update department set departmentname=?,leader=? where departmentid=?";
        try(PreparedStatement pstmt=conn.prepareStatement(sql)) {
            pstmt.setString(1,name);
            pstmt.setString(2,leader);
            pstmt.setInt(3,id);
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("学院修改成功！");
            }
            else {
                System.out.println("学院修改失败，请检查输入数据。");
            }
        }

    }
}