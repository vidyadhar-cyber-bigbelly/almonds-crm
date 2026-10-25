public without sharing class almd_paiBatchSyncHelper {
	
    public class SupabaseInventory {
        public String product_code;
        public String product_name;
        public String category;
        public String subCategory;
        public String manufacturer;
        public Integer quantity;
        public String description;
        public boolean active;	
        public double unit_price;
    }
    
    public class syncResult {
        public Integer insertedCount = 0;
        public Integer updatedCount = 0;
        public Integer skippedCount = 0;
        public Integer failedCount = 0;
        
        public List<String> errors = new List<String>();
        
        public String getMessage() {
            return 'Sync completed. ' +
                'Inserted: ' + insertedCount +
                ', Updated: ' + updatedCount +
                ', Skipped: ' + skippedCount +
                ', Failed: ' + failedCount;
        }
    }
}