import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { TitulosRoutingModule } from './titulos-routing.module';
import { PoPageDynamicTableModule } from '@po-ui/ng-templates';



@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    TitulosRoutingModule,PoPageDynamicTableModule
  ]
})
export class TitulosModule { }
