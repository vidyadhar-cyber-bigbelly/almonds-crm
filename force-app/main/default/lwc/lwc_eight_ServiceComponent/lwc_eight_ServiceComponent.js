// We need to define the code for toast message, that can used by other components

// import 'ShowToastEvent' to display the toast message
import {ShowToastEvent} from 'lightning/platformShowToastEvent'

// create a helper/utility function that will be called by multiple components, who wants to display toast message
// toastMessage(): user-defined function(name can be anything), called by multiple components
// why not this.dispatchEvent? -> this means specific -> and below will be used by multiple components, not a specific component.
// to the title, message, variant, mode we cannot give static specific values, bcoz diff components may have diff values, so we add parameters, and we will receive the parameter values from the calling components
function toastMessage(resT, resM, resV, resMd){
    dispatchEvent(
        new ShowToastEvent(
            {
                title : resT,
                message : resM,
                variant : resV,
                mode : resMd
            }
        )
    );
}

// to allow 'toastMessage' function to import into calling components, we must first export it.
export {toastMessage}