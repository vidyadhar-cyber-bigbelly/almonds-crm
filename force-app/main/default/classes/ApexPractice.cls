public class ApexPractice {
    public void mainValueMethod(){
        String websiteUrl = 'www.jaswanth.com';
        
        System.debug('Before value call' + websiteUrl);
        passByValueCall(websiteUrl);
        System.debug('After value call' + websiteUrl);
    }
    
    private void passByValueCall(String websiteUrlValue){
        websiteUrlValue = 'www.salesforce.com';
    }
    
    public void mainpassrefmethod(){
        
        Account a = new Account();
        a.name = 'test1';
        a.Website = 'test@gmail.com';
        
        System.debug('Before passing the ref: '+ a.Website);
        passbyrefcall(a);
        System.debug('After passing the ref:' + a.Website);
    }
    
    private void passbyrefcall(Account a){
        a.Website = 'hello@gmail.com';
    }
}