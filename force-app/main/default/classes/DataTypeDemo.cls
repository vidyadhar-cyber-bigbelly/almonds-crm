public class DataTypeDemo {
    public void show(){
        List<Account> acc= [Select id, name from Account limit 2];
        System.debug('Account details: '+ acc);
    }
}