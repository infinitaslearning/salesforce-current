@RestResource(urlMapping='/B2BTriggerBatch/*')
global with sharing class Order_B2BTriggerBatchRESTAPI {
    @HttpGet
    global static String doGet() {
        
        String resp='Success';
        try{
            Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
            database.executebatch(B2BOrders ,1);
        }
        catch(exception e){
            resp=e.getmessage();
        }

        return resp;
    }


@invocablemethod
public static void startBatch(){
    AsyncApexJob[] ajob =[select Id,ApexClass.Name,createddate,status from AsyncApexJob where ApexClass.Name ='Order_BatchUpdateB2BOrders' AND (status = 'Processing' OR status = 'Queued' OR status = 'Holding' OR status = 'Preparing')];

    System.debug('*****'+ajob.size() );
    if(ajob.size() < 1){
        Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
        database.executebatch(B2BOrders ,1);
    }
    
}

}