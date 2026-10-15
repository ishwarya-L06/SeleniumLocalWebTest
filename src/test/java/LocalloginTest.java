import java.io.File;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;

import org.openqa.selenium.chrome.ChromeOptions;


public class LocalloginTest {

    WebDriver driver;

    @BeforeMethod
    public void setUp() {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless=new");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--window-size=1920,1080");

        driver = new ChromeDriver(options);

        String page = new File("webpage/login.html")
                .getAbsoluteFile()
                .toURI()
                .toString();

        driver.get(page);
    }

    @Test
    public void validLoginTest() {
        driver.findElement(By.id("username")).sendKeys("student");
        driver.findElement(By.id("password")).sendKeys("12345");
        driver.findElement(By.id("loginButton")).click();

        String message = driver.findElement(By.id("message")).getText();
        Assert.assertTrue(
                message.toLowerCase().contains("success"),
                "Expected a successful login message"
        );
    }

    @Test
    public void invalidLoginTest() {
        driver.findElement(By.id("username")).sendKeys("wrongUser");
        driver.findElement(By.id("password")).sendKeys("wrongPass");
        driver.findElement(By.id("loginButton")).click();

        String message = driver.findElement(By.id("message")).getText();
        Assert.assertTrue(
                message.toLowerCase().contains("invalid"),
                "Expected an invalid login message"
        );
    }

    @Test
    public void blankLoginTest() {
        // Leaving fields blank and clicking login
        driver.findElement(By.id("loginButton")).click();

        String message = driver.findElement(By.id("message")).getText();
        Assert.assertTrue(
                message.toLowerCase().contains("required") || message.toLowerCase().contains("invalid"),
                "Expected a validation message for blank fields"
        );
    }

    @AfterMethod
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
