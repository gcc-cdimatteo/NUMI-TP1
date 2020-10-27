a = "";

##
##
function res=roundn(x,n)
  res = round(n*x)/n;
endfunction  

## Devuelve una matriz (n+m)*k siendo n la cantidad de columnas de "columnasFiltro" 
## y m la cantidad de columnas de "columasSumatoria".
## Post: Se crea una matriz que contiene la sumatoria de cada columna 
## representada en "matriz" por los valores de "columnasSumatoria" agrupando por
## las columnas representadas en "matriz" por los valores de "columnasFiltro".
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

## Devuelve una matriz n*m siendo m la cantidad original de columnas de la matriz
## y n la cantidad de filas resultantes de aplicar los filtros solicitados.
## Post: Se crea una matriz que contiene el resultante de aplicar los filtros
## correspondientes a la matriz original.
function res = filtradoPorValor(matriz, valores, columnas)
  res = [];
  j = 1;
  for i = 1:rows(matriz)
    esta = false;
    for k = 1:columns(columnas)
      filtro = matriz(i,columnas(1,k));
      l = 1;
      while l <= rows(valores) && esta == false
        if filtro == valores(l,1) esta = true; endif
        l += 1;
      endwhile
    endfor
    if esta res(j,:) = matriz(i,:); j += 1; endif
  endfor
endfunction

## Devuelve -1 si no encuentra la aparicion solicitada y la fila correspondiente
## en caso contrario.
## Post: Se devuelve el valor correspondiente a la fila donde se encuentra el 
## valor solicitado. 
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
    text = num2str([ER_Fuente(i, 1) ER_Region(i, 1) ER_EnGenerada(i, 1)]);
    text = horzcat([char(ER_mes(i, 1)) "\t" char(ER_CentMaq(i, 1)) "\t"],text);
    disp(text);
  endfor
endfunction

function ejercicio_B();
  oferta = load('EnergiasRenovablesSimple.dat');
  demanda = load('DemandaSimple.dat');
  energiaMensual = sumatoriaPorClave(oferta, [ 1 2 ], [ 6 ]); # [ anio mes aporteTotal ]
  for i = 1:rows(energiaMensual)
    anio = energiaMensual(i,1);
    mes = energiaMensual(i,2);
    pos = existeEnMatriz(demanda, [ anio mes ], [ 1 2 ]); #Si pos == -1 hay un error de datos
    energiaMensual(i,4) = energiaMensual(i,3)/demanda(pos,3);
    energiaMensual(i,5) = (energiaMensual(i,4) <= 0.08);
  endfor
endfunction

function ejercicio_C();
  oferta = load('EnergiasRenovablesSimple.dat');
  demanda = load('DemandaSimple.dat');
  
  ofertaFiltrada = filtradoPorValor(oferta, [4;5], [ 4 ]); #Filtro la oferta por fuente == 4 || fuente == 5
  oferta = sortrows(sumatoriaPorClave(ofertaFiltrada, [ 1 4 ], [ 6 ]), [2, 1]); # [ anio fuente aporteTotal ] -> sort fuente asc anio asc
  energiaEolica = filtradoPorValor(oferta, [ 4 ], [ 2 ])(:,3); #Filtro la energia por fuente == 4
  energiaHidraulica = filtradoPorValor(oferta, [ 5 ], [ 2 ])(:,3); #Filtro la energia por fuente == 5
  demandaAnual = sumatoriaPorClave(demanda, [ 1 ], [ 3 ]); # [ anio demandaTotal ]
  energiaTotal = demandaAnual(:,2); 
  years = demandaAnual(:,1);
  
  Data = round(horzcat(years,energiaEolica,energiaEolica./energiaTotal*100,energiaHidraulica,energiaHidraulica./energiaTotal*100,(energiaEolica.+energiaHidraulica),(energiaEolica.+energiaHidraulica)./energiaTotal*100,energiaTotal)*100)/100;
  csvwrite("out/Ej_C.csv",Data)
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
  legend(fig_tit,'location','northeastoutside');
  subplot (2, 1, 2)
  bar(years,horzcat(Data(:,3),Data(:,5),Data(:,7)));
  axis(xlim)
  grid on
  xlabel("Anio")
  ylabel("Consumo respecto al total  [%] ")
  legend(fig_tit,'location','northeastoutside')
  filename = "out/Ej_A.jpg";
  print(filename);
endfunction

function ejercicio_D();
  oferta = load('EnergiasRenovablesSimple.dat');
  ofertaAnualFiltrada = filtradoPorValor(oferta, [101;104;108], [ 5 ]); #Filtro la oferta in region = [101,104,108]
  ofertaAnual = sumatoriaPorClave(ofertaAnualFiltrada, [1 4 5], [6]); ## [ anio fuente region aporteTotal ]
endfunction

function ejercicio_E()
  oferta = load('EnergiasRenovablesSimple.dat');
  ofertaFiltrada = filtradoPorValor(oferta, [2011;2019], [ 1 ]); #Filtro la oferta in anios = [2011,2019]
  aportesAnualesFuente = sumatoriaPorClave(ofertaFiltrada, [ 1 4 ], [ 6 ]); # [ anio fuente aporteTotal ]
  aportesAnualesRegion = sumatoriaPorClave(ofertaFiltrada, [ 1 5 ], [ 6 ]); # [ anio region aporteTotal ]
endfunction

function ejercicio_F();
  oferta = load('EnergiasRenovablesSimple.dat');
  energia = sumatoriaPorClave(oferta, [ 4 ], [ 6 ]); # [ fuente aporteTotal aportePorcentual ]
  total = sum(energia(:,2));
  for i = 1:rows(energia)
    energia(i,3) = energia(i,2)/total*100;
  endfor
  energia = sortrows(energia, [1]);
  disp(energia);
endfunction

function ejercicio_G()
  oferta = load('EnergiasRenovablesSimple.dat');
  mayorCentralFuente = []; # [ fuente central mes region energia ]
  for i = 1:6
    mayorCentralFuente(i, 1) = i;
    mayorCentralFuente(i, 2) = -Inf;
    mayorCentralFuente(i, 3) = 0;
    mayorCentralFuente(i, 4) = 0;
    mayorCentralFuente(i, 5) = 0;
  endfor
  for i = 1:rows(oferta)
    mes = oferta(i,2);
    central = oferta(i,3);
    fuente = oferta(i,4);
    region = oferta(i,5);
    energia = oferta(i,6);
    if central > mayorCentralFuente(fuente, 2)
      mayorCentralFuente(fuente, 2) = central;
      mayorCentralFuente(fuente, 3) = mes;
      mayorCentralFuente(fuente, 4) = region;
      mayorCentralFuente(fuente, 5) = energia;
    endif
  endfor
endfunction

function main()
#  printf("----------Ejercicio A----------\n");
#  ejercicio_A();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio B----------\n");
#  ejercicio_B();
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
  ejercicio_F();
#  printf("-------------------------------\n");
#  printf("----------Ejercicio G----------\n");
#  ejercicio_G();
#  printf("-------------------------------\n");
endfunction

main()
