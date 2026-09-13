// ****************** WITHOUT SERVICE COMPONENT *******************************
import { LightningElement, wire } from 'lwc';

import getAllOpp from '@salesforce/apex/OpportunityControllerClass.fetchAllOpp';
import deleteOpp from '@salesforce/apex/OpportunityControllerClass.deleteOpp';

import { refreshApex } from '@salesforce/apex';

// import 'toastMessage' to pass the arguments
// 'c' indicates component
import { toastMessage } from 'c/lwc_eight_ServiceComponent';

export default class Lwc_seven_LdtDelete extends LightningElement {

    columnsList = [
        { label: 'Opportunity Name', fieldName: 'Name' },
        { label: 'Stage Name', fieldName: 'StageName' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency', cellAttributes: { alignment: 'left' } }
    ];

    @wire(getAllOpp) opportunityList;

    selectedRecordId;
    rowSelection;

    handleRowSelection(event) {
        const row = event.detail.selectedRows;
        if (row.length > 0) {
            this.selectedRecordId = row[0].Id;
        }
    }

    handleDelete() {
        deleteOpp({ oppId: this.selectedRecordId })
            .then(() => {
                // calling 'toastMessage' function from service component to display toast messages
                toastMessage('Deletion Successful!', 'Selected Record got deleted.', 'success', 'sticky');
                this.rowSelection = [];
                return refreshApex(this.opportunityList);
            })
            .catch((err) => {
                // calling 'toastMessage' function from service component to display toast messages
                toastMessage('Deletion Unsuccessful!', err.body.message, 'error', 'dismissible');
                this.rowSelection = [];
            });
    }

}


// ****************** WITHOUT SERVICE COMPONENT *******************************
// import { LightningElement, wire } from 'lwc';

// // import apex methods
// // 1. to fetch all the opportunities -> WIRE 
// import getAllOpp from '@salesforce/apex/OpportunityControllerClass.fetchAllOpp';
// // 2. call delete to pass parameter and perfrom deletion -> IMPERATIVE
// import deleteOpp from '@salesforce/apex/OpportunityControllerClass.deleteOpp';

// // import 'refreshApex' -> will be used only with 'wire' service -> to auto refresh the wire property
// import {refreshApex} from '@salesforce/apex';

// // import 'ShowToastEvent' to display the toast message
// import {ShowToastEvent} from 'lightning/platformShowToastEvent'

// export default class Lwc_seven_LdtDelete extends LightningElement {

//     // *** LDT Columns
//     // label: column heading
//     // fieldName: field's api name, it will internally map this fields with data
//     // type: by default it is text, so if we have other than text data type, then we need to explicitly mention
//     // number and currency data types are right-aligned in column, so to shift them LHS, we must add 'align'
//     columnsList = [
//         {label:'Opportunity Name', fieldName:'Name'},
//         {label:'Stage Name', fieldName:'StageName'},
//         {label:'Close Date', fieldName:'CloseDate', type:'date'},
//         {label:'Amount', fieldName:'Amount', type:'currency', cellAttributes:{alignment:'left'}}
//     ];

//     // *** wire property
//     // opportunityList => object => {data,error}
//     @wire(getAllOpp) opportunityList;

//     // *** Property
//     selectedRecordId;   // store the selected row's record Id fetched by JS from DOM page  
//     rowSelection;    // array we have added in html

//     // *** Event Handler
//     // 1. To fetch the Id from DOM Page, upon onrowselection event
//     // to fetch from DOM page we add parameter, for ex: 'event'
//     // when to use event.target? => when we want to fetch user-entered value from input-box
//     // when to use event.detail? => when we want to fetch from DOM event
//     // row: array variable, which stores the selected rows
//     // check wheather array has any value, means wheather user selected row or not
//     // if array has value, then fetch the Id and store it in 'selectedRecordId' variable
//     // row[0].Id; => get the record Id of the first selected record
//     handleRowSelection(event){
//         const row = event.detail.selectedRows;
//         if(row.length>0){
//             this.selectedRecordId = row[0].Id;
//         }
//     }

//     // 2. to pass the Id to apex method, for deletion
//     // apex method has return type 'void', so 'then()' doesnt have any parameter
//     // apex method is throwing an AuraHandledException, will be stored in 'err' variable inside catch
//     // we must parameter(selected row's record Id) to apex
//     // oppId: written in apex method parameter, selectedRecordId: is defined above
//     // oppId = selectedRecordId; means oppId = storing the selected row's record Id
//     handleDelete(){
//         deleteOpp({oppId:this.selectedRecordId})
//         .then(() => {
//             // alert('Deletion Successful!');
//             // Create and dispatch the 'ShowToastEvent'
//             // this.dispatchEvent -> why 'this'? -> bcoz we are dispatching toast message only for current component
//             // by deafult in salesforce the mode is 'dismissible', means it will get dismissed in sometime or after clicking on page/screen.
//             // mode: 'sticky' -> it will stick on the page, until we click on 'x' icon.
//             // variant: success(green), error(red), warning(orange)
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Deletion Successful!',
//                     message: 'Selected Record got deleted.',
//                     variant: 'success',
//                     mode: 'sticky'
//                 })
//             );
//             // make 'rowSelection' empty, to avoid auto-selection of next row, post deletion
//             this.rowSelection=[];
//             // auto refresh wire property(hodling the data), post deletion
//             return refreshApex(this.opportunityList);
//         })
//         .catch((err) => {
//             // alert(err.body.message);
//              this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Deletion Unsuccessful!',
//                     message: err.body.message,
//                     variant: 'error',
//                     mode: 'dismissible'
//                 })
//             );
//             // make 'rowSelection' empty, to avoid auto-selection of the same row, after clicking on 'ok' of alert
//             this.rowSelection=[];
//         });
//     }

// }