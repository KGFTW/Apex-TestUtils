/*
@className    TestUtils
@testClass    None
@description  This is a unit test utility class that serves the purpose of creating an admin test user.
@author		  KG
@todo		  None.
*/
@isTest
public class TestUtils  {

    static final String PROD_ENVIRONMENT = 'Production';
    static final String SANDBOX_NAME_PREFIX = '--';
    static final String SANDBOX_NAME_END = '.';
    static final String TEST_USERNAME = 'f.lname@clientName.com';

   /**
    * @return The sandbox prefix when available
    */
    static String sandboxName {
        get {
            if(sandboxName == null) {
                String hostName = System.Url.getSalesforceBaseUrl().getHost();
                sandboxName = PROD_ENVIRONMENT; 

                if(isSandbox(hostName)){
                    Integer startIndex = hostName.indexOf(SANDBOX_NAME_PREFIX) + SANDBOX_NAME_PREFIX.length();
                    Integer endIndex = hostName.indexOf(SANDBOX_NAME_END);
                    sandboxName = hostName.mid(startIndex, endIndex-startIndex);
                }
            }
            system.debug('Sandbox name: ' + sandboxName);
            return sandboxName;
        }
        private set;
    }

   /**
    * @return true if the hostname contains the SANDBOX_NAME_PREFIX i.e. '--'
    */
    static Boolean isSandbox(String hostName){
        return hostName.indexOf(SANDBOX_NAME_PREFIX) != -1;
    }


    /**
     * @return the org instance based on the current organization
     */ 
    static Organization orgInstance {
        get {
            if(orgInstance == null) {
                List<Organization> orgList = [SELECT LanguageLocaleKey, TimeZoneSidKey, DefaultLocalesidkey 
                                              FROM Organization 
                                              LIMIT 1];
                system.assert(!orgList.isEmpty(), 'No org found in the org, there\'s a big problem here.');
                orgInstance = !orgList.isEmpty() ? orgList[0] : null;
            }
            return orgInstance;
        }
        private set;
    }

    /**
     * @return the existing system admin profile from the environment
     * This profile should be the first ever admin profile created on it by the system
     */ 
    static Id adminProfileId {
        get {
            if(adminProfileId == null) {
                List<Profile> pList = [SELECT Id, createddate 
                                       FROM Profile 
                                       WHERE Name LIKE '%admin%' 
                                       ORDER BY CreatedDate ASC 
                                       LIMIT 1];
                system.assert(!pList.isEmpty(), 'No admin profile found in the org.');
                adminProfileId = pList[0].Id;
            }
            return adminProfileId;
        }
        private set;
    }

    /**
     * @return an admin test user instance based on the first admin profile of the environment, the test username variable, and the sandbox name
     */
    static User createAdminUser() {
        return createTestUser(adminProfileId, TEST_USERNAME, sandboxName);
    }


    /**
     * @return an admin test user instance based on the test username variable, and the sandbox name.
     */
    static User getAdminUser() {
        String userName = TEST_USERNAME + '.' + sandboxName;
        User tmpUser = getTestUser(userName);
        if(tmpUser == null) {
            tmpUser = createAdminUser();
        }
        return tmpUser;
    }

    /**
     * @param username: username of the user to retrieve 
     * @return a user matching the provided username parameter
     */ 
    public static User getTestUser(String username) {
        List<User> uList = [SELECT Id, Name, Email, Username 
                            FROM User 
                            WHERE Username = :username 
                            LIMIT 1];
        User tmpUser = !uList.isEmpty() ? uList[0] : null;
        System.Debug('Found Test User: ' + tmpUser);
        return tmpUser;
    }

    /**
     * adminUser SingleTon
     * @return an admin test user instance, either instanciating it or getting an existing one 
     */ 
    public static User adminUser {
        get {
            if(adminUser == null) {
                adminUser = getAdminUser();
            }
            return adminUser;
        }
       private set;
    }

    /**
     * @param profileId: id of the profile to create a test user for
     * @param username: username of the test user to create, must match the "firstname.lastname@domain.com" pattern
     * @param sandboxName: name of the sandbox to use as a last parameter in the username
     * 
     */ 
    public static User createTestUser(Id profileId, String username, String sandboxName) {
        system.assert(username.contains('@'), 'Username doesn\'t match the expected email pattern, define an \'@\' in it.');
        system.assert(username.substringBefore('@').contains('.'), 'Username doesn\'t match the expected pattern, define a \'firstname.lastname@email.com\' format');
        system.assert(username.substringBefore('@').length() <= 8, 'firstname.lastname combination shoudln\'t exceed 8 characters (used for alias field completion with max length matching 8 chars)');
        User tmpUser = new User();
        tmpUser.firstName = userName.substringBefore('.');
        tmpUser.lastName = userName.substringBetween('.','@');
        tmpUser.Alias = tmpUser.FirstName + '.' + tmpUser.LastName;
        tmpUser.email = userName;
        tmpUser.Username = userName + '.' + sandboxName;
        tmpUser.profileId = profileId;
        tmpUser.TimeZoneSidKey = orgInstance.TimeZoneSidKey;
        tmpUser.LocaleSidKey = orgInstance.DefaultLocalesidkey;
        tmpUser.EmailEncodingKey = 'UTF-8';
        tmpUser.LanguageLocaleKey = orgInstance.LanguageLocaleKey;
        System.Debug('Instanciated Test User: ' + tmpUser);
        return tmpUser;
    }
}