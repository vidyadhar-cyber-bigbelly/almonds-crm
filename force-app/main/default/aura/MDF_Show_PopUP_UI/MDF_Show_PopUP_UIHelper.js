({
	loadBookTypePicklist : function(component) {
		 var action = component.get("c.getBookTypePicklist");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                var options = response.getReturnValue();
                component.set("v.bookTypeOptions", options);
                console.log("Picklist Loaded: " + JSON.stringify(options));
            } else {
                console.error("Error loading Book Type picklist");
            }
        });
        
        $A.enqueueAction(action);
	}
})