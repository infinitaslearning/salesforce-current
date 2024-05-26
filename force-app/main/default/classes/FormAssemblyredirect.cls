@RestResource(urlMapping='/FormAssembly/*')
global with sharing class FormAssemblyredirect {
    
    global pagereference Buildredirect(){

        String recId =  ApexPages.currentPage().getParameters().get('tfa_5');

        String data = 'tfa_5'+recId; // strip '&' and '=' from string.
        Blob mac = Crypto.generateMac('HMacSHA256', Blob.valueOf(data), Blob.valueOf('07319b458763bd6fade9720257a2ba5f'));
        String sig = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
        String url = 'https://infinitaslearning.tfaforms.net/360?tfa_5='+recId+'&signature=' + sig;

        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    @HttpPost
    global static String doPost(String recId) {

        String data = 'tfa_5'+recId; // strip '&' and '=' from string.
        Blob mac = Crypto.generateMac('HMacSHA256', Blob.valueOf(data), Blob.valueOf('07319b458763bd6fade9720257a2ba5f'));
        String sig = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
        String url = 'https://infinitaslearning.tfaforms.net/360?tfa_5='+recId+'&signature=' + sig;


        return url;
    }
    */

    @HttpPost
    global static List<String> doGet(List<ProcessContacts> ContactIds) {

        List<string> response = new List<String>();

        for(ProcessContacts rec:ContactIds){
            
            String data = 'tfa_5'+rec.recId; // strip '&' and '=' from string.
            Blob mac = Crypto.generateMac('HMacSHA256', Blob.valueOf(data), Blob.valueOf('07319b458763bd6fade9720257a2ba5f'));
            String sig = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');
            String url = 'https://infinitaslearning.tfaforms.net/360?tfa_5='+rec.recId+'&signature=' + sig; 
            
            response.add(url);
        }
        


        return response;
    }

Global class ProcessContacts{

    Public string recId {get;set;}

}


}