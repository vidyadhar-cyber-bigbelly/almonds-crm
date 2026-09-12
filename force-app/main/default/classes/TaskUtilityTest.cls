@isTest
public class TaskUtilityTest {
    @isTest static void testTaskPriority(){
        String priority=TaskUtility.taskPriority('UK');
        System.assertEquals('Normal',priority);
    }
    @isTest static void testTaskPriorityHigh(){
        String priority=TaskUtility.taskPriority('US');
        System.assertEquals('High',priority);
    }
    @isTest static void testTaskPriorityNull(){
        String priority=TaskUtility.taskPriority('India');
        System.assertEquals(null,priority);
    }
}