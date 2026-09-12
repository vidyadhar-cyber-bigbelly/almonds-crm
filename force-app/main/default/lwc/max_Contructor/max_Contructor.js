import { LightningElement } from 'lwc';

export default class Max_Contructor extends LightningElement {
    my_List = [];
    constructor(){
        super();
        console.log("Constructor called!");
    }
    connectedCallback(){
        this.my_List.push("Hii");
        console.log("inside ConnectedCallback");
        console.log(JSON.stringify(this.my_List));
    }
    disconnectedCallback(){
        this.my_List = [];
        console.log(JSON.stringify(this.my_List));
        console.log("inside disconnected callback");
    }
}