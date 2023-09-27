import { HttpClient } from '@angular/common/http';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoBreadcrumb, PoModalComponent } from '@po-ui/ng-components';
import {  PoPageDynamicTableCustomAction, PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-catalog',
  templateUrl: './catalog.component.html',
  styleUrls: ['./catalog.component.css']
})
export class CatalogComponent implements OnInit {
  readonly serviceApi = environment.api + `Catalogs`;


  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Catalogs' }]
  };

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Catálogo',
      icon: 'po-icon po-icon-pdf'
    }
  ];

  constructor(public http: HttpClient) {}

  ngOnInit(): void {}

  onLoad(): PoPageDynamicTableOptions {
    return {
      fields: [
        { property: 'codigo', allowColumnsManager: true, gridLgColumns: 6, filter: true },
        { property: 'descricao', label: 'Descricao', gridLgColumns: 6, filter: true },
      ]
    };
  }

  printPage() {
    window.print();
  }
}
