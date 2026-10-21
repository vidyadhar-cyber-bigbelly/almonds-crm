public class almd_SyncScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        // Instantiate the batch class
        almd_SyncInventoryBatch batchJob = new almd_SyncInventoryBatch();
        
        // Execute with a batch size of 1. 
        // This ensures 1 Integer offset is passed to the execute method at a time,
        // resulting in exactly 1 API call per batch chunk.
        Database.executeBatch(batchJob, 1);
    }
}