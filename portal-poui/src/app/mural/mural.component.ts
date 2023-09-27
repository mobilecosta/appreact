import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { environment } from 'src/environments/environment';

@Component({
  templateUrl: './mural.component.html',
  styleUrls: ['./mural.component.css']
})
export class MuralComponent implements OnInit {
  vendedor: boolean = false

  mural: Array<any> = []
  user: string = `${localStorage.getItem('user')}`

  constructor(private http: HttpClient) { }

  ngOnInit(): void {
    if(localStorage.getItem('tipo') == 'vendedor'){
      this.vendedor = !this.vendedor
    }

    const url_metas = environment.api + `/Mural`
    this.http.get(url_metas).subscribe((response: any) =>{
      response[`items`].forEach((element: any) => {
        let data = element['data_publicacao'].split('/')[0]
        let today = new Date()
        var dd = today.getDate()
        if((parseInt(data) + 4) <= dd){
          this.mural.push({codigo: element[`codigo`], assunto: element[`assunto`],conteudo: element[`conteudo`], data_publicacao: element['data_publicacao']})
          return
        }
      });
    })
  }


}
