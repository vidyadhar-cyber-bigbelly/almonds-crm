public class TaskUtility {
    public static String taskPriority(String leadingCountry){
        if(String.isBlank(leadingCountry) || leadingCountry.length()>2)
            return null;
        String priority;
        if(leadingCountry == 'US')
            priority='High';
        else
            priority = 'Normal';
        return priority;
    }
}