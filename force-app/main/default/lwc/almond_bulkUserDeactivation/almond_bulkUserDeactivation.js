import { LightningElement, track, wire } from 'lwc';
import getUsersByProfile from '@salesforce/apex/almondUserHandler.getUsersByProfile';
import updateUserActivation from '@salesforce/apex/almondUserHandler.updateUserActivation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class UserManagement extends LightningElement {
    @track admins = [];
    @track activeUsers = [];
    @track inactiveUsers = [];
    @track adminActive = [];

    @track adminDisplay = [];

    @track selectedActiveUsers = [];
    @track selectedInactiveUsers = [];

    @track adminStatusLabell;
    @track adminStatusClasss;
    @track activeRowsToDisplay;
    @track inActiveRowsToDisplay;
    @track selectedUserIds = [];
    @track selectedInActiveUserIds = [];
    hideCheckboxColumn = false;

    @track loading = false;
    @track columns = [
        {label : 'Name', fieldName : 'Name', type: 'text'},
        {label : 'Profile Name', fieldName : 'ProfileName', type: 'text'},
        {label : 'Department', fieldName : 'Department', type: 'text'},
        {label : 'Region', fieldName : 'Region_V__c', type: 'text'}
    ];

    @wire(getUsersByProfile)
    wiredUsers({ data, error }) {
        if (data) {
            console.log(data.Admins);
            this.admins = data.Admins || [];
            this.processAdminDisplay();
            this.activeUsers = data.Active || [];
            //this.rowsToDisplay = data.Active || [];

            this.activeRowsToDisplay = data.Active.map(u => ({
            ...u,
            ProfileName: u.Profile?.Name
            }));
            this.inActiveRowsToDisplay = data.Inactive.map(u => ({
            ...u,
            ProfileName: u.Profile?.Name
            }));

            this.inactiveUsers = data.Inactive || [];
        } else if (error) {
            console.error(error);
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedUserIds = selectedRows.map(row => row.Id);
    }
    handleInactiveRowSelection(event) {
        const selectedRows1 = event.detail.selectedRows;
        this.selectedInActiveUserIds = selectedRows1.map(row => row.Id);
    }

    get activeUserOptions() {
        return this.activeUsers.map(u => ({ label: u.Name, value: u.Id }));
    }

    get inactiveUserOptions() {
        return this.inactiveUsers.map(u => ({ label: u.Name, value: u.Id }));
    }
    get adminStatusLabel() {
        
    return (this.adminActive) ? 'Active' : 'Inactive';
    }

    get adminStatusClass() {
    return  (this.adminActive) ? 'slds-theme_success' : 'slds-theme_warning';
    }   

    processAdminDisplay(){
        this.adminDisplay = this.admins.map(u => ({
            Name : u.Name,
            statusLabel : u.IsActive ? 'Active' : 'Inactive',
            statusClass : u.IsActive ? 'slds-theme_success' : 'slds-theme_warning'
        }));
    }




    handleActiveSelect(event) {
        this.selectedActiveUsers = event.detail.value;
    }

    handleInactiveSelect(event) {
        this.selectedInactiveUsers = event.detail.value;
    }

    async handleActivate() {
        await this.updateUsers(this.selectedInActiveUserIds, true, 'Activated');
    }

    async handleDeactivate() {
        await this.updateUsers(this.selectedUserIds, false, 'Deactivated');
    }

    async updateUsers(userIds, setActive, message) {
        if (!userIds|| userIds.length === 0) {
            this.showToast('No Users Selected', 'Please select users to update.', 'warning');
            return;
        }
        this.loading = true;
        try {
            await updateUserActivation({ userIds: userIds, setActive: setActive });

            this.showToast('Success', `Users successfully ${message}.`, 'success');
                setTimeout(() => {
                    window.location.reload();
                    }, 
                    3000
                    );
            //window.location.reload();
            // Refresh data
            this.refreshData();
        } catch (error) {
            if (error.body && error.body.message) {
                    this.errorMessage = error.body.message;
                } else {
                    this.errorMessage = JSON.stringify(error);
                }
            this.showToast('Error', 'Contact your Admin and give this ->'+this.errorMessage, 'error');
        } finally {
            this.loading = false;
        }
    }

    refreshData() {
        getUsersByProfile()
            .then(data => {
                this.admins = data.Admins || [];
                this.activeUsers = data.Active || [];
                this.inactiveUsers = data.Inactive || [];
                this.selectedActiveUsers = [];
                this.selectedInactiveUsers = [];
            })
            .catch(error => console.error(error));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}