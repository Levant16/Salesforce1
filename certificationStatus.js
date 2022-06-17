import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CertificationStatus extends LightningElement {
    @api recordId
    isReadOnly = true;

    handleStatusChange(event){
        if(event.detail.value === 'Passed'){
            this.isReadOnly = false
        } else {
            this.isReadOnly = true
        }
    }

    closeAction(){
        this.dispatchEvent(new CustomEvent('closeModal'));
        console.log('lwchandlecloseModal');
    }
}