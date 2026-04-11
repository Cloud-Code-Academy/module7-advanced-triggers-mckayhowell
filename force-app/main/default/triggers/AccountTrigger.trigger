/**
 * Account Trigger
 * Uses an AccountHelper class to shift most logic out of the trigger
 */
trigger AccountTrigger on Account (before insert, after insert) {

    /*
    * BEFORE_INSERT
    */
    if (Trigger.isBefore && Trigger.isInsert) {
        // Change the account type to 'Prospect' if there is no value in the type field
        AccountHelper.setTypeProspect(Trigger.new);

        // Copy the shipping address to the billing address
        AccountHelper.addressCopy(Trigger.new);

        // Set the rating to 'Hot' if the Phone, Website, and Fax is not empty
        AccountHelper.setRating(Trigger.new);
    }
    
    /*
    * AFTER_INSERT
    */    
    if(Trigger.isAfter && Trigger.isInsert){
        // Create a contact related to the account with default values
        AccountHelper.defaultContact(Trigger.new);
    }
}