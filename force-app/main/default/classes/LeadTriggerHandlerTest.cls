/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class LeadTriggerHandlerTest {

    @isTest
    public static void handleTitleNormalizationCorrectionUnitTest() {
        
        // Create leads with various titles that should be normalized
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'firstName' + i; 
            lead.LastName = 'lastName' + i;
            lead.Company = 'company' + i;

            if (lead.FirstName.contains('1') || lead.FirstName.contains('7')) {
                lead.title = 'vp';
            } else if (lead.FirstName.contains('2') || lead.FirstName.contains('8')) {
                lead.title = 'mgr';
            } else if (lead.FirstName.contains('3') || lead.FirstName.contains('9')) {
                lead.title = 'exec';
            } else if (lead.FirstName.contains('4') || lead.FirstName.contains('0')) {
                lead.title = 'assist';
            }

            leads.add(lead);
        }

        insert leads;

        //Test.startTest();
            LeadTriggerHandler.handleTitleNormalization(leads);
        //Test.stopTest();

        // Query the inserted leads to verify that the titles were normalized correctly
        List<Lead> insertedVPLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName7' 
            LIMIT 1
        ];
        Assert.areEqual('Vice President', insertedVPLeads[0].Title, 'The title should be normalized to \'Vice President\'');

        List<Lead> insertedManagerLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName8' 
            LIMIT 1
        ];
        Assert.areEqual('Manager', insertedManagerLeads[0].Title, 'The title should be normalized to \'Manager\'');
        
        List<Lead> insertedExecutiveLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName9' 
            LIMIT 1
        ];
        Assert.areEqual('Executive', insertedExecutiveLeads[0].Title, 'The title should be normalized to \'Executive\'');

        List<Lead> insertedAssistLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName0' 
            LIMIT 1
        ];
        Assert.areEqual('Assistant', insertedAssistLeads[0].Title, 'The title should be normalized to \'Assistant\'');

    }


    @isTest
    public static void handleTitleNormalizationNoCorrectionUnitTest() {

        // Create leads with various titles that should NOT be normalized
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'firstName' + i; 
            lead.LastName = 'lastName' + i;
            lead.Company = 'company' + i;

            if (lead.FirstName.contains('1') || lead.FirstName.contains('7')) {
                lead.title = 'test';
            } else if (lead.FirstName.contains('2') || lead.FirstName.contains('8')) {
                lead.title = 'no title';
            } else if (lead.FirstName.contains('3') || lead.FirstName.contains('9')) {
                lead.title = 'junior';
            } else if (lead.FirstName.contains('4') || lead.FirstName.contains('0')) {
                lead.title = 'senior';
            }

            leads.add(lead);
        }

        insert leads;

        //Test.startTest();
            LeadTriggerHandler.handleTitleNormalization(leads);
        //Test.stopTest();

        // Query the inserted leads to verify that the titles were NOT normalized and remain unchanged
        List<Lead> insertedTestLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName7' 
            LIMIT 1
        ];
        Assert.areEqual('test', insertedTestLeads[0].Title, 'The title should be \'test\'');

        List<Lead> insertedNoTitleLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName8' 
            LIMIT 1
        ];
        Assert.areEqual('no title', insertedNoTitleLeads[0].Title, 'The title should be \'no title\'');
        
        List<Lead> insertedJuniorLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName9' 
            LIMIT 1
        ];
        Assert.areEqual('junior', insertedJuniorLeads[0].Title, 'The title should be \'junior\'');

        List<Lead> insertedSeniorLeads = [
            SELECT Id, Title 
            FROM Lead 
            WHERE LastName LIKE 'LastName0' 
            LIMIT 1
        ];
        Assert.areEqual('senior', insertedSeniorLeads[0].Title, 'The title should be \'senior\'');

    }

    @isTest
    public static void handleAutoLeadScoringUpdateScoreUnitTest() {

        // Create leads with various attributes that should contribute to lead scoring
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'firstName' + i; 
            lead.LastName = 'lastName' + i;
            lead.Company = 'company' + i;

            if (lead.FirstName.contains('1') || lead.FirstName.contains('7')) {
                lead.LeadSource = 'Web';
                lead.Email = 'test' + i + '@' + lead.Company + '.com';
            } else if (lead.FirstName.contains('2') || lead.FirstName.contains('8')) {
                lead.Phone = '1234567890';
            } else if (lead.FirstName.contains('3') || lead.FirstName.contains('9')) {
                lead.Industry = 'Technology';
            } else if (lead.FirstName.contains('4') || lead.FirstName.contains('0')) {
                lead.LeadSource = 'Web';
                lead.Email = 'test' + i + '@' + lead.Company + '.com';
                lead.Phone = '1234567890';
                lead.Industry = 'Technology';
            }

            leads.add(lead);
        }

        insert leads;

        //Test.startTest();
            LeadTriggerHandler.handleAutoLeadScoring(leads);
        //Test.stopTest();

        // Query the inserted leads to verify that the lead scores were calculated correctly based on the specified criteria
        List<Lead> insertedWebLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName7' 
            LIMIT 1
        ];
        Assert.areEqual(3, insertedWebLeads[0].Lead_Score__c, 'The lead score should be 3');

        List<Lead> insertedPhoneLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName8' 
            LIMIT 1
        ];
        Assert.areEqual(5, insertedPhoneLeads[0].Lead_Score__c, 'The lead score should be 5');
        
        List<Lead> insertedTechnologyLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName9' 
            LIMIT 1
        ];
        Assert.areEqual(10, insertedTechnologyLeads[0].Lead_Score__c, 'The lead score should be 10');

        List<Lead> insertedMaxScoreLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName0' 
            LIMIT 1
        ];
        Assert.areEqual(18, insertedMaxScoreLeads[0].Lead_Score__c, 'The lead score should be 18');

    }


    @isTest
    public static void handleAutoLeadScoringNoUpdateUnitTest() {

        // Create leads with attributes that do not meet any of the scoring criteria
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'firstName' + i; 
            lead.LastName = 'lastName' + i;
            lead.Company = 'company' + i;

            if (lead.FirstName.contains('1') || lead.FirstName.contains('7')) {
                lead.LeadSource = 'Website';
                lead.Email = 'test' + i + '@' + lead.Company + '.com';
            } else if (lead.FirstName.contains('2') || lead.FirstName.contains('8')) {
                lead.Email = 'test' + i + '@' + lead.Company + '.com';
            } else if (lead.FirstName.contains('3') || lead.FirstName.contains('9')) {
                lead.Industry = 'Other';
            } 

            leads.add(lead);
        }

        insert leads;

        //Test.startTest();
            LeadTriggerHandler.handleAutoLeadScoring(leads);
        //Test.stopTest();

        // Query the inserted leads to verify that the lead scores were not updated and remain at their default value (assuming default is 0) since they do not meet any of the specified criteria
        List<Lead> insertedWebLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName7' 
            LIMIT 1
        ];
        Assert.areEqual(0, insertedWebLeads[0].Lead_Score__c, 'The lead score should be 0');

        List<Lead> insertedEmailLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName8' 
            LIMIT 1
        ];
        Assert.areEqual(0, insertedEmailLeads[0].Lead_Score__c, 'The lead score should be 0');
        
        List<Lead> insertedOtherSourceLeads = [
            SELECT Id, Lead_Score__c
            FROM Lead 
            WHERE LastName LIKE 'LastName9' 
            LIMIT 1
        ];
        Assert.areEqual(0, insertedOtherSourceLeads[0].Lead_Score__c, 'The lead score should be 0');

    }


    @isTest
    public static void handleLeadAutoConvertOneMatchUnitTest() {
        // Create a account
        Account account = new Account();
        account.Name = 'TestCompany';
        insert account;

        // Create a contact
        Contact contact = new Contact();
        contact.FirstName = 'John';
        contact.LastName = 'Doe';
        contact.Email = 'john.doe@testcompany.com';
        contact.AccountId = account.Id;
        insert contact;

        List<Lead> leads = new List<Lead>();

        // Create a lead with an email that matches the contact's email
        Lead lead = new Lead();
        lead.FirstName = 'John';
        lead.LastName = 'Doe';
        lead.Company = 'TestCompany';
        lead.Email = 'john.doe@testcompany.com';
        leads.add(lead);

        Test.setMock(HttpCalloutMock.class, new DummyJSONCalloutMockGenerator());
        Test.startTest();
        insert leads;
        Test.stopTest();

        // Query the lead to verify that it was converted
        Lead convertedLead = [
            SELECT Id, FirstName, LastName, Email, IsConverted, ConvertedContactId, ConvertedAccountId
            FROM Lead
            WHERE Email = 'john.doe@testcompany.com' AND IsConverted = true
        ];

        Assert.areEqual(convertedLead.ConvertedContactId, contact.Id, 'The contact Id should be the same');
        Assert.areEqual(convertedLead.ConvertedAccountId, account.Id, 'The account Id should be the same');
    }


    @isTest
    public static void handleLeadAutoConvertTwoMatcheshUnitTest() {
        // Create a account
        Account account = new Account();
        account.Name = 'TestCompany';
        insert account;

        // Create first contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'John';
        contact1.LastName = 'Doe';
        contact1.Email = 'j.doe@testcompany.com';
        contact1.AccountId = account.Id;
        insert contact1;

        // Create second contact
        Contact contact2 = new Contact();
        contact2.FirstName = 'Jane';
        contact2.LastName = 'Doe';
        contact2.Email = 'J.Doe@testcompany.com';
        contact2.AccountId = account.Id;
        insert contact2;

                // Create third contact
        Contact contact3 = new Contact();
        contact3.FirstName = 'Jane';
        contact3.LastName = 'Doe';
        contact3.Email = 'J.Doe@testcompany.com';
        contact3.AccountId = account.Id;
        insert contact3;

        List<Lead> leads = new List<Lead>();

        // Create a lead with an email that matches the contacts email
        Lead lead = new Lead();
        lead.FirstName = 'John';
        lead.LastName = 'Doe';
        lead.Company = 'TestCompany';
        lead.Email = 'J.Doe@testcompany.com';
        leads.add(lead);

        Test.setMock(HttpCalloutMock.class, new DummyJSONCalloutMockGenerator());
        Test.startTest();
        insert leads;
        Test.stopTest();

        // Query the lead to verify that it was converted
        Lead nonConvertedLead = [
            SELECT Id, FirstName, LastName, Email, IsConverted, ConvertedContactId, ConvertedAccountId
            FROM Lead
            WHERE Email = 'j.doe@testcompany.com' AND IsConverted = false
        ];

       Assert.areEqual(nonConvertedLead.IsConverted, false, 'The lead should not be converted');
       Assert.areEqual(nonConvertedLead.ConvertedContactId, null, 'The contact Id should be null');
       Assert.areEqual(nonConvertedLead.ConvertedAccountId, null, 'The account Id should be null');
    }

}

