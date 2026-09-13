import { LightningElement } from 'lwc';
export default class Lwc_fourteen_VN_parent extends LightningElement {
    // Property
    receivedItemName;

    // Event Handler
    // event: custom event details
    handleDemo(event){
        this.receivedItemName = event.detail.message;   // receivedItemName = 'name' of the selected item
    }
    // this.receivedItemName = "wireM"

    // Getter Properties
    /* Syntax:
    get propertyName(){
        return boolean;    // true/false
    }
    */
    // LHS: receivedItemName; defined above, has received name value of the item
    // RHS: Actual name item values copied from child html
    // this comparision will pass true or false value.
    get dispProperty(){
        return this.receivedItemName == 'dispMsg';   // false
    }
    get calProperty(){ 
        return this.receivedItemName == 'simpCal';    // false
    }
    get wirePropProperty(){
        return this.receivedItemName == 'wireProp';   // false
    } 
    get wireMethProperty(){
        return this.receivedItemName == 'wireM';   // true
    }
}