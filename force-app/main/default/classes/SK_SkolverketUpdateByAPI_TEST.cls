@IsTest
public class SK_SkolverketUpdateByAPI_TEST {

    @IsTest
    static void TestCorrectResponse01(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SK_TestDataFactory.Mock());
            System.enqueueJob(new SK_SkolverketUpdateByAPI());
        Test.stopTest();
    }

    @IsTest
    static void TestCorrectResponse02(){
        List<SK_SkolverketUpdateByAPI.school> schoolList = new List<SK_SkolverketUpdateByAPI.school>();
        List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList = new List<SK_SkolverketUpdateByAPI.schoolDetails>();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SK_TestDataFactory.Mock());
            System.enqueueJob(new SK_SkolverketUpdateByAPI(schoolList, schoolDetailList));
        Test.stopTest();
    }

    @IsTest
    static void TestIncorrectResponse01(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SK_TestDataFactory.badMock01());
            System.enqueueJob(new SK_SkolverketUpdateByAPI());
        Test.stopTest();
    }

    @IsTest
    static void TestIncorrectResponse02(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SK_TestDataFactory.badMock02());
            System.enqueueJob(new SK_SkolverketUpdateByAPI());
        Test.stopTest();
    }
}