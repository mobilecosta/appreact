import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';

import { TrocaSenhaRoutingModule } from './trocasenha-routing.module';


@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    TrocaSenhaRoutingModule
  ],
  schemas:[CUSTOM_ELEMENTS_SCHEMA]
})
export class TrocaSenhaModule { }
