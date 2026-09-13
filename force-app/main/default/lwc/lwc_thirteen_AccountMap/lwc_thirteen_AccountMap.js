import { LightningElement, wire, api } from 'lwc';
// schema: refers the structor of the database -> Objects
// why we imported fields from schema/object: getRecord() should know for which object fields we are fetching the record details.
// Syntax: import PROPERTY from @salesforce/schema/objectApiName.fieldApiName';
// we must use uppercase property for schema, ex: CITY, COUNTRY 
// import schema -> creates the dependency -> ex: now if we try to delete  BillingCity/BillingCountry field from object manager, it will throw error, stating fields are already in use -> this is called as STATIC SCHEMA, which prefered by developers.
import CITY from '@salesforce/schema/Account.BillingCity';
import COUNTRY from '@salesforce/schema/Account.BillingCountry';

// import LDS Adaptors
// getRecord: to fetch the specific record data, it works best with wire adaptor
// getFieldValue: a helper function to fetch the actual/raw data returned by specific field
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class Lwc_thirteen_AccountMap extends LightningElement {

    // property
    locationIndicator;
    // 1. user-defined record Id variable, ex: accId, conId, etc. -> when we are using this record Id in HTML, or if we are assigning values directly in JS, for ex: received by subscriber, fetched from DOM page event(like onrowselection).
    // 2. standard salesforce record Id variable, ex: recordId -> case-sensitive -> when we are fetching the record-Id dynamically/at run-time from objects record page.  
    // why @api? -> because here we are fetching record Id from salesforce org, not defining within component, so this variable should be accessible in org, means outside this component, thats we added @api + isExposed=true, making access specifier for record Id as 'global'.
    @api recordId;

    // LDS adaptor, getRecord() works best with wire, we cannot use it imperatively inside handler
    // we will use wire method
    // getRecord() have 2 standard parameters: recordId, fields
    // here '$recordId' -> we defined above at line no 22, and made it dynamic, so that it can fetch Id's during run-time. 
    // fields:[CITY,COUNTRY]: from specific record(whose Id is provided in '$recordId') we need details from 'CITY' and 'COUNTRY' fields.
    @wire(getRecord,{recordId:'$recordId', fields:[CITY,COUNTRY]}) displayMap({ data, error }) {
        if (data) {
            // data: holds record data for both 'CITY' and 'COUNTRY' fields.
            // from data we are seggricating city and country values seperatly using getFieldValue.
            // getFieldValue(data,CITY): from data returned by getRecord(), get the value present at 'CITY' field, likewise for country also.
            const accCity = getFieldValue(data,CITY);
            const accCountry = getFieldValue(data,COUNTRY);
            // now define the location
            // location: mandatory attribute, City and Country are the standard attributes.
            // we can define, location:{accCity,accCountry} -> this way also allowed
            this.locationIndicator = [
                {
                    title : 'Map',
                    description : 'This is '+accCity+ ' from '+accCountry,
                    location : {City:accCity, Country:accCountry}
                }
            ];
        }
        else if (error) {
            // error is in the JSON format
            console.log(JSON.stringify(error)); // converts error message from JSON format into String/text
        }
    }
}


// FETCH THE DATA IN LWC
// 1. Using Apex: Calling Apex Method -> Wire and Imperative
// 2. Base Lightning Components -> record-view form, record-edit form, record form
// 3. JavaScript Fetch API -> using third-party external API
// 4. Lightning Data Service(LDS) -> getRecord(), getFieldValue()