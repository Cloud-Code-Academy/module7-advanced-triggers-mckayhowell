/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.



Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
    /**
     * Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
     * @param accounts The entire set of Accounts contained in Trigger.New
     */
    static public void setTypeProspect(List<Account> accounts){
        /* Since SObjects are passed by reference, setting field values in the loop actually does update
        * the source Sobject and we don't need to return anything to the parent trigger
        */
        for (Account acc : accounts) {
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
        }
    }

    /**
     * Copy the shipping address of the Account to its billing address
     * @param accounts The entire set of Accounts contained in Trigger.New
     */
    static public void addressCopy(List<Account> accounts){
        for (Account acc : accounts) {
            if (acc.ShippingStreet != null) {
                acc.BillingStreet = acc.ShippingStreet;
            }

            if (acc.ShippingCity != null) {
                acc.BillingCity = acc.ShippingCity;
            }

            if (acc.ShippingState != null) {
                acc.BillingState = acc.ShippingState;
            }

            if (acc.ShippingPostalCode != null) {
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }

            if (acc.ShippingCountry != null) {
                acc.BillingCountry = acc.ShippingCountry;
            }
        }
    }

    /**
     * Evaluate certain conditions on the Account and assign a rating based on that evaluation
     * @param accounts The entire set of Accounts contained in Trigger.New
     */
    static public void setRating(List<Account> accounts){
        for (Account acc : accounts) {
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    /**
     * Create a default contact related to the Account after the Account is inserted
     * @param accounts The entire set of Accounts contained in Trigger.New
     */
    static public void defaultContact(List<Account> accounts){
        List<Contact> contacts = new List<Contact>();
        for(Account acc : accounts){
            Contact con = new Contact();
            con.LastName = 'DefaultContact';
            con.Email = 'default@email.com';
            con.AccountId = acc.Id;
            contacts.add(con);
        }
        insert contacts;
    }
}
