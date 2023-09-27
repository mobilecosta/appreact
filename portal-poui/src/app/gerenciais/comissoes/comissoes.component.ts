import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent, PoSelectOption } from '@po-ui/ng-components';
import { PoPageDynamicTableActions, PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-comissoes',
  templateUrl: './comissoes.component.html',
  styleUrls: ['./comissoes.component.scss']
})
export class ComissoesComponent implements OnInit {
  @ViewChild('userDetailModal')
  userDetailModal!: PoModalComponent;

  serviceApi = environment.api+`Commission/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;

  detailedUser: any;
  quickSearchWidth: number = 3;
  event!: string;

  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Comissões' }]
  };


  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'id', gridLgColumns: 4 },
    { property: 'razao_social', gridLgColumns: 4 },
    { property: 'valor_pedido', gridLgColumns: 4 },
    { property: 'porcentagem', gridLgColumns: 4 },
    { property: 'valor_comissao', gridLgColumns: 4},
    { property: 'data_pedido', gridLgColumns: 4, gridSmColumns: 6 },
    { property: 'marca' },
    { property: 'data_status' },
    { property: 'quantidade' },
    { property: 'nome_fantasia' },
    { property: 'desconto' },
    { property: 'cond_pagto.' },
    { property: 'numero_nf' },
  ];

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Details',
      action: this.onClickUserDetail.bind(this),
      icon: 'po-icon po-icon-finance'
    }
  ];

  constructor(public http: HttpClient) {}

  ngOnInit(): void {}
  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'id', allowColumnsManager: true, label: 'Código do Cliente', gridLgColumns: 4 , filter: true},
        { property: 'razao_social', label: 'Razao Social', gridLgColumns: 4 , filter: true},
        { property: 'nome_fantasia', label: 'Nome Fantasia', gridLgColumns: 4 , filter: true},
        { property: 'porcentagem', label: 'Porcentagem', gridLgColumns: 4 , filter: true},
        { property: 'data_pedido', label: 'Data Pedido', gridLgColumns: 4, filter: true },
        { property: 'valor_pedido', label: 'Valor Pedido', gridLgColumns: 4 , filter: true},
        { property: 'valor_comissao', label: 'Valor Comissao', gridLgColumns: 4 , filter: true},
        { property: 'marca', label: 'Marca', gridLgColumns: 4, duplicate: true, filter: true },
        { property: 'quantidade', label: 'Quantidade', gridLgColumns: 4 , filter: true},
        { property: 'desconto', label: 'Desconto', gridLgColumns: 4, filter: true},
        { property: 'cond_pagto', label: 'Cond. Pagto', gridLgColumns: 4, filter: true, visible: false},
        { property: 'numero_nf', label: 'Numero NF', gridLgColumns: 4 , filter: true},
      ]
    };
  }

  private onClickUserDetail(user: any) {
    this.detailedUser = user;

    this.userDetailModal.open();
  }
}
