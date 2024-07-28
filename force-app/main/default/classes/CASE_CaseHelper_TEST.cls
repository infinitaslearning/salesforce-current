@IsTest
public class CASE_CaseHelper_TEST {
    
    @TestSetup
    static void makeData(){

        // Get Noordhoff Case recordtypeId
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Noordhoff').getRecordTypeId();

        // Get Noordhoff BusinessHoursId
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Noordhoff' LIMIT 1].Id;

        // Create Case
        Case c = new Case();
        c.recordTypeId = recordTypeId;
        c.Status = 'New';
        c.Origin = 'Phone';
        c.CategoryLevel1__c = 'General';
        c.CategoryLevel2__c = 'Assortiment';
        c.BusinessHoursId = businessHoursId;

        insert c;

        // Create 3 Knowledge Articles
        List<knowledge__kav> newArticleList = new List<knowledge__kav>();
        for (Integer i = 0; i < 3; i++) {
            knowledge__kav newArticle = new knowledge__kav();
            newArticle.Title = 'Test Article ' + (i+1);
            newArticle.Content__c = 'Test Content for Article ' + (i+1);
            newArticle.Type__c = 'FAQ';
            newArticle.UrlName = 'testUrl'+(i+1);
            newArticle.OperatingCompany__c = 'Noordhoff';
            newArticle.PrimaryEducation__c = true;
            newArticleList.add(newArticle);
        }
        insert newArticleList;

        // Get knowledgaArticle Ids
        List<Knowledge__Kav> kavList = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav];
        List<CaseArticle> caList = new List<CaseArticle>();
        for (Knowledge__kav k : kavList) {
            
            // publish article
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            
            // Attach Articles to Case
            CaseArticle ca = new CaseArticle();
            ca.caseId = c.Id;
            ca.KnowledgeArticleId = k.KnowledgeArticleId;
            caList.add(ca);
        }
        insert caList;
    }

    @IsTest
    static void Test01(){
        
        List<Case> c = [SELECT Id FROM Case];

        CASE_CaseHelper.parameters param = new CASE_CaseHelper.parameters();
        param.inputCase = c[0];

        List<CASE_CaseHelper.parameters> paramList = new List<CASE_CaseHelper.parameters>();
        paramList.add(param);

        Test.startTest();
            List<Integer> numberOfArticles = CASE_CaseHelper.getNumberOfArticlesFromCase(paramList);
        Test.stopTest();
        
        System.assertEquals(3, numberOfArticles[0], 'We received an incorrect amount of articles, expected: 3, we got: ' + numberOfArticles[0]);
    }

}