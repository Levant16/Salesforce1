import { LightningElement, track, wire } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi'; 
 
const actions = [

    { label: 'Delete', name: 'delete' }

];
const certColumns = [
   { label: 'Certification Category', fieldName: 'Certification_Category__c' },
   { label: 'Certification Name', fieldName: 'Certification_Name__c' },
   { label: 'Certification ID', fieldName: 'Certification_Id__c' },
   { label: 'Action', type: 'action', typeAttributes: { rowActions: actions },fixedWidth: 130,},
];
export default class AddCertification extends LightningElement {
  @track certCategory;
  @track certName;
  @track selectedCategoryValue = '';
  @track certPicklist;
  @track selectedCertificateValue = '';
  @track selectedCertificationId = '';
  @track certificateList=[];
  @track certColumns = certColumns;
  @track rowOffset = 0;
  @track certificationRecord={};
  @track tempArr = []
    
    // method to get master and dependent Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: 'Case', recordTypeId: '0127h000000DDyUAAW' })
    newPicklistValues({ error, data }) {
        if (data) {
            this.error = null;
            this.certPicklist = data.picklistFieldValues;
            console.log('data returned' + JSON.stringify(data.picklistFieldValues));
            let certValuesList = data.picklistFieldValues.Certification_Category__c.values;
            let certCategory = [];
            for (let i = 0; i < certValuesList.length; i++) {
                certCategory.push({
                    label: certValuesList[i].label,
                    value: certValuesList[i].value
                });
            }
            this.certCategory = certCategory;
            //console.log('Cert Category' + JSON.stringify(this.certCategory));
        }
        else if (error) {
            this.error = JSON.stringify(error);
            console.log(JSON.stringify(error));
        }
    }

    handleCertCategoryChange(event) {
        console.log('event',event.detail.value)
        console.log('name',event.target.name)
        //if(event.target.name==='category'){
        this.selectedCategoryValue = event.detail.value;      
        if (this.selectedCategoryValue) {
            let data = this.certPicklist;
            let totalCertNameValues = data.Certification_Name__c;
            //Getting the index of the controlling value as the single value can be dependant on multiple controller value

            let controllerValueIndex = totalCertNameValues.controllerValues[this.selectedCategoryValue];

            let certNamePicklistValues = data.Certification_Name__c.values;
            let certNamePicklists = [];            
            certNamePicklistValues.forEach(key => {
                for (let i = 0; i < key.validFor.length; i++) {
                    if (controllerValueIndex == key.validFor[i]) {
                        certNamePicklists.push({
                            label: key.label,
                            value: key.value
                        });
                    }
                }
            })
            console.log('Cert Name ' + JSON.stringify(certNamePicklists));
            if (certNamePicklists && certNamePicklists.length > 0) {
                this.certName = certNamePicklists;
            //}
        }
    }
    // else if(event.target.name==='certname'){
    //     this.selectedCertificateValue = event.detail.value;
    // }
    // else if(event.target.name==='cID'){
    //     this.selectedCertificationId = event.detail.value;
    // }
    }
    
    handleCertNameChange(event) {
        this.selectedCertificateValue = event.detail.value;
    }

    handleCertId(event) {
        this.selectedCertificationId = event.detail.value;
    }

  handleAddClick() {
        //this.tempArr = []
        let certificationRecord = [{}]
        certificationRecord.Certification_Category__c =this.selectedCategoryValue;  
        certificationRecord['Certification_Name__c']=this.selectedCertificateValue;
        certificationRecord['Certification_Id__c']=this.selectedCertificationId;
        // let unique = [...new Set(certificationRecord.map(Certification_Name__c=> certificationRecord.Certification_Name__c))];
        // if(unique.length===1){
        //     console.log(unique);
        // }
        for(let i =0;i < certificationRecord.length; i++){

            if(certificationRecord.name== this.handleCertNameChange){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Record Deleted',
                        variant: 'error'
                    })
                );
            }
            else{
    
                this.certificateList.push(certificationRecord);
    
            }
        }
        console.log('test1',certificationRecord)
        this.certificateList.push(certificationRecord);
        this.certificateList = JSON.parse(JSON.stringify(this.certificateList))
        console.log('test...',this.certificateList) 
        this.selectedCategoryValue = '';
        this.selectedCertificateValue = '';
        this.selectedCertificationId = '';
    }

    increaseRowOffset() {
        this.rowOffset += 100;
}

 handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
        case 'delete':
            this.deleteRow(row);
            break;
        default:
    }
}

deleteRow(row) {
    let rowObj = JSON.parse(JSON.stringify(row));
    console.log('event',rowObj)
    const { Certification_Id__c } = rowObj;
    const index = this.findRowIndexById(Certification_Id__c);
    if (index !== -1) {
        this.certificateList = this.certificateList
            .slice(0, index)
            .concat(this.certificateList.slice(index + 1));
    }
}
findRowIndexById(id) {
    let ret = -1;
    this.certificateList.some((row, index) => {
        if (row['Certification_Id__c'] === id) {
            ret = index;
        }
    });
    return ret;
}
}