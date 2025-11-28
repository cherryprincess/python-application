import unittest
from selenium import webdriver
from selenium.webdriver.common.by import By
import xmlrunner

class TestFlaskAppHomePage(unittest.TestCase):
    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')  # Run in headless mode
        self.driver = webdriver.Chrome(options=options)
        self.driver.implicitly_wait(10)
        
        # Replace with your actual external IP or DNS name
        self.app_url = "http://4.236.7.116:3001//"
        self.driver.get(self.app_url)

    def test_homepage_text(self):
        # Verifies that the message is shown in the body
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        expected_text = "Hello World! Welcome to the python_flask demo website."
        self.assertIn(expected_text, body_text)

    def tearDown(self):
        self.driver.quit()

if __name__ == "__main__":
    with open("selenium-test-results.xml", "wb") as output:
        unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output))
