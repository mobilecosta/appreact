import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { BrowserModule } from '@angular/platform-browser';
import { NgModule,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { HomeModule } from './home/home.module';
import { LoginModule } from './login/login.module';
import { SharedModule } from './shared/shared.module';
import { PoLoadingModule, PoFieldModule, PoNotificationModule } from '@po-ui/ng-components';
import { PoStorageModule } from '@po-ui/ng-storage';
import { ClientesComponent } from './cadastrais/clientes/clientes.component';
import { ProdutosComponent } from './cadastrais/produtos/produtos.component';
import { TitulosComponent } from './financial/titulos/titulos.component';
import { FaturamentoComponent } from './financial/faturamento/faturamento.component';
import { ComissoesComponent } from './gerenciais/comissoes/comissoes.component';
import { NotasComponent } from './vendas/notas/notas.component';
import { PedidosComponent } from './vendas/pedidos/pedidos.component';
import { WarrantyComponent } from './warranty/warranty.component';
import { CatalogComponent } from './catalog/catalog.component';
import { FormularioComponent } from './warranty/formulario/formulario.component';
import { LoginService } from './login/login.service';
import { AuthInterceptor } from './auth/auth-config.interceptor';
import { MuralComponent } from './mural/mural.component';
import { MuralModule } from './mural/mural.module';
import { TrocaSenhaModule } from './trocasenha/trocasenha.module'
import {trocasenha} from './trocasenha/trocasenha.component'



@NgModule({
  imports: [
    AppRoutingModule,
    BrowserModule,
    SharedModule,
    HomeModule,
    LoginModule,
    PoNotificationModule,
    PoLoadingModule,
    PoFieldModule,
    PoStorageModule.forRoot(),
    MuralModule,
    TrocaSenhaModule
  ],
  declarations: [
    AppComponent,
    ClientesComponent,
    ProdutosComponent,
    TitulosComponent,
    FaturamentoComponent,
    ComissoesComponent,
    NotasComponent,
    PedidosComponent,
    WarrantyComponent,
    CatalogComponent,
    FormularioComponent,
    MuralComponent,
    trocasenha
   ],
   providers: [
    LoginService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
 ],
  bootstrap: [AppComponent],
  schemas:[CUSTOM_ELEMENTS_SCHEMA]
})
export class AppModule { }
