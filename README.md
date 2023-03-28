
# Apex Unit Test Utility Class

<a href="https://githubsfdeploy.herokuapp.com/KGFTW/Apex-TestUtils">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Documentation

This unit test utility class helps you instanciate an admin test user (or any other user type), automatically through singletons, on any sandbox or production environment in a generic way.
    
# How to use it ?
It's quite simple, follow these steps:
    
- First initialize a test, admin or whatever user needed in the test Setup of your class
- Call the user singleton as a runAs in every testMethod class.
- Then run your test, test users shall be created automatically based on your org configuration.

Below is an example on a sample code that instanciates and uses the adminUser singleton from the TestUtils class to run the subsequent test.

Please note that the "createTestUser" method can be leveraged to create test users other than admins, however it requires the username to match the "firstname.lastname@domain.com" with a "firstname.lastname" combination that shoudln\'t exceed 8 characters (used for alias field completion with max length matching 8 chars).

```
@testSetup
static void testSetup() {
    User testUser = TestUtils.adminUser;
    insert testUser;

    system.runAs(TestUtils.adminUser) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
    }
}

static testMethod void getAccountTest() {
    system.runAs(TestUtils.adminUser) {
        List<Account> accList = [Select Id
                                    From Account];
        system.assert(!accList.isEmpty(), 'There should be at least one account in the org, check your test setup');

        Account expectedAcc = accList[0];

        test.startTest();
        Account actualAcc = myClass.getAccount(expectedAcc.Id);
        test.stopTest();

        system.assertNotEquals(null, actualAcc);
        system.assertEquals(expectedAcc.Id, actualAcc.Id);
    }
}
```