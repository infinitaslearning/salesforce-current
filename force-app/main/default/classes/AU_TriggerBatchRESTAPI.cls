@RestResource(urlMapping='/AgodiUpdateTriggerBatch/*')
global with sharing class AU_TriggerBatchRESTAPI {

    // global static List<Id> contetDocumentIdList;
    // global static Id agodiUpdateRecordId;
    
    // @HttpGet
    // global static String doGet() {
    //     System.debug('AU_TriggerBatchRESTAPI-doGet (contentDocumentIdList: ' + contetDocumentIdList + ', agodiUpdateRecordId: ' + agodiUpdateRecordId + ')');

    //     String resp='Success';
    //     try{
    //         AU_processFiles auUpdate = new AU_processFiles(contetDocumentIdList, agodiUpdateRecordId);
    //         database.executebatch(auUpdate ,1);
    //     }
    //     catch(exception e){
    //         resp=e.getmessage();
    //     }
    //     return resp;
    // }
}