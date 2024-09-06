import java.sql.SQLException;
import java.util.Scanner;

public class main {
        static final Scanner sc = new Scanner(System.in);
        public static void main(String[] args) throws SQLException, ClassNotFoundException {
            int choose = choosemenu();
            switch (choose)
            {
                case 1:
                    System.out.println("管理系统登录");
                    Admin.adminlog(args);
                    break;
                case 2:
                    System.out.println("裁判登录");
                    Referee.refereelog(args);
                    break;
                    case 3:
                    System.out.println("运动员登录");
                    Jock.jocklog(args);
                    break;
                case 4:
                    System.out.println("退出系统");
                    break;
                default:
                    System.out.println("输入错误");
            }
        }
        private static int choosemenu()
        {
            System.out.println("欢迎使用江苏大学运动会管理系统");
            System.out.println("请选择你的职务");
            System.out.println("1.管理员");
            System.out.println("2.裁判");
            System.out.println("3.运动员");
            System.out.println("4.退出");
            return  sc.nextInt();
        }
    }


