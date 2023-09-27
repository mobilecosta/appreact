import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from '../login/login.component';
import { LoginService } from '../login/login.service';
import { HomeComponent } from './home.component';
import { AuthInterceptor } from '../auth/auth-config.interceptor';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { AuthGuardService } from '../auth/auth-guard.service';

const homeRoutes: Routes = [
  { path: '', component: HomeComponent,
    canActivate: [AuthGuardService],
    children: [] },
    {path:'login', component: LoginComponent},
    {path: 'CUSTOMERS', loadChildren: () => import('../cadastrais/clientes/clientes.module').then(m => m.ClientesModule)},
    {path: 'PRODUCTS', loadChildren: () => import('../cadastrais/produtos/produtos.module').then(m => m.ProdutosModule)},
    {path: 'INVOICE', loadChildren: () => import('../vendas/notas/notas.module').then(m => m.NotasModule)},
    {path: 'COMISSION', loadChildren: () => import('../gerenciais/comissoes/comissoes.module').then(m => m.ComissoesModule)},
    {path: 'SALES', loadChildren: () => import('../vendas/pedidos/pedidos.module').then(m => m.PedidosModule)},
    {path: 'FINANCIAL', loadChildren: () => import('../financial/titulos/titulos.module').then(m => m.TitulosModule)},
    {path: 'FATURAMENTO', loadChildren: () => import('../financial/faturamento/faturamento.module').then(m => m.FaturamentoModule)},
    {path: 'CATALOG', loadChildren: () => import('../catalog/catalog.module').then(m => m.CatalogModule)},
    {path: 'WARRANTY', loadChildren: () => import('../warranty/warranty.module').then(m => m.WarrantyModule)},
    {path: 'FORMULARIO', loadChildren: () => import('../warranty/formulario/formulario.module').then(m => m.FormularioModule)},
    {path: 'MURAL', loadChildren: () => import('../mural/mural.module').then(m => m.MuralModule)},
    {path: 'trocasenha', loadChildren: () => import('../trocasenha/trocasenha.module').then(m => m.TrocaSenhaModule)}
  ];

@NgModule({
  imports: [RouterModule.forChild(homeRoutes)],
  exports: [RouterModule],
  providers: [
    LoginService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ]
})
export class HomeRoutingModule { }
