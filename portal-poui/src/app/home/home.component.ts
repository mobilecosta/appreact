import { Component, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { PoStorageService } from '@po-ui/ng-storage';
import { HttpClient } from '@angular/common/http';
import { PoMenuItem, PoMenuComponent, PoChartSerie, PoChartOptions, PoChartType } from '@po-ui/ng-components';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {
  @ViewChild(PoMenuComponent, { static: true })

  menu!: PoMenuComponent;
  user: string = `${localStorage.getItem('user')}`
  edited: boolean = false
  vendedor: boolean = false

  comissoes: string = environment.api + `Commission/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  pedidos: string = environment.api + `Sales/?VENDEDOR=${localStorage.getItem('cod_vendedor')}`;
  isCollapsed = true;

  graphComissoes: string = '';
  graphPedidosAnalise: string = '';
  graphPedidosMes: string = '';
  graphTitulosAberto: string = '';

  readonly menus: Array<PoMenuItem> = [];
  titulosAbertos: number = 0;
  comissaoBrl: string = '';


  marcas: Array<any> = [
    {
      avatar: '/assets/sabrina-sato.webp',
      name: 'Sabrina Sato',
      description: '30% dos nossos produtos são focados em moda fashion e o design é feito para o rosto do brasileiro.',
      website: 'https://www.robsol.com.br/marcas/sabrinasatoeyewear',
      midia: 'https://www.robsol.com.br/images/Robsol/marcas/Sabrina%20Sato%20Eyewear%20Final-1.mp4'
    },
    {
      avatar: '/assets/fox-eyewear.webp',
      name: 'Fox Eyewear',
      description: 'A FOX Eyewear é projetada para atender o público masculino exigente que temos no mercado hoje em dia.',
      website: 'https://www.robsol.com.br/marcas/foxeyewear',
      midia: 'https://www.robsol.com.br/images/Robsol/marcas/Clipe_FOX_Site.mp4'
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/_0009_CV8001%20C3-bc81835b.webp',
      name: 'Carmem Vitti',
      description: 'Marca com um design contemporâneo e cores exclusivas. Detalhes incríveis e proteção total a seus olhos, esses são alguns dos diferenciais que tornam cada peça única,como a Carla Diaz.',
      website: 'https://www.robsol.com.br/marcas/carmenvitti',
      midia: ''
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/lorena_1080px_1-3c51d66b.webp',
      name: 'Trunks Eyewear',
      description: 'Armações coloridas e confortáveis, tornando o uso do óculos muito mais agradável.',
      website: 'https://www.robsol.com.br/marcas/trunks',
      midia: ''
    },
    {
      avatar: 'https://www.robsol.com.br/templates/yootheme/cache/galeria_romano_1080_4-fe1ed5a1.webp',
      name: 'Romano Eyewear',
      description: 'Os modelos são pensados e desenvolvidos buscando antecipar as maiores tendências mundiais e feitos para o rosto do jovem brasileiro.',
      website: 'https://www.robsol.com.br/marcas/romano',
      midia: ''
    },

  ]

  mural: Array<any> = []

  constructor(private router: Router, private storage: PoStorageService, private http: HttpClient) {}

  quadrimensalOptions: PoChartOptions = {}
  quadrimensalCategories: Array<string> = [];
  quadrimensalSeries: Array<PoChartSerie> = [];

  dataMensal: any[] = []

  mensalOptions: PoChartOptions = {};
  mensalCategories: Array<string> = [];
  mensalSeries: Array<PoChartSerie> = [
  ];
  ngOnInit(): void {
    let pp =  environment.api +  `Financial/?VENDEDOR=${localStorage.getItem('cod_vendedor')}&CODIGO=${localStorage.getItem('cod_cliente')}&status=Em Aberto`;
    this.http.get(pp).subscribe((res: any) => {
      this.graphTitulosAberto = res['items'].length
    })

    const url_metas = environment.api + `/Mural`
    this.http.get(url_metas).subscribe((response: any) =>{
      response[`items`].forEach((element: any) => {
        let data = element['data_publicacao'].split('/')[0]
        let today = new Date()
        var dd = today.getDate()
        if((parseInt(data) + 4) >= dd){
          this.mural.push({codigo: element[`codigo`], assunto: element[`assunto`],conteudo: element[`conteudo`], data_publicacao: element['data_publicacao']})
          return
        }
      });
    })

    const url_graph = environment.api + 'Metas'
    this.http.get(url_graph).subscribe((response: any) =>{
      let mensalC: any[] = []
      let mensalS: any[] = []

      let quadrimensalC: any[] = []
      let quadrimensalS: any[] = []
      let meta: number = 0
      let mes: number = 0

      let analises = response['items'][0]


      response['items'][1].forEach((element: any) =>{
        mensalS.push(parseFloat(element['venda'].trim().replace(',', '.')))
        meta = parseFloat(element['meta'].trim().replace(',', '.'))
        mensalC.push(element['dia'])
        this.mensalOptions = {axis: {
          maxRange: parseFloat(element['venda'].trim().replace(',', '.')),
          gridLines: 8
        }}

      })
      response['items'][2].forEach((element: any) =>{
        quadrimensalS.push(parseFloat(element['venda'].trim().replace(',', '.')))
        quadrimensalC.push(element['mes'])
        mes = element['meta']
        this.quadrimensalOptions = {axis: {
          maxRange: parseFloat(element['venda'].trim().replace(',', '.')),
          gridLines: 8
        }}

      })
      this.mensalCategories = mensalC

      this.mensalSeries = [{
        label: 'Mensal ' + `- Meta diaria  ${meta}`,
        data: mensalS,
        type: PoChartType.Line,
        color: 'po-color-07'
      }]

      this.quadrimensalCategories = quadrimensalC

      this.quadrimensalSeries = [{
        label: 'Trimestral ' + `- Meta mensal ${mes}`,
        data: quadrimensalS,
        type: PoChartType.Line,
        color: 'po-color-07'
      }]


      this.graphComissoes = analises['comissao_mes']
      this.graphPedidosAnalise = analises['pedidos_analise']
      this.graphPedidosMes = analises['pedidos_mes']

    })

    if(localStorage.getItem('tipo') === 'vendedor'){
      this.vendedor = !this.vendedor
    }
    this.http.get(this.comissoes).subscribe((success: any) => {
      success['items'].forEach((element: any) => {
      })
    }, (err: any) => { })

    const menu = localStorage.getItem('menu_acesso')
    const url = environment.api + `MenusPrt/?CODIGOMENU=${menu}`
 
    this.http.get(url).subscribe((res: any)=>{
      console.log(res)
      res.forEach((element: any) => {
        this.menus.push(element)
      });
      this.menus.push( 
        {
          "label": "Trocar senha",
          "shortLabel": "Trocar senha",
          "action": this.clearToken.bind(this),
          "link": "/trocasenha"
        },
        {
          "label": "Sair",
          "icon": "po-icon-exit",
          "shortLabel": "Sair",
          "action": this.clearToken.bind(this),
          "link": "/login"
        }
      )

    })
  }

  openTitulos() {
    this.router.navigate(['FINANCIAL'], { queryParams: {status: "Em Aberto"} })
  }
  searchMore(event: any) {
    window.open(`http://google.com/search?q=coffee+producing+${event.label}`, '_blank');
  }

  visiteWebsite(site: any) {
    window.open(`${site}`, '_blank');
  }



  clearToken(menu: PoMenuItem){
    localStorage.setItem('access_token', ' ');
    localStorage.setItem('menu_acesso', ' ');
    localStorage.setItem('cod_vendedor', ' ');
    localStorage.setItem('cod_cliente', ' ');
    localStorage.setItem('user', ' ');
    localStorage.setItem('tipo', ' ');
    localStorage.setItem('cod_usuario', ' ');
  }

}

