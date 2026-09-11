import { LightningElement,wire ,track } from 'lwc';
import getContacts from '@salesforce/apex/GetData.getContacts'
import getAccounts from '@salesforce/apex/GetData.getAccounts'
import updateContacts from '@salesforce/apex/GetData.updateContacts'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class Show_contacts extends LightningElement {

@track contacts = [];
@track error = false;
@track contactName;
@track editedContacts={};
@track accountOptions = [];
@track accsearchTerm ;
    @wire(getAccounts,{searchTerm : '$accsearchTerm'})
    wiredAccount({data,error}){
        if(data){
            this.accountOptions = data.map(acc=>({
                label :acc.Name,
                value :acc.Id
            }));
          
        }
        else if (error){
            this.error = true;
            this.errormessage= error.body.message;
        }
        console.log("wiredAccount",JSON.stringify(this.accountOptions));
    } 
    @wire(getContacts)
    wiredContact(result){
        this.wiredresult=result;
       const {data, error} = result;
        if (data){
            console.log("data",JSON.stringify(this.data) );
            this.contacts = data.map(c=> ({...c,
            AccountName : c.Account?.Name??'No Account',
            Name : c.Name,
            Title: c.Title,
            Email: c.Email,
            Phone: c.Phone,
            AccountId: c.AccountId,
            MobilePhone:c.MobilePhone,
            readonly:true
            }));
            console.log(JSON.stringify(this.contacts) );
        }
        else if (error){
           this.error = true ;
           this.errormessage = error.body.message; 
        }
    }
    get hasContacts(){
        return !this.error && this.contacts.length>0;
    }
    get hasAccounts(){
        return this.accountOptions.length>0 && this.accountOptions != null ;
    }
    onchangeName(event){
    this.contactName = event.target.value;
    }
    
    fieldChange(event){
    const contactId=event.target.dataset.id;
    const field=event.target.dataset.field;
    const value=event.target.value;
     console.log('id',contactId);

    this.editedContacts ={
        ...this.editedContacts,
        [contactId]:{
            ...this.editedContacts[contactId],
            [field]:value
        }
    }

    }
    accountSearch(event){
        
        const accName = event.target.value;
        this.accsearchTerm = accName;
        console.log("accountSearch",this.accsearchTerm);
    }
    
   handleEdit(event){
   const clickedcontactId=event.target.dataset.id;
   
   this.contacts= this.contacts.map(c=>({
    ...c,
    readonly:  c.Id == clickedcontactId? false:true
   })
   );

   }
    async handleSave(){
    console.log(JSON.stringify(this.editedContacts));
    const contactsToSave = Object.keys(this.editedContacts).map(id => ({
        Id: id,
        ...this.editedContacts[id]
    }));
    console.log('Saving:', JSON.stringify(contactsToSave));
    try{
        await updateContacts({contacts: contactsToSave});
        this.dispatchEvent( new ShowToastEvent({
            title : 'Success',
            variant :'success',
            message : 'Updated contacts successfully'
        }));
        this.editedContacts={};
       await refreshApex (this.wiredContact);
    }
    catch (error){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body.message,
            variant : 'error'
        }))
    }
    }
    
   
}