import { Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

import { Router } from '@angular/router';

import { PoBreadcrumb, PoDialogService, PoDynamicViewField, PoModalAction,
  PoModalComponent, PoNotificationService, PoSelectOption, PoStepperComponent, PoTableAction,
  PoTableColumn, PoUploadFileRestrictions } from '@po-ui/ng-components';
import { environment } from 'src/environments/environment';
import { NgForm } from '@angular/forms';
import { DomSanitizer } from '@angular/platform-browser';

@Component({
  selector: 'app-formulario',
  templateUrl: './formulario.component.html',
  styleUrls: ['./formulario.component.css']
})
export class FormularioComponent implements OnInit {
  @ViewChild(PoStepperComponent)
  stepper!: PoStepperComponent;
  @ViewChild('userDetailModal') userDetailModal: PoModalComponent | undefined;
  @ViewChild('produtoForm', { static: true }) produtoForm!: NgForm;
  @ViewChild('produtoInputForm', { static: true })
  produtoInputForm!: NgForm;
  @ViewChild('userDetailProduto') userDetailProduto: PoModalComponent | undefined;

  @ViewChild('sucessData', { static: true })
  sucessData!: PoModalComponent;

  @ViewChild(PoModalComponent, { static: true }) modal: PoModalComponent | any;
  

  private headers: HttpHeaders | undefined;

  buttonChooseProduct: boolean = false
  lTermo = false
  itemChamado: any
  codigo: boolean = true
  chooseProduct: boolean = false
  exchange: boolean = false;
  update: boolean = false;
  notes: boolean = false;
  finish: boolean = false;
  uploaded: boolean = false;
  urls = ''
  event!: string;
  input: string | undefined;
  descricao: string | undefined;
  produto: string | undefined;
  detailedUser!: { codigo: any; descricao: any; ean: any; grupo: any; imagem: any; ncm: any; saldo: any; tipo: any; um: any; };
  detailedProduto: Array<any> = []
  InpOtherEnv: string = ''
  items: Array<any> =[]
  upload: Array<any> =[]
  selectTipoDefeito: Array<PoSelectOption> = []
  tipodefeito = '';
  defeito = '';
  opctroca = '';
  acceptance: boolean = false;
  titleModal = ''

  readonly detailFields: Array<PoDynamicViewField> = [
    { property: 'item'},
    { property: 'cod_produto'},
    { property: 'preco'},
    { property: 'nota'},
    { property: 'quantidade'},
    { property: 'emissao'},
    { property: 'bairro_empresa', divider: 'Dados da empresa'},
    { property: 'nome_empresa', gridColumns: 6},
    { property: 'cnpj'},
    { property: 'endereco_empresa', gridColumns: 8},
    { property: 'cidade_empresa'},
    { property: 'estado_empresa'},
    { property: 'inscr_estadual'},
    { property: 'base_icm', divider: 'Detalhes '},
    { property: 'chave_nfe', gridColumns: 12},
    { property: 'desc_cfop', gridColumns: 12},
    { property: 'filial_faturamento'},
    { property: 'serie'},
    { property: 'valor_icm'},
    { property: 'valor_ipi'},
];

  restrictions: PoUploadFileRestrictions = {
    allowedExtensions: ['.jpg', '.png', '.jpeg', '.webp'],
  };


  modalAction: PoModalAction = {
    action: () => {
      if(this.lTermo){
        this.lTermo = false
        this.modal.close();
        this.onClickProdutoDetail(this.itemChamado)
      }
    },
    disabled: true,
    label: 'Confirmar'
  };

  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Home', link: '/' }, { label: 'Garantia', link: '/WARRANTY' }, { label: 'Formulario' }]
  };

  readonly all: Array<PoSelectOption> = [
    { label: 'Trocar Tudo', value: 'all' },
    { label: 'Trocar Peças', value: 'single' },
  ];

  readonly selectDefeito: Array<PoSelectOption> = [
    { label: 'Frontal', value: '1' },
    { label: 'Hastes', value: '2' },
    { label: 'Charneiras', value: '3' },
    { label: 'Lentes (Somente solares de fabrica)', value: '4' },
    
  ];


  tableActions: Array<PoTableAction> = [
    {
      label: 'Detalhes da Nota',
      action: this.onClickProdutoDetail.bind(this),
      icon: 'po-icon po-icon-finance'
    }
  ]
  columns: Array<PoTableColumn> = [
    { property: 'filial_faturamento'},
    { property: 'nota'},
    { property: 'item'},
    { property: 'cod_produto'},
    { property: 'quantidade'},
    { property: 'preco'},
    { property: 'emissao' },
  ];

  constructor(
    public http: HttpClient,
    private router: Router,
    private sant:DomSanitizer,
    private poNotification: PoNotificationService,
    private httpClient: HttpClient,
    ) {}

  ngOnInit() {}

  changeInpEnv(event: string){
    this.InpOtherEnv = event
  }

  closeModalTit(){
    this.modal.close()
    this.titEmAberto = []
  }

  confirm: PoModalAction = {
    action: () => {
      this.userDetailProduto!.close();
      this.sucessData.close();
      this.router.navigate(['WARRANTY']);  
    },
    label: 'Confirmar'
  };

  enviaChamado: PoModalAction = {
    action: () => {
        if(!this.itemChamado){
          this.userDetailProduto!.close()
        }else{
          this.handleEnvChamado()
        }
    },
    label: 'Confirmar'
  };

  valited(item: string){
    if(item == 'codigo' && this.input && !this.lTermo){
      this.validTitAberto()
    }

    if(item == 'chooseProduct'){
      this.codigo = false
      this.chooseProduct = false
      this.exchange = true
    }
    if(item == 'buttonExchange' && this.descricao && this.defeito && this.opctroca && this.imagesConv.length > 0){
      this.codigo = false
      this.itemChamado.descricao = this.descricao
      this.itemChamado.defeito = this.defeito
      this.itemChamado.tipodefeito = this.tipodefeito
      this.chooseProduct = false
      this.exchange = false
      this.uploaded = true 
      this.lTermo = true
      this.titleModal = 'Políticas e procedimentos para trocas'
      this.modal.open()

    }else if(item == 'buttonExchange' && !this.opctroca){
      this.poNotification.error('Obrigatório preencher a opção de troca!');

    }else if(item == 'buttonExchange' && !this.defeito){
      this.poNotification.error('Obrigatório preencher o tipo de defeito!');
    
    }else if(item == 'buttonExchange' && !this.descricao) {
      this.poNotification.error('Obrigatório preencher a descrição!');
      
    }else if(item == 'buttonExchange' && this.imagesConv.length === 0){
      this.poNotification.error('Obrigatório inserir as imagens do produto!');
    }

    if(item == 'uploaded'){
      this.sucessData!.open();
      this.uploaded = true
      this.notes = true
    }
    if(item == 'notes'){
      this.notes = false
      this.finish = true
    }
  }

  titEmAberto: any = []

  validTitAberto(){

    let result =  environment.api +  `Financial/?VENDEDOR=${localStorage.getItem('cod_vendedor')}&CODIGO=${localStorage.getItem('cod_cliente')}&status=Em Aberto`;
    this.http.get(result).subscribe((res: any) => {
      res.items.map((event: any)=>{
        if(event.status === 'Atrasado'){
          this.titEmAberto.push(event)
        }
      })


      if(this.titEmAberto.length > 0){
        this.lTermo = false
        this.titleModal = 'Títulos em Aberto'
        this.modal.open()

      }else{
        this.onClickUserDetail()
        this.codigo = false
        this.chooseProduct = true
      }

    })
  }



  chooseSelect(item: string){
    this.itemChamado = item
    this.buttonChooseProduct = true
  }
  chooseDeselect(item: string){
    this.buttonChooseProduct = false
  }

  changeEventRepo(event: string) {
    this.event = event;
    this.opctroca = this.event
    this.itemChamado.opcTroca = this.event
  }

  changeEventDefeito(event: string) {
    this.event = event;
    this.defeito = this.event

    if(this.event === '1'){
      this.tipodefeito = 'A'
      this.selectTipoDefeito = [
        { label: 'Descascando', value: 'A' },
        { label: 'Trincado', value: 'B' },
        { label: 'Oxidação', value: 'C' },
        { label: 'Riscada', value: 'D' },
        { label: 'Quebrada', value: 'E' },
        { label: 'Manchada', value: 'L' },
        { label: 'Suporte de Plaquetas', value: 'N' }
      ];
    }else if(this.event === '2'){
      this.tipodefeito = 'A'
      this.selectTipoDefeito = [
        { label: 'Descascando', value: 'A' },
        { label: 'Trincado', value: 'B' },
        { label: 'Oxidação', value: 'C' },
        { label: 'Riscada', value: 'D' },
        { label: 'Quebrada', value: 'E' },
        { label: 'Defeito na Ponteira', value: 'I' },
        { label: 'Manchada', value: 'L' },
        { label: 'Defeito na Mola', value: 'M' }
      ];
    }else if(this.event === '3'){
      this.tipodefeito = 'E'
      this.selectTipoDefeito = [
        { label: 'Quebrada', value: 'E' },
        { label: 'Quebrada na Solda', value: 'F' },
        { label: 'Solta', value: 'G' },
        { label: 'Parafuso Espanado', value: 'H' }
      ];
    }else if(this.event === '4'){
      this.tipodefeito = 'J'
      this.selectTipoDefeito = [
        { label: 'Tonalidades Diferentes', value: 'J' },
        { label: 'Solta', value: 'G' },
        { label: 'Manchada', value: 'L' }
      ];
    }
  }

  
  changeEventTpDefeito(event: string) {
    this.event = event;
    this.tipodefeito = this.event
  }

  changeEvent(event: string) {
    this.event = event;
  }

  onClickUserDetail() {

    let itmChamado: any = []
    let lOk = true

    itmChamado = JSON.parse(localStorage.getItem('chamados') as string)
    
    const  url = environment.api + `FieldService/?codigo=${this.input}&cod_cliente=${localStorage.getItem('cod_cliente')}&loja_cliente=${localStorage.getItem('loja_cliente')}`
    this.http.get(url).subscribe((response: any) =>{

      if(itmChamado.length > 0){
          response['items'].forEach((element: any) =>{
            lOk = true

            itmChamado.filter((event: any)=>{
              if(event.produto.trim()+event.nota.trim() === element.cod_produto.trim()+element.nota.trim() && event.status !== '6' && lOk){
                lOk = false
              }
            })

            if(lOk){
              this.insertItem(element)
            }
          })
        
      }else{
        response['items'].forEach((element: any) =>{
          this.insertItem(element)
        })
      }
    })
  }

  insertItem(element: any){
    this.items.push({
      filial_faturamento: element['filial_faturamento'],
      nota: element['nota'],
      item: element['item'],
      cod_produto: element['cod_produto'],
      quantidade: element['quantidade'],
      preco: element['preco'],
      emissao: element['emissao']
    })
  }

  private onClickProdutoDetail(user: any) {
    let url = environment.api + `FieldService/?nota=${user['nota']}&codigo=${user['cod_produto']}&cod_cliente=${localStorage.getItem('cod_cliente')}&loja_cliente=${localStorage.getItem('loja_cliente')}`
    
      this.http.get(url).subscribe((res: any)=>{
      this.detailedProduto = res['items'][0] 
      this.userDetailProduto!.open();
    })

  }

  handleEnvChamado(){
  let body: any;
  const url_login = environment.api + 'PRTL043';

    this.headers = new HttpHeaders({
      'X-PO-No-Message': 'true',
      'Content-Type': 'application/json',
      Authorization: 'Basic YWRtaW46QVZTSTIwMjI=' });

    body = {
        filial_faturamento: this.itemChamado.filial_faturamento,
        nota: this.itemChamado.nota,
        item: this.itemChamado.item,
        cod_produto: this.itemChamado.cod_produto,
        quantidade: this.itemChamado.quantidade,
        preco: this.itemChamado.preco,
        emissao: this.itemChamado.emissao,
        opcTroca: this.itemChamado.opcTroca,
        descricao: this.itemChamado.descricao,
        defeito: this.itemChamado.defeito,
        tipodefeito: this.itemChamado.tipodefeito,
        cliente: localStorage.getItem('cod_cliente'),
        lojacli: localStorage.getItem('loja_cliente'),
        another_address: this.InpOtherEnv
      }

      this.http.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
        this.sucessData.open();
        if(!!res.stsrequest[0].chamado){
          this.fGrvImage(res.stsrequest[0].chamado)
        }
        
      }, (error) => {
        if (error.hasOwnProperty('message')){
          this.poNotification.error('Erro no envio do formulário, contate o administrador do sistema');
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

    console.log(files)

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
  
      this.httpClient.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
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


  columnTitAb: Array<PoTableColumn> = [
    { property: 'titulo', label: 'Título' },
    { property: 'prefixo', label: 'Prefixo' },
    { property: 'filial', label: 'Filial' },
    { property: 'emissao', label: 'Emissão' },
    { property: 'cliente', label: 'Cliente' },
    { property: 'vencimento', label: 'Vencimento' },
    { property: 'valor', label: 'Valor' },
    { property: 'parcela', label: 'Parcela' },
    { property: 'status', type: 'label', labels:[
      { value: 'Pago', color: 'color-11', label: 'Pago' },
      { value: 'Em Aberto', color: 'color-08', label: 'Em Aberto' },
      { value: 'Atrasado', color: 'color-07', label: 'Atrasado' },
    ] },
    ];
  


}
