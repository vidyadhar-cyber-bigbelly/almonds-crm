import { LightningElement,api } from 'lwc';
export default class Counter extends LightningElement {
@api count=0 ;

onclickhandle(){
    this.count+=1;
}
onResthandle(){
    this.count = 0;
}
}