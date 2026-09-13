import { LightningElement } from 'lwc';
export default class Lwc_sixteen_lifecycleHooks_child extends LightningElement {
    // Lifecycle Hooks -> called automatically based on the component's state
    constructor() {
        super();    
        console.log('I am Child Constructor');
    }
    connectedCallback() {
        console.log('I am Child connectedCallback');
    }
    renderedCallback(){
        console.log('I am Child renderedCallback');
    }
    disconnectedCallback() {
        console.log('I am Child disconnectedCallback');
    }
}