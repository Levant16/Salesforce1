({
    handlecloseModal : function(component, event, helper) {
        console.log('aurahandlecloseModal');
        $A.get("e.force:closeQuickAction").fire();
        
    }
})

