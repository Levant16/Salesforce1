import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class RequestVoucherButton extends NavigationMixin (LightningElement) {

    handleClick(){
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: 'https://sfpdc.force.com/sfportal/requestVoucher',
            }
        };
        this[NavigationMixin.Navigate](config);
    }

}