public class restCallout {
    
    Public static void getCallout(){
        HTTP http = new HTTP();
        HTTPRequest req = new HTTPRequest();
        //req.setMethod('GET');
        req.setMethod('POST');
        req.setEndpoint('https://reqres.in/api/users');
        req.setHeader('Context-Type','application/json');
        req.setHeader('x-api-key', 'free_user_3I5DChFEJRS6LEhDSyldAAvzrqD');
        req.setBody('{"data": {"name": "Wireless Headphones","price": 59.99,"category": "Electronics","in_stock": true}}');
        
        HTTPResponse res= new HTTPResponse();
        res = http.send(req);
        System.debug(res.getBody());
        System.debug('StatusCode '+ res.getStatusCode());
        
        
    }

}