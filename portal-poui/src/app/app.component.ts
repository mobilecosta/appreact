import { Component, OnDestroy } from '@angular/core';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnDestroy {

  ngOnDestroy(): void {
    localStorage.setItem('access_token', ' ');
    localStorage.setItem('menu_acesso', ' ');
    localStorage.setItem('cod_vendedor', ' ');
    localStorage.setItem('cod_cliente', ' ');
    localStorage.setItem('user', ' ');
    localStorage.setItem('tipo', ' ');
    localStorage.setItem('cod_usuario', ' ');
  }


}
