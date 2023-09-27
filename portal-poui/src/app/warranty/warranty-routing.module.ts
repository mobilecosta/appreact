import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { WarrantyComponent } from './warranty.component';

const routes: Routes = [
  {path: '', component: WarrantyComponent}
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class WarrantyRoutingModule { }
