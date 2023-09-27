import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent } from '@po-ui/ng-components';
import {  PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';

@Component({
  selector: 'app-clientes',
  templateUrl: './clientes.component.html',
  styleUrls: ['./clientes.component.scss']
})
export class ClientesComponent implements OnInit {
  @ViewChild('userDetailModal') userDetailModal: PoModalComponent | undefined;

  readonly serviceApi = `http://200.98.81.201:40160/rest/Customers/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  detailedUser!: { codigo: any; nome_fantasia: any; razao_social: any; endereco: any; telefone: any; cidade: any; bairro: any; cep: any; uf: any; };
  quickSearchWidth: number = 3;

  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Clientes' }]
  };

  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'codigo', gridColumns: 12, divider: 'Informações do Cliente'},
    { property: 'razao_social', gridColumns: 6 },
    { property: 'nome_fantasia', gridColumns: 6 },
    { property: 'endereco', gridColumns: 12, divider: 'Informações de Endereço' },
    { property: 'bairro', gridLgColumns: 4 },
    { property: 'ultima_compra', gridLgColumns: 4 },
    { property: 'cep', gridLgColumns: 4 },
    { property: 'cidade', gridLgColumns: 4},
    { property: 'uf', gridLgColumns: 4, gridSmColumns: 6 },
    { property: 'contato', divider: 'Informações de Contato'},
    { property: 'celular'},
    { property: 'email', gridColumns: 12},
    { property: 'filial'},
    { property: 'bandeira'},
  ];

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Detalhes',
      action: this.onClickUserDetail.bind(this),
      icon: 'po-icon-user'
    }
  ];


  constructor(public http: HttpClient) {}
  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'codigo', label: 'Codigo', gridLgColumns: 4,key: true, visible: true, filter: true},
        { property: 'filial', allowColumnsManager: true, label: 'Filial', gridLgColumns: 4 , filter: true},
        { property: 'razao_social', allowColumnsManager: true, label: 'Razao Social', gridLgColumns: 4 , filter: true},
        { property: 'nome_fantasia', label: 'Nome Fantasia', gridLgColumns: 4 , filter: true},
        { property: 'endereco', label: 'Endereço', gridLgColumns: 12 , filter: true},
        { property: 'bairro', label: 'Bairro', gridLgColumns: 4 , filter: true},
        { property: 'ultima_compra', label: 'Última Compra', gridLgColumns: 4, filter: true },
        { property: 'cep', label: 'Cep', gridLgColumns: 4, filter: true },
        { property: 'celular', label: 'Celular', filter: true },
        { property: 'cidade', label: 'Cidade', gridLgColumns: 6, filter: true, visible: false},
        { property: 'uf', label: 'UF', gridLgColumns:6, filter: true, visible: false}
      ]
    };
  }

  ngOnInit(): void {}

  private onClickUserDetail(user: any) {
    this.http.get(this.serviceApi, {params: {codigo: user['codigo']}}).subscribe((res)=>{
      this.detailedUser = user
    })

    this.userDetailModal!.open();
  }
}
