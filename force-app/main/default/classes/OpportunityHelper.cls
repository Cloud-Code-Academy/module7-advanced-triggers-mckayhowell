/**
 * Opportunity trigger Helper
 * Contains the utility logic called by the OpportunityTriggerHandler
 */
public with sharing class OpportunityHelper {
    /**
     * Set a default Type if none was specified
     * @param newOpps a list of Opportunity records
     */
    public static void setDefaultType(List<Opportunity> newOpps){
        for(Opportunity opp : newOpps){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }
    }

    /**
     * Validate that the amount is greater than 5000
     * @param newOpps a list of Opportunity records
     */
    public static void validateAmount(List<Opportunity> newOpps){
        for(Opportunity opp : newOpps){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    /**
     * Set the primary contact on the opportunity to the contact with the title of 'CEO'
     * @param newOpps a list of Opportunity records
     */
    public static void setPrimaryContact(List<Opportunity> newOpps){
        // Get contacts related to the opportunity account
        /*Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            accountIds.add(opp.AccountId);
        }*/
        Map<Id, Contact> contacts = new Map<Id, Contact>(
            [SELECT Id, FirstName, AccountId
            FROM Contact
            WHERE Title = 'CEO' AND AccountId IN (SELECT AccountId FROM Opportunity WHERE Id IN :newOpps)
            ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : newOpps){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }

    /**
     * Prevent the deletion of Opportunity records that meet specific criteria
     * @param oldOpps a list of Opportunity records
     */
    public static void preventDeleteCheck(List<Opportunity> oldOpps){
        for(Opportunity opp : oldOpps){
            if (opp.IsClosed){
                opp.addError('Cannot delete closed opportunity');
            }
        }
    }

    /**
     * Create a new Task for newly inserted Opportunities
     * @param newOpps a list of Opportunity records
     */
    public static void createOppTasks(List<Opportunity> newOpps){
        List<Task> tasks = new List<Task>();
        for(Opportunity opp : newOpps){
            Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
            tasks.add(tsk);
        }
        insert tasks;
    }

    /**
     * Note any changes to Stage value in the Description
     * @param newOpps a list of Opportunity records containing the new values
     * @param oldOppsMap a map of Opportunity records containing the old values
     */
    public static void updateDescriptionFromStage(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){
        // Append Stage changes in Opportunity Description
        for (Opportunity opp : newOpps){
            if (opp.StageName != null && opp.StageName != oldOppsMap.get(opp.Id).StageName){
                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            }
        }
    }

    /**
     * Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities
     * Only updates the Opportunities that don't already have a primary contact
     * @param newOpps a list of Opportunity records containing the new values
     */
    public static void assignPrimaryContact(List<Opportunity> newOpps) {
        // Build a map of Account Ids and the VP Sales contacts
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId IN (SELECT AccountId FROM Opportunity WHERE Id IN :newOpps)];
        Map<Id,Id> accountToContactMap = new Map<Id,Id>();
        for(Contact con : contacts){
            accountToContactMap.put(con.AccountId, con.Id);
        }
    
        // Assign the primary contact and update
        List<Opportunity> oppsWithContact = new List<Opportunity>();
        for (Opportunity opp : newOpps){
            if (opp.Primary_Contact__c == null && accountToContactMap.get(opp.AccountId) != null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = accountToContactMap.get(opp.AccountId);
                oppsWithContact.add(oppToUpdate);
            }
        }
        update oppsWithContact;
    }

    /**
     * Sends an email notification to the owner of the Opportunity when it gets deleted
     * Uses Salesforce's Messaging.SingleEmailMessage to send the email
     * @param oldOpps a list of Opportunity records containing the old values
     */
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> oldOpps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : oldOpps){
            List<String> toAddresses = new List<String>{opp.OwnerId}; // Can accept User Id as a To Address
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }
}