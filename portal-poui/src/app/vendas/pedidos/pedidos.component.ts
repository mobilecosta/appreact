import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent, PoSelectOption, PoTableColumn } from '@po-ui/ng-components';
import { PoPageDynamicTableActions, PoPageDynamicTableCustomTableAction, PoPageDynamicTableFilters, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-pedidos',
  templateUrl: './pedidos.component.html',
  styleUrls: ['./pedidos.component.scss']
})
export class PedidosComponent implements OnInit {
  @ViewChild('userDetailModal')
  userDetailModal!: PoModalComponent;

  vendedor = localStorage.getItem('Cod_Vendedor')
  pedidoitems: any;
  readonly serviceApi = environment.api+ `Sales/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  detailedUser: any;
  quickSearchWidth: number = 3;
  quantidade: number = 0;
  valor_total: number = 0;


  readonly actions: PoPageDynamicTableActions = {
    new: '/documentation/po-page-dynamic-edit',
    remove: true,
    removeAll: true
  };
  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'codigo', gridLgColumns: 4 },
    { property: 'descricao', gridLgColumns: 4 },
    { property: 'quantidade', gridLgColumns: 4 },
    { property: 'valor_total', gridLgColumns: 4 },
    { property: 'valor_unit', gridLgColumns: 4 },
  ];

  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Pedido' }]
  };

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Detalhes',
      action: this.onClickUserDetail.bind(this),
      icon: 'po-icon po-icon-sale'
    }
  ];

  constructor(public http: HttpClient) {}

  ngOnInit(): void {}

  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'codigo', allowColumnsManager: true, label: 'Cupom', gridLgColumns: 4, filter: true },
        { property: 'emissao', label: 'Emissão', gridLgColumns: 4, filter: true, allowColumnsManager: true, duplicate: true},
        { property: 'status', type: "label", labels: [
          { value: 'Faturado', color: 'color-11', label: 'Faturado' }, //verde
          { value: 'Em Aberto', color: 'color-08', label: 'Em Aberto' }, //amarelo
          { value: 'Pendencias', color: 'color-07', label: 'Com pendências' },
        ], gridLgColumns: 4, filter: true},
        { property: 'cliente', label: 'Cliente', gridLgColumns: 6 , filter: true},
        { property: 'nota', label: 'NF', gridLgColumns: 6 , filter: true},
        { property: 'serie', label: 'Serie', gridLgColumns: 6 , filter: true},
      ]
    };
  }

  private onClickUserDetail(user: { [x: string]: any; }) {
    this.valor_total = 0;
    this.quantidade = 0;

    let titulos = environment.api + `Sales/?VENDEDOR=${localStorage.getItem('cod_vendedor')}&codigo=${user['codigo']}`
    this.http.get(titulos).subscribe((res: any)=>{
      this.pedidoitems = res['items']
      res['items'].forEach((item: any) => {
        this.valor_total += parseFloat(item['valor_total'].trim().replace(',', '.'))
        this.quantidade += parseInt(item['quantidade'])
      })
    })
    this.userDetailModal.open();
  }

}
