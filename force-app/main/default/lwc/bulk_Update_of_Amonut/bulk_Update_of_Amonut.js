import { LightningElement,api } from 'lwc';
import getOpportunities from '@salesforce/apex/Bulk_Opp_update.getOpportunities';
export default class Bulk_Update_of_Amonut extends LightningElement {
@api name ="Vishal";
@api OppName;
@api displayname;
 oppList=[];
 MapList =[];

handleonchangeinput(event){
    
this.OppName= event.target.value;   
this.displayname = this.OppName;
}
handleInputBlur(event){
console.log(this.OppName);
}
connectedCallback() {
getOpportunities()
.then(result=>{
    console.log('Raw result:', result);
    const Mapped=result.map(opp=>({
        id:opp.Id,
        name:opp.Name,
        amount:opp.Amount,
        risk:opp.Risk__c,
        closedate:opp.CloseDate,

    }));
    console.log('test MapList',Mapped);
    this.oppList= Mapped;
    console.log('test',this.oppList.length);
    console.log('test list',this.oppList);
});
}
renderedCallback() {
        console.log('Rendered oppList size:', this.oppList.length);
    }
}