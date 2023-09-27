import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { Router } from '@angular/router';

import { PoNotificationService } from '@po-ui/ng-components';
import {
  PoPageChangePassword,
  PoPageChangePasswordComponent,
  PoPageChangePasswordRequirement
} from '@po-ui/ng-templates';

import { environment } from 'src/environments/environment';

@Component({
  selector: 'trocasenha',
  templateUrl: './trocasenha.component.html',
  styleUrls: ['./trocasenha.component.css']
})
export class trocasenha implements OnInit {
  @ViewChild(PoPageChangePasswordComponent, { static: true }) changePassword: PoPageChangePasswordComponent | any;

  hideCurrentPassword: boolean = true;
  recovery: string | any;
  requirement: PoPageChangePasswordRequirement | any;
  requirements: Array<PoPageChangePasswordRequirement> | any;
  urlBack: string | any;
  urlHome: string | any;
  hideload = true

  private headers: HttpHeaders | undefined;


  constructor(
    private httpClient: HttpClient,
    private poNotification: PoNotificationService,
    private router: Router,
    ) {}

  ngOnInit() {
    this.restore();
  }

  addRequirement() {
    this.requirements = [...this.requirements, this.requirement];
    this.requirement = { requirement: '', status: false };
  }

  restore() {
    this.hideCurrentPassword = false;
    this.urlBack = '';
    this.urlHome = '';
    this.recovery = '';
    this.requirement = { requirement: '', status: false };
    this.requirements = [];
  }

  submit(formData: PoPageChangePassword) {
    this.hideload = false
    this.fAuthPass(formData)
  }


  fAuthPass(formData: any){
    let body: any;
    const url_login = environment.api + 'PRTL001';

    this.headers = new HttpHeaders({
      'X-PO-No-Message': 'true',
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });

    body = {USUARIO : localStorage.getItem('login_user'), SENHA : formData.currentPassword};

    this.httpClient.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
      const result: any = res['statusrequest'];

      if (result[0].code == '#200') {
        this.fGrvNewPass(formData)

      } else{
        this.poNotification.error('Falha na autenticação, senha incorreta');
        this.hideload = true
      }
    }, (error) => {
      if (error.hasOwnProperty('message')){
        this.poNotification.error('Falha na autenticação, senha incorreta');
        this.hideload = true
      }

      this.hideload = true
    });

  }


  fGrvNewPass(formData: any){
    let body: any;
    const url_login = environment.api + 'PRTL045';

    this.headers = new HttpHeaders({
      Authorization: 'Basic UjJhbHJFZDRoQWh1MmZSMFRPQnVCTlpxdFM0YTpsUDBUYktKUDdmQ245WGJDUktkM2pYZDFYRW9hIA' });

    body = {USUARIO : localStorage.getItem('login_user'), NEWPASS : formData.newPassword};

    this.httpClient.post(url_login, body, {headers: this.headers}).subscribe((res: any) => {
      const result: any = res['statusrequest'];

      if (result[0].code == '#200') {
        this.hideload = true
        this.poNotification.success('Senha alterada com sucesso!');
        this.router.navigate(['/login']);
      } else{
        this.poNotification.error('Nao alterou a senha #500');
        this.hideload = true
      }
    }, (error) => {
      if (error.hasOwnProperty('message')){
        this.poNotification.error('Falha na comunicaçao com servidor');
        this.hideload = true
      }
    });
  }
  

}