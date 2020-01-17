public class DelinquentAccounts implements Schedulable{
    // used for default schedule -- once a day at 1am
    public static void scheduleMe(){
        String schedule = '0 0 1 * * ?';
        scheduleMe(schedule);
    }
    
    // used to pass in a custom cron string
    public static void scheduleMe(String schedule){
        DelinquentAccounts da = new DelinquentAccounts();
        String jobId = System.schedule('Delinquent Accounts Job', schedule, da);
    }
    
    public void execute(System.SchedulableContext schedulableContext){
        verifyDelinquentAccounts();
        
        flagDelinquentAccounts();
    }
    
    // sets Delinquent_Account__c to true on every account with unpaid orders older than 90 days
    // called from schedule job that runs once a day
    static void flagDelinquentAccounts(){
        List<AggregateResult> ars = [select count(id), accountid AccountId
            from order
            where Paid__c = false 
              and CreatedDate < LAST_90_DAYS 
              and account.delinquent_account__c = false 
              and AccountId != null
         group by Accountid];
        
        Set<Id> accountIds = new set<Id>();
        for (AggregateResult ar : ars){
            accountIds.add((Id)ar.get('AccountId'));
        }
        
        List<Account> delinquentAccounts = [Select Id, Delinquent_Account__c from Account where Id in :accountIds];
        
        for (Account account : delinquentAccounts){
            account.Delinquent_Account__c = true;
        }
        
        update delinquentAccounts;
    }
    
    // checks delinquent accounts to see if they're still delinquent, and un-flags them if not
    // called from scheduled job that runs once a day
    static void verifyDelinquentAccounts(){
        List<Account> delinquentAccounts = [select id,
            (select id 
               from orders 
               where paid__c = false 
                 and CreatedDate < LAST_90_DAYS 
            )
             from account
            where delinquent_account__c = true];
        
        for (Account account : delinquentAccounts){
            if (account.orders.isEmpty()){
                account.Delinquent_Account__c = false;
            }
        }
        
        update delinquentAccounts;
    }

    // called in Order trigger
    public static void checkAccounts(Set<Id> accountIds){
        List<Account> accounts = [Select Id, Delinquent_Account__c, (Select Id from Orders where CreatedDate < LAST_90_DAYS and Paid__c = false) from Account where Id in :accountIds];
        for (Account account : accounts){
            if (account.orders.size() > 0){
                account.Delinquent_Account__C = true;
            }
        }
        update accounts;
    }
}