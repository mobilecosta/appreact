import { TestBed } from '@angular/core/testing';

import { ComissoesService } from './comissoes.service';

describe('ComissoesService', () => {
  let service: ComissoesService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ComissoesService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
