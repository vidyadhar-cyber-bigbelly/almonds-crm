import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccounts from '@salesforce/apex/account_data.getAccountrecords'
const COLUMNS =[
        {label: 'Name' , fieldName :'recordLink' , 
        type :'url',
         typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }, sortable :true},
        {label: 'Account Number' , fieldName :'AccountNumber' , type :'text', sortable :true},
        {label: 'Industry' , fieldName :'Industry' , type :'text'},
        {label: 'Phone' , fieldName :'Phone' , type :'phone'},
        {
        type: 'action',
        typeAttributes: { rowActions: [
            { label: 'View', name: 'view' },
            { label: 'Edit', name: 'edit' }
        ]}
    }
        
    ];

export default class Account_Data_table extends NavigationMixin(LightningElement) {
    @track accounts =[];
    @track error;
    columns=COLUMNS;
    isNew= false;
    
    @wire(getAccounts)
        wiredAccounts({data, error}){
            if(data){
                this.accounts= data.map(row=>({
                    ...row,
                    recordLink: '/' + row.Id
                }));
            }
            else if(error){
                this.error=true;
            }
        }
    
  get hasAccounts(){
   return !this.error && this.accounts.length >0;
  }

  handleRowSelection(event){
    const selectedRows= event.detail.selectedRows;
    console.log(JSON.stringify(selectedRows));
  }


  handleActions(event){
    const action = event.detail.action.name;
    const row = event.detail.row;
    console.log(JSON.stringify(event.detail));

    switch (action) {
        case 'view':
            this.navigateToRecord(row.Id, 'view');
            break;

        case 'edit':
            this.navigateToRecord(row.Id, 'edit');
            break;

        default:
            break;
    }



  }
  navigateToRecord(recordId,mode){
    console.log(recordId);
    if(mode=='view'){
        window.open('/'+recordId,'_blank');
    }
    else if(mode=='edit'){
        this[NavigationMixin.Navigate]({
            type : 'standard__recordPage',
            attributes :{
                actionName:mode,
                recordId: recordId,
                objectApiName:'account'

            }
        });
    }
}
  handleNew(){
    this.isNew= true;
    console.log( this.isNew);
  }
  closeNewModal(){
    return this.isNew= false;
  }
}