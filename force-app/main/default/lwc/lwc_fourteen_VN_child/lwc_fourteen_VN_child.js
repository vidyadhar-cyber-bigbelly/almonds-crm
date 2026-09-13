import { LightningElement } from 'lwc';
export default class Lwc_fourteen_VN_child extends LightningElement {

    // Event Handler
    // when user selects any item, we will fetch the 'name' of the selected item from DOM page and dispatch it via 'message  variable to the parent.
    // to fetch from DOM page, use parameter, ex: event
    // event.detail.name: from the 'onselect' event details, fetch the 'name' of the item, who caused this event to occure.
    // why not event.target? bcoz user is not entering any value in input box, here user is selecting the existing item value.
    handleSelect(event){
        const customEvent = new CustomEvent('demo', {
            detail: {
                message: event.detail.name
            }
        })
        this.dispatchEvent(customEvent);
    }
}