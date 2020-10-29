a = "";

##
##
function res=roundn(x,n)
  res = round(n*x)/n;
endfunction 

function res=completar_nulos_sort(matriz,columnaFiltro,columnaSumatoria,valores)
  for val=valores
    n=rows(matriz);
    if (any(matriz(:,columnaFiltro) == val) == 0)
      matriz(n+1,[columnaFiltro,columnaSumatoria])=[val 0];
    endif
  endfor
  res=sortrows(matriz,columnaFiltro);
endfunction 

## Devuelve una matriz (n+m)*k siendo n la cantidad de columnas de "columnasFiltro" 
## y m la cantidad de columnas de "columasSumatoria".
## Post: Se crea una matriz que contiene la sumatoria de cada columna 
## representada en "matriz" por los valores de "columnasSumatoria" agrupando por
## las columnas representadas en "matriz" por los valores de "columnasFiltro".
function res = sumatoriaPorClave(matriz, columnasFiltro, columnasSumatoria)
  res = [];
  columnas = 1:columns(columnasFiltro);
  j = 1;
  for i = 1:rows(matriz)
    valores = matriz(i,columnasFiltro);
    pos = existeEnMatriz(res, valores, columnas);
    if pos != -1
      for k = 1:columns(columnasSumatoria)
        res(pos,columns(columnasFiltro)+k) += matriz(i,columnasSumatoria(1,k));
      endfor
    else
      res(j,1:columns(columnasFiltro)) = matriz(i,columnasFiltro);
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
  i = 1;
  while i <= rows(matriz) && pos == -1
    j = columnas(1, 1);
    while j >= 0 && j <= columns(columnas) && pos == -1
      if matriz(i, columnas(1, j)) == valores(1, columnas(1, j))
        if j == columns(columnas) pos = i; endif
        j += 1;
      else
        j = -1;
      endif
    endwhile
    i += 1;
  endwhile
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
    energiaMensual(i,4) = energiaMensual(i,3)/demanda(pos,3)*100; #### ACA PUSE EL PORCENTAJE EN 100 ####
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
  years = energiaTotal_(:,1);energiaTotal=energiaTotal_(:,2);#Defino EnergiaTotal como el total de energia RENOVABLE anual de todas las fuentes.
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
  
  tit_reg = {"BA";"CU";"PA"};
  tit_reg_largo={"Buenos Aires";"Cuyo";"Patagonia"};
  cod_reg = [101 104 108];
  cod_tip = 1:6;
  
  tot_  = sumatoriaPorClave(ofertaAnual,[1],[4]);
  years = tot_(:,1);TOTAL = tot_(:,2);##  la oferta total de las tres regiones
  
  REGION = years;
  for i=1:columns(cod_reg);
    region=cod_reg(i);
    for j=1:columns(cod_tip);
      tipo=cod_tip(j);
      date=ofertaAnual(1,1);
      jdate=1;res=0*(1:rows(years))';
      for fila = 1:rows(ofertaAnual);
        if (ofertaAnual(fila,1)!=date)
          date=ofertaAnual(fila,1);
          jdate+=1;
        endif
        if (ofertaAnual(fila,2)==tipo && ofertaAnual(fila,3)==region);
          res(jdate)+=ofertaAnual(fila,4);
        endif
      endfor
      REGION(:,1+j+6*(i-1)) = res;
  endfor
##  la matriz REGION tiene su primer columna los anios y en las columnas 2:19,
##  esta dividida en tres submatrices correspondientes a ls tres regiones 
##  con el aporte de cada una de los tipos de energia.
  
  DATA{1,1}   =REGION(:,1);
  DATA{1,i+1} =REGION(:,(1+6*(i-1)).+(1:6));
  DATA;

##  DATA es un cellarray con el mismo formato que explique
##  para REGION de la forma 
##                      {years reg1 reg2 reg3}
##  durante el proximo loop le agrego en la segunda fila las
##  matrices porcentuales, quedando DATA asi de la forma
##                    {years reg1 reg2 reg3
##                     years por1 por2 por3}
 
  endfor
  csvwrite("out/Ej_D.csv",REGION)
  
  for region = 1:columns(cod_reg);
    reg = cod_reg(region);
    reg_abs = DATA{1,region+1};
    tot_reg = sum(reg_abs');
    reg_por = roundn(reg_abs./tot_reg'.*100,4);
    DATA{2,1}=DATA{1,1};DATA{2,region+1}=reg_por;
    
    disp("---------------------")
    disp(["La oferta de energ�a anual en " tit_reg_largo{region} " por tipo de energ�a fue de:"])
    disp("(de izquierda a derecha segun codigo de tipo)"),disp("")
    num2str(horzcat(DATA{1,1},reg_abs)),disp("")
    disp("la misma como porcentaje de todos los tipos en la region")
    num2str(horzcat(DATA{1,1},reg_por)),disp("")
    disp("---------------------")
    csvwrite(strcat("out/Ej_D_",tit_reg{region},".csv"),horzcat(DATA{1,1},reg_abs))
    csvwrite(strcat("out/Ej_D_",tit_reg{region},"_[%].csv"),horzcat(DATA{1,1},reg_por))
    
    X     =DATA{1,1};
    Y     =DATA{1,region+1};
    Y_per =DATA{2,region+1};
    
##  GRAPHING


    tipos_tit={"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};
    xlim=[2010.5 2020.5];
    figure(1+region)
      subplot (2, 1, 1)
      bar(X,Y,0.9,'stacked')
    title(["Consumo anual por tipo en " tit_reg_largo{region}])
    axis(xlim)
    grid on
    ylabel("[GWh]")
    legend(tipos_tit,'location',"northeastoutside")
      subplot (2, 1, 2)
      bar(X,Y_per,0.9,'stacked')
    title("Consumo respecto al total regional")
    axis(horzcat(xlim,[0 100]))
    grid on
    ylabel(" [%] ")
    legend(tipos_tit,'location',"northeastoutside")

      filename=strcat("out/Ej_D_fig_",tit_reg{region},".jpg");
      print(filename) 
  endfor
endfunction

function ejercicio_E()
  oferta = load('EnergiasRenovablesSimple.dat');
  oferta2011 = filtradoPorValor(oferta, [2011], [ 1 ]);
  FUENTE2011 = sumatoriaPorClave(oferta2011, [ 1 4 ], [ 6 ])(:,2:3);
  REGION2011 = sumatoriaPorClave(oferta2011, [ 1 5 ], [ 6 ])(:,2:3);
  oferta2019 = filtradoPorValor(oferta, [2019], [ 1 ]);
  FUENTE2019 = sumatoriaPorClave(oferta2019, [ 1 4 ], [ 6 ])(:,2:3);
  REGION2019 = sumatoriaPorClave(oferta2019, [ 1 5 ], [ 6 ])(:,2:3);
  
  DATA={FUENTE2011 FUENTE2019;REGION2011 REGION2019};
  
  valores = {1:6;101:108};
  for i=1:2
    for j=1:2
      DATA{i,j}=completar_nulos_sort(DATA{i,j},1,2,valores{i,:});
    endfor
  endfor  
  
  TIPO       = cell2mat(horzcat(DATA(1,:)))(:,[2,4]);
  REGION     = cell2mat(horzcat(DATA(2,:)))(:,[2,4]);
  TIPO,REGION
  TIPO_porcentual   = roundn(TIPO  ./sum(TIPO  )*100,2);
  REGION_porcentual = roundn(REGION./sum(REGION)*100,2);
  TIPO_porcentual,REGION_porcentual

  csvwrite("out/Ej_E_TIPO.csv",TIPO);
  csvwrite("out/Ej_E_REGION.csv",REGION);
  csvwrite("out/Ej_E_TIPO_por.csv",TIPO_porcentual);
  csvwrite("out/Ej_E_REGION_por.csv",REGION_porcentual);

##  GRAPHING
  tit_reg = {"BS AS";"CENTRO";"COMAHUE";"CUYO";"LITORAL";"NOR-ES";"NOR-OES";"PATAG"};
  cod_reg = 101:108 ;
  tit_tip = {"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};
  cod_tip = 1:6;
  
      years={"2011";"2019"};
  figure(5)
    subplot(2,1,1)
      bar(cod_tip',TIPO(:,1:2))
      title("Oferta de energia por tipo en todas las regiones en 2011 y 2019 [GWh]")
      axis([0.5 6.5])
      grid on
      ylabel("[GWh]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_tip)
    subplot(2,1,2)
      bar(cod_tip',TIPO_porcentual(:,1:2))
      title("Oferta de energia [%] por tipo de todas las regiones en 2011 y 2019")
      axis([0.5 6.5])
      grid on
      ylabel("[%]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_tip)

  figure(6)      
    subplot(2,1,1)
      bar(cod_reg.-100',REGION(:,1:2))
      title("Oferta de energia por region de todos los tipos en 2011 y 2019 [GWh]")
      axis([0.5 8.5])
      grid on
      ylabel("[GWh]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_reg)
      
    subplot(2,1,2)
      bar(cod_reg.-100',REGION_porcentual(:,1:2))
      title("Oferta de energia [%] por region de todos los tipos en 2011 y 2019")
      axis([0.5 8.5])
      grid on
      ylabel("[%]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_reg)
      
      print(5,"out/Ej_E_tipo.jpg")
      print(6,"out/Ej_E_region.jpg")
  
endfunction

function ejercicio_F();
##  oferta = load('EnergiasRenovablesSimple.dat');
##  energiaMensual = sumatoriaPorClave(oferta, [ 1 2 4 ], [ 6 ]); # [ anio mes fuente aporteTotal ]
##  energiaAnual = sumatoriaPorClave(energiaMensual, [ 1 3 ], [ 4 ]); # [ anio fuente aporteTotal ]
##  for i = 1:rows(energiaMensual)
##    anio = energiaMensual(i,1);
##    fuente = energiaMensual(i,3);
##    pos = existeEnMatriz(energiaAnual, [ anio fuente ], [ 1 2 ]);
##    totalAnual = energiaAnual(pos,3);
##    if totalAnual == 0
##      energiaMensual(i,5) = 0;
##    else
##      totalMensual = energiaMensual(i,4);
##      energiaMensual(i,5) = totalMensual/totalAnual*100;
##    endif
##  endfor
##  disp(energiaMensual) # [ anio mes fuente aporteTotal aportePorcentual ]
##  
##  csvwrite("out/Ej_F - energiaMensual.csv",energiaMensual)



####################
##  c=1;
##  for  i=2011:2020;
##    for j=1:12;
##      while !(i==2020 & j>8)
##        fechas(c,1:2)=[i j];
##      endwhile
##      c+=1;
##    endfor
##  endfor
##  
##  for i = 1:6;
##    data=filtradoPorValor(energiaMensual,[i],[3])(:,[1 2 4 5])
##    for k=1:rows(fechas)
##      n=rows(data);
##      date = data(:,[1 2]);
##      if !(any(date == fechas(k,:)))
##        data(n+1,1:2)= fechas(k,:);
##        data(n+1,2:4)= [0 0];
##      endif
##    endfor
##  data=sortrows(data,[1 2]);
##  DataMensual{i} = data;
##
##  
####    DataMensual{i} = filtradoPorValor(energiaMensual,[i],[3])(:,[1 2 4 5]);
##    csvwrite(strcat("out/Ej_F-Fuente_",num2str(i),".csv"),DataMensual{i})
##    Y(:,i)    = DataMensual{i}(:,3);
##    Y_por(:,i)= DataMensual{i}(:,4)
##  endfor
##  
####  GRAPHING
##  tit_tip = {"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};
##  X=1:rows(DataMensual{1})
##    subplot(2,1,1)
##      plot(X,Y)
##      title("Consumo mensual por fuente")
##      cod_tip = 1:6;
##      legend(tit_tip,'location',"northeastoutside")
##      ylabel("[GWh]")
##    subplot(2,1,2)
##      plot(X,Y_por)
##      legend(tit_tip,'location',"northeastoutside")
##      ylabel("[%]")
##
##############  


for i=1:6
  Data{i}=csvread(strcat("out/Energia_fuente_",num2str(i),".csv"));
  Data{i}=Data{i}(2:rows(Data{i}),:);
  Y(:,i)  = Data{i}(:,3);
  Ypor(:,i)= Data{i}(:,4);
endfor

  X=1:rows(Data{1});X=X';
  tipos_tit={"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};

  figure(7)      
    subplot(2,1,1)
      plot(X,Y,'-')
      title("Oferta de energia mensual por fuente")
      grid on
      ylabel("[GWh]")
      legend(tipos_tit,'location',"northeastoutside")

      
    subplot(2,1,2)
      plot(X,Ypor)
      title("Oferta de energia mensual en relacion a la anual por fuente")
      grid on
      ylabel("[%]")
      xlabel("Meses transcurridos desde Ago2011")
      legend(tipos_tit,'location',"northeastoutside")
      
      print(7,"out/Ej_F.jpg")

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
##  disp("----------Ejercicio D----------\n");
##  ejercicio_D();
##  disp("-------------------------------\n");
##  disp("----------Ejercicio E----------\n");
##  ejercicio_E();
##  disp("-------------------------------\n");
  disp("----------Ejercicio F----------\n");
  ejercicio_F();
  disp("-------------------------------\n");
##  disp("----------Ejercicio G----------\n");
##  ejercicio_G();
##  disp("-------------------------------\n");
endfunction

main()
