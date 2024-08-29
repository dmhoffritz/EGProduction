import LightningDatatable from 'lightning/datatable';
import customNameTemplate from './customName.html';
import customPicklist from './customPicklist.html';

export default class CustomTypesGlobal extends LightningDatatable {
    static customTypes = {
        gradePicklist: {
            template: customNameTemplate,
            editTemplate: customPicklist,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options']
        }
    }
}