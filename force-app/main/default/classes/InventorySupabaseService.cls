public with sharing class InventorySupabaseService {

    public static void testConnection() {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(
            'callout:Supabase/rest/v1/products'
        );

        req.setMethod('GET');

        req.setHeader(
            'Content-Type',
            'application/json'
        );

        Http http = new Http();

        HttpResponse res = http.send(req);

        System.debug('Status: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());
    }
}