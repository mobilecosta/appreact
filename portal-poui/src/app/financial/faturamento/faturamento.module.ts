import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { FaturamentoRoutingModule } from './faturamento-routing.module';
import { PoPageDynamicTableModule } from '@po-ui/ng-templates';



@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    FaturamentoRoutingModule,PoPageDynamicTableModule
  ]
})
export class FaturamentoModule { }
