import { AuthInterceptor } from './../auth/auth-config.interceptor';
import { LoginService } from './../login/login.service';
import { NgModule } from '@angular/core';
import { CardCountModule } from './../generic/card-count/card-count.module';
import { HomeComponent } from './home.component';
import { HomeRoutingModule } from './home-routing.module';
import { SharedModule } from './../shared/shared.module';
import { PoModule, PoDynamicModule, PoFieldModule, PoDividerModule } from '@po-ui/ng-components';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { PoMenuModule,PoChartModule } from '@po-ui/ng-components';


@NgModule({
  imports: [
    SharedModule,
    CardCountModule,
    HomeRoutingModule,
    PoDynamicModule, PoModule, PoFieldModule, PoDividerModule,PoMenuModule,PoChartModule
  ],
  declarations: [
    HomeComponent
  ],
  providers: [
    LoginService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ]
})
export class HomeModule { }
