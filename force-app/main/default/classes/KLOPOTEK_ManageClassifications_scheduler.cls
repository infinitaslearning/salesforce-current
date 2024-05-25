/*/
*   @ Created By: Jannes Kleerebezem
*   @ Created on: 25-03-2022
*
*   Use: 
*   Used to schedule the Klopotek Classifications batch job.
*
*   EXAMPLE:
*   KLOPOTEK_ManageClassifications_scheduler kmcScheduled = new KLOPOTEK_ManageClassifications_scheduler();
*   String sch = '0 0 01 * * ? *'; // seconds minutes hours day_of_month month day_of_week optional_year
*   String jobId = system.schedule('Klopotek Classifications management - daily', sch, kmcScheduled);
/*/

global class KLOPOTEK_ManageClassifications_scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        KLOPOTEK_ManageClassifications_Batch kmc = new KLOPOTEK_ManageClassifications_Batch();
        Database.executeBatch(kmc, 50);
    }
}