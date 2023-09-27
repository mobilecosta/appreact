import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoModalComponent } from '@po-ui/ng-components';
import {  PoPageDynamicTableCustomAction, PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { environment } from 'src/environments/environment';
import { NotasService } from './notas.service';

@Component({
  selector: 'app-notas',
  templateUrl: './notas.component.html',
  styleUrls: ['./notas.component.scss']
})
export class NotasComponent implements OnInit {
  @ViewChild('userDetailModal')
  userDetailModal!: PoModalComponent;
  pedidoitems: any;
  readonly serviceApi = environment.api+ `Invoice/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  detailedUser: any;
  quickSearchWidth: number = 3;


  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Notas' }]
  };
  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [];

  constructor(public http: HttpClient, private usersService: NotasService) {}

  ngOnInit(): void {

  }

  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'codigo', allowColumnsManager: true, label: 'NF', gridLgColumns: 6, filter: true },
        { property: 'nome', label: 'Nome', gridLgColumns: 6, filter: true },
        { property: 'serie', label: 'Serie', gridLgColumns: 6, filter: true},
        { property: 'emissao', label: 'Emissão', gridLgColumns: 6 , filter: true},
        { property: 'cod_cliente', label: 'Código Cliente', gridLgColumns: 6, filter: true},
        { property: 'valor', label: 'Valor', gridLgColumns: 6, filter: true },
      ]
    };
  }
  printPage() {
    window.print();
  }

  private onClickUserDetail(user: any) {
    let notasapi = this.serviceApi + `&codigo=${user['codigo']}`
    this.http.get(notasapi).subscribe((res: any)=>{
     this.pedidoitems = res['items']
    })
    this.userDetailModal.open();
  }
}
