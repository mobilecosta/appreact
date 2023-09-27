import { Component, OnInit, ViewChild } from '@angular/core';
import { environment } from 'src/environments/environment';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { PoBreadcrumb, PoDynamicViewField, PoModalComponent, PoNotificationService, PoPageAction, PoTableAction, PoTableColumn, PoTableColumnLabel, PoTableColumnSort } from '@po-ui/ng-components';

import { PoPageDynamicTableCustomTableAction, PoPageDynamicTableOptions } from '@po-ui/ng-templates';
import { DomSanitizer } from '@angular/platform-browser';

@Component({
  selector: 'app-warranty',
  templateUrl: './warranty.component.html',
  styleUrls: ['./warranty.component.css']
})

export class WarrantyComponent implements OnInit {
  @ViewChild(PoModalComponent, { static: true })
  poModal!: PoModalComponent;
  detailedChamado: Array<any> = []
  detailedProduto: Array<any> = []
  notifyNumber: string = '0'

  columnsTable: Array<PoTableColumn> | any ;
  itemsTable: Array<any> | any;

  @ViewChild('userDetailProduto') userDetailProduto: PoModalComponent | undefined;


  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'item', label: 'Item'},
    { property: 'cod_produto', label: 'Produto'},
    { property: 'preco', label: 'Preço'},
    { property: 'nota', label: 'Nota'},
    { property: 'serie', label: 'Serie'},
    { property: 'quantidade', label: 'Quantidade'},
    { property: 'emissao', label: 'Emissão'},
    { property: 'bairro_empresa', label: 'Bairro', divider: 'Dados da empresa'},
    { property: 'nome_empresa', label: 'Empresa', gridColumns: 6},
    { property: 'cnpj', label: 'CNPJ'},
    { property: 'endereco_empresa',label: 'Endereço', gridColumns: 8},
    { property: 'cidade_empresa', label: 'Cidade'},
    { property: 'estado_empresa', label: 'Estado'},
    { property: 'cep_empresa', label: 'CEP'},
    { property: 'inscr_estadual', label:'Insc. Estadual'},
    { property: 'base_icm', label: 'Base ICMS' ,divider: 'Detalhes '},
    { property: 'chave_nfe',label: 'Chave NFE', gridColumns: 12},
    { property: 'desc_cfop', label: 'CFOP', gridColumns: 12},
    { property: 'filial_faturamento', label: 'Filial Faturamento'},
    { property: 'valor_icm', label:'Valor ICMS'},
    { property: 'valor_ipi', label: 'Valor IPI'},
];

  public readonly actions: Array<PoPageAction> = [
    { label: 'Incluir Chamado', url: '/FORMULARIO', icon: 'po-icon po-icon-plus' }
  ];
  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Garantia' }]
  };

  private headers: HttpHeaders | undefined;

  obscliente: string = '';
  obsatendente: string | undefined;
  numChamado: string = ''
  hideload = true

  fields: Array<PoDynamicViewField> = [
    { property: 'chamado', label: 'Chamado', gridLgColumns: 6 },
    { property: 'nota', label: 'Nota', gridLgColumns: 4 },
    { property: 'item', label: 'Item', gridLgColumns: 4 },
    { property: 'emissao', label: 'Emissão', gridLgColumns: 4 },
    { property: 'produto', label: 'Produto', gridLgColumns: 4 },
    { property: 'descricao', label: 'Descrição', gridLgColumns: 20 },
    { property: 'quantidade', label: 'Quantidade', gridLgColumns: 4 },
    { property: 'preco', label: 'Valor', gridLgColumns: 4 },
    { property: 'defeito', label: 'Defeito', gridLgColumns: 4 },
    { property: 'tipodefeito', label: 'Tipo Defeito', gridLgColumns: 4 },
    { property: 'rastreio', label: 'Num. Rastreamento', gridLgColumns: 4 },
    { property: 'pedido', label: 'Num. Pedido', gridLgColumns: 4 }
  ];


  tableCustomActions: Array<PoTableAction> = [
      {
        label: 'Detalhes Chamado',
        action: this.onClickUserDetail.bind(this),
        icon: 'po-icon-user'
      },
      {
        label: 'Espelho da Nota',
        action: this.onClickProdutoDetail.bind(this),
        icon: 'po-icon-user'
      }
  ];


  constructor(
    public http: HttpClient,
    private poNotification: PoNotificationService,
    private sant:DomSanitizer,
  ) { }

  employee: any = ''

  ngOnInit(): void {
    this.columnsTable = this.getColumns();
    this.itemsTable = this.getChamadosAbertos();
  } 


  onClickUserDetail(event: any) {

    console.log(event)
    
    this.numChamado = event.chamado
    this.loadNotify(event.chamado)

    this.employee = { 
      chamado:event.chamado,
      nota:event.nota,
      item:event.item,
      emissao:event.emissao,
      produto:event.produto,
      descricao:event.descricao,
      quantidade:event.quantidade,
      defeito:event.defeito,
      tipodefeito:event.tipodefeito,
      preco:event.preco,
      rastreio:event.rastreio,
      pedido:event.pedido
    }
    this.obsatendente = event.obsatend.trim()
    this.poModal.open();
  }


  onClicknotiFy(row: any) {

    this.numChamado = row.chamado
    this.loadNotify(row.chamado)

    this.employee = { 
      chamado:row.chamado,
      nota:row.nota,
      item:row.item,
      emissao:row.emissao,
      produto:row.produto,
      descricao:row.descricao,
      quantidade:row.quantidade,
      defeito:row.defeito,
      tipodefeito:row.tipodefeito,
      preco:row.preco,
      rastreio: row.rastreio,
      pedido:row.pedido
    }
    this.obsatendente = row.obsatend.trim()
    this.poModal.open();
  }


  private onClickProdutoDetail(user: any) {
    let url = environment.api + `FieldService/?nota=${user['nota']}&codigo=${user['produto']}&cod_cliente=${localStorage.getItem('cod_cliente')}&loja_cliente=${localStorage.getItem('loja_cliente')}`

    this.http.get(url).subscribe((res: any)=>{
      this.detailedProduto = res['items'][0]
      this.userDetailProduto!.open();
    })

  }


  interageCliente(){  

    if(!!this.obscliente){
      let body: any;
      const url_login = environment.api + 'UpdChamdo';
  
      this.headers = new HttpHeaders({
        Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });
  
      body = {
        USUARIO : localStorage.getItem('user'), 
        TEXT : this.obscliente,
        NOTA : this.employee.nota,
        CLIENTE : localStorage.getItem('cod_cliente'),
        LOJA : localStorage.getItem('loja_cliente'),
        EMISSAO : this.employee.emissao,
        PRODUTO : this.employee.produto
      };
  
      this.http.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
        const result: any = res['statusrequest'];
  
        if (result[0].code == '#200') {
          
          this.fGrvImage(this.numChamado)
          this.poNotification.success(result[0].message);
          this.poModal.close()
          window.location.reload();
  
        } else{
          this.poNotification.error(result[0].message);
        }
      }, (error) => {
        if (error.hasOwnProperty('message')){
          this.poNotification.error('Falha na comunicaçao com servidor');
        }
      });
      
    } else{
      this.poNotification.error('Necessário preencher interação!')
    }

  }


  async loadNotify (chamado: string){  
  
    this.headers = new HttpHeaders({
      Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });

    this.http.post(environment.api + 'chamadoNotific', {CHAMADO : chamado}, {headers: this.headers})
      .subscribe((res: any) => {
        const result: any = res['statusrequest'];
          console.log(result[0].message);

      }, (error) => {
        if (error.hasOwnProperty('message')){
          console.log('Falha na comunicaçao com servidor');
        }
      });
  }

  
  base64: string = ''
  fileSelected?:Blob;
  imageUrl?: string
  imagesConv: any = []

  inputImg: String = ''

  onSelectNewFile(files: FileList):void{

    var filesStr = "";

    for (let i = 0; i < files.length; i++){
      filesStr += '<li>' + files[i].name + ' </li> '

      this.fileSelected = files[i]
      this.imageUrl = this.sant.bypassSecurityTrustUrl(window.URL.createObjectURL(this.fileSelected)) as string

      if(!!this.imageUrl){
        let reader = new FileReader();
        reader.readAsDataURL(this.fileSelected as Blob)
        reader.onloadend=()=>{
          this.base64 = reader.result as string
          this.imagesConv.push({image: this.base64, name: files[i].name})
        }
      }
    }
    this.inputImg += filesStr;
  }

  clearImg(){
    this.imagesConv = []
    this.inputImg = ''
    this.imageUrl = ''
    this.base64 = ''
  }

  fGrvImage(chamado: string){

    this.imagesConv.map((event: any, index: number) =>{
      let body: any;
    
      const url_login = environment.api + 'PRTL046';
  
      this.headers = new HttpHeaders({
        Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });
  
      body = {IMAGE : event.image, NIMAGE: event.name, CHAMADO: chamado};
  
      this.http.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
        const result: any = res['statusrequest'];
  
        if (result[0].code == '#200') {
          this.poNotification.success(result[0].message)
          this.imagesConv = []
          this.inputImg = ''
  
        } else{
          this.poNotification.error('Nao enviou a imagem #500');
        }
      }, (error) => {
        if (error.hasOwnProperty('message')){
          this.poNotification.error('Falha na comunicaçao com servidor');
        }
      });
    })

  }


  getColumns(): Array<PoTableColumn> {
    return [
      { property: 'chamado', label: 'Chamado' },
      { property: 'nota', label: 'Nota' },
      { property: 'item', label: 'Item' },
      { property: 'emissao', label: 'Emissão' },
      { property: 'produto', label: 'Produto' },
      { property: 'descricao', label: 'Descrição' },
      { property: 'quantidade', label: 'Quantidade' },
      { property: 'defeito', label: 'Defeito' },
      { property: 'tipodefeito', label: 'Tipo Defeito' },
      { property: 'produto', label: 'Produto' },
      { 
        property: 'status', 
        type: 'label', 
        labels:[
          { value: '2', color: 'color-02', label: 'Atendido' },
          { value: '1', color: 'color-08', label: 'Em Aberto' },
          { value: '3', color: 'color-07', label: 'Negado' },
          { value: '4', color: 'color-11', label: 'Finalizado' },
          { value: '5', color: 'color-12', label: 'Envio pendente de documentos' },
          { value: '6', color: 'color-07', label: 'Cancelado pelo atendente' },
        ] 
      },
      {
        property: 'notification',
        label: 'Notificação',
        type: 'icon',
        sortable: false,
        icons: [
          {
            action: this.onClicknotiFy.bind(this),
            color: 'color-07',
            icon: 'po-icon-notification',
            tooltip: 'Visualizar Notificação',
            value: 'atualizou'
          }
        ]
      }
    ];
  }


  getChamadosAbertos(): Array<any>{
    this.hideload = false

    let url = environment.api + `EnvChamdo/?cod_cliente=${localStorage.getItem('cod_cliente')}&loja_cliente=${localStorage.getItem('loja_cliente')}`
    let items: any = []
    
    this.http.get(url).subscribe((response: any) =>{
      response['items'].forEach((element: any) =>{

        items.push({
          chamado:element.chamado,
          nota:element.nota,
          item:element.item,
          emissao:element.emissao,
          produto:element.produto,
          descricao:element.descricao,
          quantidade:element.quantidade,
          defeito:element.defeito,
          tipodefeito:element.tipodefeito,
          preco:element.preco,
          obsatend:element.obsatend,
          status:element.status,
          notification: element.notification,
          rastreio: element.rastreio,
          pedido:element.pedido
        })
      })

      const setChamado = items.length > 0 ? JSON.stringify(items) : JSON.stringify([])
      localStorage.setItem('chamados', setChamado)
      this.hideload = true
      
    })
    return items
  }

}
