import { TitulosService } from './titulos.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { environment } from 'src/environments/environment';
import { Component, OnInit, ViewChild } from '@angular/core';
import {  PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent, PoNotificationService, PoSelectOption } from '@po-ui/ng-components';


@Component({
  selector: 'app-titulos',
  templateUrl: './titulos.component.html',
  styleUrls: ['./titulos.component.scss']
})
export class TitulosComponent implements OnInit {
  @ViewChild('userDetailModal')
  userDetailModal!: PoModalComponent;

  serviceApi = environment.api + `Financial/?CODIGO=${localStorage.getItem('cod_cliente')}`;
  detailedUser: any;
  quickSearchWidth: number = 3;


  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'emissao', gridLgColumns: 4},
    { property: 'parcela', gridLgColumns: 4 },
    { property: 'prefixo', gridLgColumns: 4 },
    { property: 'status', gridLgColumns: 4, gridSmColumns: 6},
    { property: 'titulo', gridLgColumns: 4 },
    { property: 'vencimento', gridLgColumns: 4, gridSmColumns: 6 },
  ];


  readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Titulos'}]
  };

  private headers: HttpHeaders | undefined;

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [];

  constructor(
    private http: HttpClient, 
    public titulosServices: TitulosService, 
    private route: ActivatedRoute,
    private poNotification: PoNotificationService,
    ) {}

  ngOnInit(): void {
    console.log(this.serviceApi)
    if(localStorage.getItem('tipo') == 'vendedor'){
      this.tableCustomActions.push({
        label: 'Detalhes',
        action: this.onClickUserDetail.bind(this),
        icon: 'po-icon po-icon-finance-secure'
      })
    }else if(localStorage.getItem('tipo') == 'cliente'){
      this.tableCustomActions.push({
        label: 'Boleto',
        action: this.onClickUploadBoleto.bind(this),
        icon: 'po-icon po-icon-money',
      },
      {
        label: 'Danfe',
        icon: 'po-icon po-icon-sale',
        action: this.onClickUploadDanfe.bind(this),
      },
      {
        label: 'Xml',
        icon: 'po-icon po-icon-xml',
        action: this.onClickUploadXml.bind(this),
      })
    }
  }

onLoad(): PoPageDynamicTableOptions {
  return {
    fields: [
      { property: 'titulo', label: 'Título', gridLgColumns: 4 , filter: true},
      { property: 'prefixo', label: 'Prefixo', gridLgColumns: 4, filter: true },
      { property: 'filial', label: 'Filial', gridLgColumns: 4, filter: true },
      { property: 'emissao', label: 'Emissão', gridLgColumns: 4, filter: true },
      { property: 'cliente', label: 'Cliente', gridLgColumns: 12 , filter: true},
      { property: 'vencimento', label: 'Vencimento', gridLgColumns: 4, filter: true },
      { property: 'valor', label: 'Valor', gridLgColumns: 4, filter: true },
      { property: 'parcela', allowColumnsManager: true, label: 'Parcela', gridLgColumns: 4, filter: true },
      { property: 'status', type: 'label', labels:[
        { value: 'Pago', color: 'color-11', label: 'Pago' },
        { value: 'Em Aberto', color: 'color-08', label: 'Em Aberto' },
        { value: 'Atrasado', color: 'color-07', label: 'Atrasado' },
      ], gridLgColumns: 4, filter: true },
    ]
  };
}

  printPage() {
    window.print();
  }

  isUserInactive(person: { status: string; }) {
    return person.status === 'inactive';
  }

  private onClickUploadBoleto(user: { [x: string]: any; }){

    let arquivo = 'http://portal.robsol.com.br/'+user.cnpj+'/boleto_'+user.titulo+'_'+user.parcela+'.pdf'

    const exportFileDefaultName = arquivo
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', arquivo);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.setAttribute('target', '_blank');
    linkElement.click();
  }
  private onClickUploadDanfe(user: { [x: string]: any; }){
    console.log(user)
    const exportFileDefaultName = user.danfe;
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', user.danfe);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.setAttribute('target', '_blank');
    linkElement.click();
  }
  private onClickUploadXml(user: { [x: string]: any; }){
    console.log(user)
    const exportFileDefaultName = user.xml;
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', user.xml);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.setAttribute('target', '_blank');
    linkElement.click();
  }

  private onClickUserDetail(user: { [x: string]: any; }) {
    let titulos = this.serviceApi + `&titulo=${user['titulo']}&prefixo=${user['prefixo']}&parcela=${user['parcela']}`
    this.http.get(titulos).subscribe((res: any) => {
      this.detailedUser = res['items'][0]
      this.userDetailModal.open();
    }, () => {})
   }
}
