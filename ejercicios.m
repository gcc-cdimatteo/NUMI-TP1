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
##  columnas = [];
##  for i = 1:columns(columnasFiltro) columnas(1,i) = i; endfor
  columnas = 1:columns(columnasFiltro);
  j = 1;
  for i = 1:rows(matriz)
##    valores = [];
##    for k = 1:columns(columnasFiltro)
##      valores(1,k) = matriz(i,columnasFiltro(1,k));
##    endfor
    valores = matriz(i,columnasFiltro);
    pos = existeEnMatriz(res, valores, columnas);
    if pos != -1
      for k = 1:columns(columnasSumatoria)
        res(pos,columns(columnasFiltro)+k) += matriz(i,columnasSumatoria(1,k));
      endfor
    else
##      for k = 1:columns(columnasFiltro)
##        res(j, columnas(1,k)) = matriz(i,columnasFiltro(1,k));
##      endfor
      res(j,1:columns(columnasFiltro))=matriz(i,columnasFiltro);
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
    energiaMensual(i,4) = energiaMensual(i,3)/demanda(pos,3)*100;#### ACA PUSE EL PORCENTAJE EN 100 ####
    energiaMensual(i,5) = (energiaMensual(i,4) <= 8);
  endfor
  csvwrite("out/Ej_B.csv",energiaMensual)
  
##  PRINTING
  printf("%s\t|\t%s\t|\t%s\t|\t%s\t|\t%s\t|\t\n","Anio","Mes","En [GWh]","En [%]","Cumple ley?"),
  disp("----------------------------------------------------------------------")
  printf("%4i\t|\t%2i\t|\t%.1f\t\t|\t%.2f\t|\t%i\n",energiaMensual'),
  disp("----------------------------------------------------------------------")
  cumple=sum(energiaMensual(:,5)==0);
  n_mes =rows(energiaMensual);
  printf("Se cumple con  la ley en %i de %i meses (%.1f%%)\n",cumple,n_mes,cumple/n_mes*100),
  disp("")
  
##  GRAPHING
  i=1:n_mes;
  xlim=[1 n_mes];
  xlab=strcat("t1 = ene2011  ; t",num2str(n_mes)," = ago2020");
  figure(1)
  subplot (2, 1, 1)
    plot(i,energiaMensual(:,3));
    title("Consumo mensual de energia renovable ")
    axis(xlim)
    grid on
##    xlabel(xlab)
    ylabel("[GWh]")
  subplot (2, 1, 2)
    plot(i,energiaMensual(:,4),"r-");
    title("Consumo mensual de energia renovable respecto de la energia total")
    axis(xlim)
    grid on
    xlabel(xlab)
    ylabel("[%]")
  filename = "out\Ej_B.jpg";
  print(filename)
  
endfunction

function ejercicio_C();
  oferta = load('EnergiasRenovablesSimple.dat');
  demanda = load('DemandaSimple.dat');
  
  energiaTotal_ = sumatoriaPorClave(oferta, [ 1 ], [ 6 ]);
  years=energiaTotal_(:,1);energiaTotal=energiaTotal_(:,2);#Defino EnergiaTotal como el total de energia RENOVABLE anual de todas las fuentes.
  ofertaFiltrada = filtradoPorValor(oferta, [4;5], [ 4 ]); #Filtro la oferta por fuente == 4 || fuente == 5
  oferta = sortrows(sumatoriaPorClave(ofertaFiltrada, [ 1 4 ], [ 6 ]), [2, 1]); # [ anio fuente aporteTotal ] -> sort fuente asc anio asc
  energiaEolica = filtradoPorValor(oferta, [ 4 ], [ 2 ])(:,3); #Filtro la energia por fuente == 4
  energiaHidraulica = filtradoPorValor(oferta, [ 5 ], [ 2 ])(:,3); #Filtro la energia por fuente == 5
##  demandaAnual = sumatoriaPorClave(demanda, [ 1 ], [ 3 ]); # [ anio demandaTotal ]
  
  Data = roundn(horzcat(years,energiaEolica,energiaEolica./energiaTotal*100,energiaHidraulica,energiaHidraulica./energiaTotal*100,energiaEolica.+energiaHidraulica,energiaTotal),2);
##  csvwrite("out/Ej_C.csv",Data)
  
##  PRINTING

  titulos=["Anio\t" "Eolica\t" "Eolica (%)\t" "Hidra\t" "Hidra (%)\t" "Eol+Hid\t" "En Total"];
##  printf("%4s\t%s\t\t%s\t\t%s\t\t%s\t\t%s\t\t%s\t\t\n",titulos),
##  disp(titulos)
  printf("%s | %s | %s | %s | %s | %s | %s\n",titulos'),disp("")
  disp("----------------------------------------------------------------------")
  printf("%4i  %9.1f  %9.1f  %9.1f  %9.1f  %9.1f  %9.1f\n",Data'),
  disp("----------------------------------------------------------------------")
  
##  GRAPHING
  fig_tit={"Eolica";"Hidraulica"};
  xlim=[2010.5 2020.5];
  figure(1)
  subplot (2, 1, 1)
  bar(years,horzcat(Data(:,2),Data(:,4)));
  title("Consumo anual de energia eolica e hidraulica")
  axis(xlim)
  grid on
  ylabel("[GWh]")
  legend(fig_tit,'location','northeastoutside');
  subplot (2, 1, 2)
  bar(years,horzcat(Data(:,3),Data(:,5)),0.9,'stacked');
  title("Consumo respecto al total de todas las fuentes")
  axis(xlim)
  grid on
  ylabel("[%]")
  legend(fig_tit{1:2},'location','northeastoutside')
  filename = "out/Ej_A.jpg";
  print(filename);
endfunction

function ejercicio_D();
  oferta = load('EnergiasRenovablesSimple.dat');
  ofertaAnualFiltrada = filtradoPorValor(oferta, [101;104;108], [ 5 ]); #Filtro la oferta in region = [101,104,108]
  ofertaAnual = sumatoriaPorClave(ofertaAnualFiltrada, [1 4 5], [6]); ## [ anio fuente region aporteTotal ]
  ofertaAnual
  
  tit_reg = {"BA";"CU";"PA"};
  tit_reg_largo={"Buenos Aires";"Cuyo";"Patagonia"};
  cod_reg = [101 104 108];
  cod_tip = 1:6;
  
  

  
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
##  disp("----------Ejercicio A----------\n");
##  ejercicio_A();
##  disp("-------------------------------\n");
##  disp("----------Ejercicio B----------\n");
##  ejercicio_B();
##  disp("-------------------------------\n");
##  disp("----------Ejercicio C----------\n");
##  ejercicio_C();
##  disp("-------------------------------\n");
  disp("----------Ejercicio D----------\n");
  ejercicio_D();
  disp("-------------------------------\n");
##  disp("----------Ejercicio E----------\n");
##  ejercicio_E();
##  disp("-------------------------------\n");
##  disp("----------Ejercicio F----------\n");
##  ejercicio_F();
##  disp("-------------------------------\n");
##  disp("----------Ejercicio G----------\n");
##  ejercicio_G();
##  disp("-------------------------------\n");
endfunction

main()
