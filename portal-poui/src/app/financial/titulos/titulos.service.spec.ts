import { TestBed } from '@angular/core/testing';

import { TitulosService } from './titulos/titulos.service';

describe('TitulosService', () => {
  let service: TitulosService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TitulosService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
