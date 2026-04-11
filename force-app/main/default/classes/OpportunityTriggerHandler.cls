/**
 * Opportunity Trigger Handler
 * Extends the virtual TriggerHandler framework class and overrides the context methods
 * TriggerHandler Source: https://github.com/kevinohara80/sfdc-trigger-framework
 * @see <a href="https://www.apexhours.com/trigger-framework-in-salesforce/">Trigger Frameworks in Salesforce</a>
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    /***************************************
     * CONSTRUCTOR
     ***************************************/
    private List<Opportunity> newOpps;
    private List<Opportunity> oldOpps;
    private Map<Id, Opportunity> oldOppsMap;
    public OpportunityTriggerHandler() {
        // Constructor takes care of the necessary type casting for Trigger context variables referenced in a class
        this.newOpps = (List<Opportunity>) Trigger.new;
        this.oldOpps = (List<Opportunity>) Trigger.old;
        this.oldOppsMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    /***************************************
     * HANDLER METHODS
     ***************************************/
    /**
     * BEFORE_INSERT
     */
    public override void beforeInsert(){
        OpportunityHelper.setDefaultType(newOpps);
    }

    /**
     * BEFORE_UPDATE
     */
    public override void beforeUpdate(){
        OpportunityHelper.validateAmount(newOpps);
        OpportunityHelper.setPrimaryContact(newOpps);
        OpportunityHelper.updateDescriptionFromStage(newOpps, oldOppsMap);
    }

    /**
     * BEFORE_DELETE
     */
    public override void beforeDelete(){
        OpportunityHelper.preventDeleteCheck(oldOpps);
    }

    /**
     * AFTER_INSERT
     */
    public override void afterInsert(){
        OpportunityHelper.createOppTasks(newOpps);
    }

    /**
     * AFTER_DELETE
     */
    public override void afterDelete(){
        OpportunityHelper.notifyOwnersOpportunityDeleted(oldOpps);
    }

    /**
     * AFTER_UNDELETE
     */
    public override void afterUndelete(){
        OpportunityHelper.assignPrimaryContact(newOpps);
    }
}