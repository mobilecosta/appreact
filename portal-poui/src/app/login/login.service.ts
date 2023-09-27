import { User } from './../model/user';
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

import { PoStorageService } from '@po-ui/ng-storage';

import { GenericService } from './../generic/service/generic.service';

@Injectable()
export class LoginService extends GenericService<User> {

  path = 'api/oauth2/v1/token';
  inlogin = false;

  constructor(http: HttpClient, private storage: PoStorageService) {
    super(http);
  }

  isLoggedIn(): Promise<any> {
    return this.storage.get('isLoggedIn');
  }

}
