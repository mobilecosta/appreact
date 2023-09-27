import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { PoNotificationService, PoPageAction } from '@po-ui/ng-components';
import { PoModalPasswordRecoveryType, PoPageLogin, PoPageLoginRecovery,PoPageLoginLiterals } from '@po-ui/ng-templates';
import { PoStorageService } from '@po-ui/ng-storage';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  passwordRecovery: PoPageLoginRecovery = {
    url: '',
    type: PoModalPasswordRecoveryType.All,
    contactMail: 'suporte@robsol.com',
  };
  loginForm: FormGroup | undefined;

  private headers: HttpHeaders | undefined;
  
  customLiterals: PoPageLoginLiterals = {
    loginPlaceholder: 'Insira seu usuário de acesso',
  };

  literals: string | any;
  hideload = true

  constructor(
    private router: Router,
    private httpClient: HttpClient,
    private poNotification: PoNotificationService,
    private formBuilder: FormBuilder

    ) {}
    

    ngOnInit(): void {

      this.loginForm = this.formBuilder.group({
        cpf: [
          '',
          [
            Validators.required,
            Validators.pattern('^[0-9]{11}$'),
            Validators.maxLength(11),
          ],
        ],
     });
    }


  loginSubmit = async(formData: PoPageLogin) =>{
    this.hideload = false

    let body: any;
    const url_login = environment.api + 'PRTL001';

    this.headers = new HttpHeaders({
      'X-PO-No-Message': 'true',
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });

    body = {USUARIO : formData.login, SENHA : formData.password};

    this.httpClient.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
      const fmt_res: any = res['statusrequest'];

      localStorage.setItem('access_token', fmt_res[0].user_token);

      if (fmt_res[0].code == '#200') {

        if(fmt_res[0].cod_cliente.trim() !== ""){
          localStorage.setItem('tipo', 'cliente');
        }
        
        if(fmt_res[0].cod_vendedor.trim() !== ""){
          localStorage.setItem('tipo', 'vendedor');
        }

        localStorage.setItem('login_user', formData.login);
        localStorage.setItem('user', fmt_res[0].nome_usuario);
        localStorage.setItem('cod_usuario', fmt_res[0].Cod_Usuario);
        localStorage.setItem('cod_vendedor', fmt_res[0].cod_vendedor.trim());
        localStorage.setItem('cod_cliente', fmt_res[0].cod_cliente.trim());
        localStorage.setItem('menu_acesso', fmt_res[0].menu_acesso);
        localStorage.setItem('loja_cliente', fmt_res[0].loja_cliente);

        this.router.navigate(['/']);
        this.hideload = true
        
      } else{
          this.poNotification.error(fmt_res[0].Cod_Usuario)
          this.hideload = true
          
      }
    }, (error) => {
        this.poNotification.error('Falha na autenticação, tente novamente')
        this.hideload = true
    });
   
  }

}
