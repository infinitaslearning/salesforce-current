public with sharing class Lead_LoopContacts {
    
    
    public class Request{ 
        @invocablevariable Public List<Contact> ContactList;  
    }
    public class Response{ 
        @invocablevariable Public List<Contact> ContactList;            
    }

    @invocablemethod
    public static List<Response> LoopContacts(List<Request> req){
       
        for(Contact con:req[0].ContactList){


        }    

        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.ContactList = req[0].ContactList; 
        responses.add(res);

        return responses;

    }


}