@RestResource(Urlmapping='/babaiInbound')
global class inboundApexRest {
    @httpGet
    global static void inboundGetMethod(){
        RestRequest req = RestContext.Request;
        RestResponse res = RestContext.Response;
        String body = req.requestBody.toString();
    }

}