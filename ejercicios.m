a = "";

function res=roundn(x,n)
  res = round(n*x)/n;
endfunction  

function res = sumatoriaPorClave(matriz, columnasFiltro, columnasSumatoria)
  res = [];
  columnas = [];
  for i = 1:columns(columnasFiltro) columnas(1,i) = i; endfor
  j = 1;
  for i = 1:rows(matriz)
    valores = [];
    for k = 1:columns(columnasFiltro)
      valores(1,k) = matriz(i,columnasFiltro(1,k));
    endfor
    pos = existeEnMatriz(res, valores, columnas);
    if pos != -1
      for k = 1:columns(columnasSumatoria)
        res(pos,columns(columnasFiltro)+k) += matriz(i,columnasSumatoria(1,k));
      endfor
    else
      for k = 1:columns(columnasFiltro)
        res(j, columnas(1,k)) = matriz(i,columnasFiltro(1,k));
      endfor
      for k = 1:columns(columnasSumatoria)
        res(j, columns(columnasFiltro)+k) = matriz(i,columnasSumatoria(1,k));
      endfor
      j += 1;
    endif
  endfor
endfunction

function pos = existeEnMatriz(matriz, valores, columnas);
  pos = -1;
  for i = 1:rows(matriz)
    j = columnas(1, 1);
    while j >= 0 && j <= columns(columnas) && pos == -1
      if matriz(i, columnas(1, j)) == valores(1, columnas(1, j))
        if j == columns(columnas) pos = i; endif
        j += 1;
      else
        j = -1;
      endif
    endwhile
  endfor
endfunction

function ejercicio_A();
  #Demanda
  [DT_mes, DT_demandaTotal] = textread("Demanda.dat", "%s %f", "headerlines", 1);
  for i = 1:rows(DT_demandaTotal);
    if i == 1 printf("%s  %s \n", "Mes", "Demanda Total"); endif
    printf("%s  %f\n", char(DT_mes(i, 1)), DT_demandaTotal(i, 1));
  endfor
  #EnergiasRenovables
  [ER_mes, ER_CentMaq, ER_Fuente, ER_Region, ER_EnGenerada] = textread("EnergiasRenovables.dat", "%s %s %d %d %f", "headerlines", 1);
  for i = 1:rows(ER_Fuente);
    if i == 1 printf("%s %s %s %s %s \n", "Mes", "CentMaq", "Fuente", "Region", "EnGenerada [GWh]"); endif
    text= num2str([ER_Fuente(i, 1) ER_Region(i, 1) ER_EnGenerada(i, 1)]);
    text= horzcat([char(ER_mes(i, 1)) "\t" char(ER_CentMaq(i, 1)) "\t"],text);
    disp(text)
  endfor
endfunction

function ejercicio_B();
  oferta = load('EnergiasRenovablesSimple.dat');
  demanda = load('DemandaSimple.dat');
  energiaMensual = sumatoriaPorClave(oferta, [ 1 2 ], [ 6 ]);
  for i = 1:rows(energiaMensual)
    anio = energiaMensual(i,1);
    mes = energiaMensual(i,2);
    pos = existeEnMatriz(demanda, [ anio mes ], [ 1 2 ]); #Si pos == -1 hay un error de datos
    energiaMensual(i,4) = energiaMensual(i,3)/demanda(pos,3);
    energiaMensual(i,5) = (energiaMensual(i,4) <= 0.08);
  endfor
  csvwrite("Ej_B.csv", energiaMensual)
endfunction

function ejercicio_C();
  oferta = load('EnergiasRenovablesSimple.dat');
  energia = []; ## [ anio fuente aporte demandaAnual ]
  j = 1;
  for i = 1:rows(oferta)
    anio = oferta(i,1);
    fuente = oferta(i,4);
    aporte = oferta(i,6);
    if fuente == 4 || fuente == 5
      pos = existeEnMatriz(energia, [ anio fuente ], [ 1 2 ]);
      if pos != -1
          energia(pos,3) += aporte;
      else
          energia(j,1) = anio;
          energia(j,2) = fuente;
          energia(j,3) = aporte;
          j += 1;
      endif
    endif
  endfor
  energia = sortrows(energia, [2, 1]);
  pos = -1;
  i = 1;
  while i <= rows(energia) && pos == -1
    if energia(i,2) == 5 pos = i; endif
    i += 1;
  endwhile
  en_Eol = energia(1:pos-1,:)(:,3);
  en_Hid = energia(pos:rows(energia),:)(:,3);
  demandaAnual = sortrows(demandaAnual(),[1]);
  en_Tot = demandaAnual(:,2);
  years = demandaAnual(:,1);
  
  Data = round(horzcat(years,en_Eol,en_Eol./en_Tot*100,en_Hid,en_Hid./en_Tot*100,(en_Eol.+en_Hid),(en_Eol.+en_Hid)./en_Tot*100,en_Tot)*100)/100;
  csvwrite("Ej_C.csv",Data)
  titulos=["Anio\t" "Eolica\t" "Eolica (%)\t" "Hidra\t" "Hidra (%)\t" "Eoli+Hidra\t" "Eoli+Hidra (%)\t" "En Total"];
  disp(titulos);
  num2str(Data);
  
  #  Graficos
  fig_tit={"Eolica";"Hidraulica";"Eolica + Hidraulica"};
  xlim=[2010.5 2020.5]
  figure(1)
  subplot (2, 1, 1)
    bar(years,horzcat(Data(:,2),Data(:,4)));
    title("Consumo anual de energia eolica e hidraulica")
    axis(xlim)
    grid on
    xlabel("Anio")
    ylabel("Consumo anual [GWh]")
    legend(fig_tit,'location','northeastoutside')
  subplot (2, 1, 2)
    bar(years,horzcat(Data(:,3),Data(:,5),Data(:,7)));
    axis(xlim)
    grid on
    xlabel("Anio")
    ylabel("Consumo respecto al total  [%] ")
    legend(fig_tit,'location','northeastoutside')
  filename = "Ej_A.jpg"
  print(filename)  
endfunction

function demandaAnual = demandaAnual()
  demanda = load('DemandaSimple.dat');
  demandaAnual = [];
  j = 1;
  for i = 1:rows(demanda)
    anio = demanda(i,1);
    aporte = demanda(i,3);
    pos = existeEnMatriz(demandaAnual, [ anio ], [ 1 ]);
    if pos != -1
      demandaAnual(pos,2) += aporte;
    else
      demandaAnual(j,1) = anio;
      demandaAnual(j,2) = aporte;
      j += 1;
    endif
  endfor
endfunction

function ejercicio_D();
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  years = demanda_anual(dem)(:,1);
  n_years = rows(years);
  
  tit_reg = {"BA";"CU";"PA"};
  tit_reg_largo = {"Buenos Aires";"Cuyo";"Patagonia"};
  cod_reg = [101,104,108];

  ofertaAnual = sumatoriaPorClave(ofe, [1 4 5], [6]); ## [anio fuente region aporteTotal]
  ofertaAnualFiltrada = []; ## [ anio fuente region aporteTotal ]
  j = 1;
  for i = 1:rows(ofertaAnual)
    region = ofertaAnual(i,3);
    for k = 1:columns(cod_reg)
      if cod_reg(k) == region
        ofertaAnualFiltrada(j,:) = ofertaAnual(i,:);
        j += 1;
      endif
    endfor
  endfor
endfunction

function ejercicio_E()
  energiasRenovables = load('EnergiasRenovablesSimple.dat');
  aportesAnualesFuente = [];
  aportesAnualesRegion = [];
  contFuente = 1;
  contRegion = 1;
  for i = 1:rows(energiasRenovables)
    anio = energiasRenovables(i,1);
    if anio == 2011 || anio == 2019
      fuente = energiasRenovables(i,4);
      region = energiasRenovables(i,5);
      aporte = energiasRenovables(i,6);
      existePosFuente = existeEnMatriz(aportesAnualesFuente, [ anio fuente ], [ 1 2 ]);
      ## Fuente
      if existePosFuente != -1
        aportesAnualesFuente(existePosFuente,3) += aporte;
      else
        aportesAnualesFuente(contFuente,1) = anio;
        aportesAnualesFuente(contFuente,2) = fuente;
        aportesAnualesFuente(contFuente,3) = aporte;
        contFuente += 1;
      endif
      ## Region
      existePosRegion = existeEnMatriz(aportesAnualesRegion, [ anio region ], [ 1 2 ]);
      if existePosRegion != -1
        aportesAnualesRegion(existePosRegion,3) += aporte;
      else
        aportesAnualesRegion(contRegion,1) = anio;
        aportesAnualesRegion(contRegion,2) = region;
        aportesAnualesRegion(contRegion,3) = aporte;
        contRegion += 1;
      endif
    endif
  endfor
  disp(aportesAnualesFuente);
  disp(aportesAnualesRegion);
endfunction

function ejercicio_F();
  energiasRenovables = load('EnergiasRenovablesSimple.dat');
  totalAnual = [];
  totalMensual = [];
  contAnual = 1;
  contMensual = 1;
  for i = 1:rows(energiasRenovables)
    anio = energiasRenovables(i,1);
    aporte = energiasRenovables(i,6);
    pos = existeEnMatriz(totalAnual, [ anio ], [ 1 ]);
    if pos != -1
      totalAnual(pos, 2) += aporte;
    else
      totalAnual(contAnual, 1) = anio;
      totalAnual(contAnual, 2) = aporte;
      contAnual += 1;
    endif
  endfor
  for i = 1:rows(energiasRenovables)
    anio = energiasRenovables(i,1);
    mes = energiasRenovables(i,2);
    aporte = energiasRenovables(i,6);
    pos = existeEnMatriz(totalMensual, [ anio mes ], [ 1 2 ]);
    if pos != -1
      totalMensual(pos, 3) += aporte;
    else
      totalMensual(contMensual, 1) = anio;
      totalMensual(contMensual, 2) = mes;
      totalMensual(contMensual, 3) = aporte;
      contMensual += 1;
    endif
  endfor
  for i = 1:rows(totalAnual)
    totalAnual(i,3) = totalAnual(i,2)*100/sum(totalAnual(:,2));
  endfor
  for i = 1:rows(totalMensual)
    anio = totalMensual(i,1);
    pos = existeEnMatriz(totalAnual, [ anio ], [ 1 ]);
    totalMensual(i,4) = 100*totalMensual(i,3)/totalAnual(pos,2);
  endfor
  disp(totalAnual);
  disp(totalMensual);
endfunction

function ejercicio_G()
  energiasRenovables = load('EnergiasRenovablesSimple.dat');
  mayorCentralFuente = [];
  for i = 1:6
    mayorCentralFuente(i, 1) = i; #Fuente
    mayorCentralFuente(i, 2) = -Inf; #Central
    mayorCentralFuente(i, 3) = 0; #Mes
    mayorCentralFuente(i, 4) = 0; #Region
    mayorCentralFuente(i, 5) = 0; #Energia
  endfor
  for i = 1:rows(energiasRenovables)
    fuente = energiasRenovables(i,4);
    central = energiasRenovables(i,3);
    mes = energiasRenovables(i,2);
    region = energiasRenovables(i,5);
    energia = energiasRenovables(i,6);
    if central > mayorCentralFuente(fuente, 2)
      mayorCentralFuente(fuente, 2) = central;
      mayorCentralFuente(fuente, 3) = mes;
      mayorCentralFuente(fuente, 4) = region;
      mayorCentralFuente(fuente, 5) = energia;
    endif
  endfor
  disp(mayorCentralFuente);
endfunction

function main()
#  printf("----------Ejercicio A----------\n");
#  ejercicio_A();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio B----------\n");
  ejercicio_B();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio C----------\n");
#  ejercicio_C();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio D----------\n");
#  ejercicio_D();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio E----------\n");
#  ejercicio_E();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio F----------\n");
#  ejercicio_F();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio G----------\n");
#  ejercicio_G();
#  printf("-------------------------------\n");
endfunction

main()