
a = "";

function res=roundn(x,n)
  res = round(n*x)/n;
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
    #printf("%s  %s  %d  %d  %f\n", char(ER_mes(i, 1)), char(ER_CentMaq(i, 1)), ER_Fuente(i, 1), ER_Region(i, 1), ER_EnGenerada(i, 1));
    text= num2str([ER_Fuente(i, 1) ER_Region(i, 1) ER_EnGenerada(i, 1)]);
    text= horzcat([char(ER_mes(i, 1)) "\t" char(ER_CentMaq(i, 1)) "\t"],text);
    disp(text)
  endfor
endfunction


function ejercicio_B();
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  n = rows(ofe);
  year  = ofe(1:n,1);
  month = ofe(1:n,2);
  pow   = ofe(1:n,6);
  
  pow_men = [year(1) month(1) pow(1)];
  j=1;
  for i = 2:n;
    date = [year(i) month(i)];
    if ( date(1)!= pow_men(j,1) || date(2)!= pow_men(j,2))
      j+=1;
      pow_men(j,1:2)= date;
    endif
    pow_men(j,3) += pow(i);
  endfor
  disp("")
  disp("Oferta energética mensual"),disp("---------------------------------------------------")
  disp(["Año" "\t|\t" "Mes" "\t|\t" "Energía [GWh]"]),disp("---------------------------------------------------")
  for i=1:j;
    text=pow_men(i,:);
    disp([num2str(text(1)) "\t|\t" num2str(text(2)) "\t|\t" num2str(text(3))])
  endfor

  disp(""),disp("¿Verifica la ley 26.910?"),disp("")
  
  disp(["Oferta / demanda (%)" " | " "Año/Mes" " | " "Verifica?"]),disp("---------------------------------------------------")
  
  n_mes=rows(pow_men);
  total_SI=0;
  for j = 1:n_mes;
    pow_men_100  = num2str(round((pow_men(j,3)/dem(j,3))*10000)/100);
    pow_men(j,4) = pow_men(j,3)/dem(j,3);
    date = [num2str(dem(j,1)) " / " num2str(dem(j,2))];
    if pow_men(j,4) <= 0.08
      disp(horzcat([pow_men_100 "\t|\t"],date,["\t|\t" "NO"]))
    else 
      disp(horzcat([pow_men_100 "\t|\t"],date,["\t|\t\t" "SI"]))
      total_SI+=1;
    endif
  endfor
  disp("---------------------------------------------------")
  disp("")
  disp(["Se cumplió con la ley en " num2str(total_SI) " de " num2str(n_mes) " meses."]),disp("")
  
  csvwrite("Ej_B.csv",pow_men)
endfunction

function ejercicio_C();

#  En este ejercicio habia un par de endif´s que no le pusieron condicion,
#  y por eso tiraba error en el command window y pedia parentesis. 
#  Solo habia que cambiarlos por else.
  
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  
  en_Eol  = pow_an(4,4,ofe)(:,2);
  en_Hid  = pow_an(4,5,ofe)(:,2);
  en_Tot  = demanda_anual(dem)(:,2);
  years   = demanda_anual(dem)(:,1);
  n_mes   = rows(en_Tot);
  
  Data = round(horzcat(years,en_Eol,en_Eol./en_Tot*100,en_Hid,en_Hid./en_Tot*100,(en_Eol.+en_Hid),(en_Eol.+en_Hid)./en_Tot*100,en_Tot)*100)/100;
  csvwrite("Ej_C.csv",Data)
  titulos=["Año\t" "Eolica\t" "Eolica (%)\t" "Hidra\t" "Hidra (%)\t" "Eoli+Hidra\t" "Eoli+Hidra (%)\t" "En Total"];
  disp(titulos)
  num2str(Data)
  
##  Graficos
  fig_tit={"Eolica";"Hidraulica";"Eolica + Hidraulica"};
  xlim=[2010.5 2020.5]
  figure(1)
  subplot (2, 1, 1)
    bar(years,horzcat(Data(:,2),Data(:,4)));
    title("Consumo anual de energía eólica e hidraulica")
    axis(xlim)
    grid on
    xlabel("Año")
    ylabel("Consumo anual [GWh]")
    legend(fig_tit,'location','northeastoutside')
  subplot (2, 1, 2)
    bar(years,horzcat(Data(:,3),Data(:,5),Data(:,7)));
    axis(xlim)
    grid on
    xlabel("Año")
    ylabel("Consumo respecto al total  [%] ")
    legend(fig_tit,'location','northeastoutside')
  filename = "Ej_A.jpg"
  print(filename)  
    
endfunction

function res = pow_an(col,cod,ofe) 
##  Esta funcion se usa en C,D...
##  Esta funcion devuelve una matriz de nx2 = [año_j oferta_anual] 
##  para el tipo/region que se especifique segun los códigos:

## tipo => col=4 --- region => col=5

##    1    BIODIESEL
##    2    BIOGAS
##    3    BIOMASA
##    4    EOLICO
##    5    HIDRO <=50MW
##    6    SOLAR

##  101   BUENOS AIRES
##  102   CENTRO
##  103   COMAHUE
##  104   CUYO
##  105   LITORAL
##  106   NORESTE
##  107   NOROESTE
##  108   PATAGONIA

n = rows(ofe);
year  = ofe(1:n,1);
pow   = ofe(1:n,6);
col  = ofe(1:n,col);
res = [year(1) 0];
j=1;

for i = 1:n;
  date = [year(i)];
  if ( date(1)!= res(j,1))
    j+=1;
    res(j,1) = date;
  endif
  if ( col(i)== cod )
        res(j,2) += pow(i);
  endif
endfor
endfunction


function res = demanda_anual(dem)
#  Esta funcion devuelve una matriz de 2xn = [año_j demanda_anual]
  n     = rows(dem);
  year  = dem(:,1);
  res   = [year(1) 0];
  j=1;
for i = 1:n;
  date = [year(i)];
  if ( date(1)!= res(j,1))
    j+=1;
    res(j,1)= date;
  endif
  res(j,2)+= dem(i,3);
endfor
endfunction

function res = oferta_anual_xtipoyreg(ofe,tipo,reg)
#  Esta funcion devuelve una matriz de 2xn = [año_j demanda_anual]
#  del tipo de energia segun el codigo.
  n     = rows(ofe);
  year  = ofe(:,1);
  res   = [year(1) 0];
  j=1;
for i = 1:n;
  date = [year(i)];
  if (ofe(i,4)==tipo && ofe(i,5)==reg)
    if ( date(1)!= res(j,1) )
      j+=1 ;
      res(j,1) = date ;
    endif
    res(j,2)+= ofe(i,6);
  endif
endfor
endfunction

function ejercicio_D();
  
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  years   = demanda_anual(dem)(:,1);
  n_years  = rows(years);
  
  tit_reg = {"BA";"CU";"PA"};
  tit_reg_largo={"Buenos Aires";"Cuyo";"Patagonia"}
  cod_reg = [101,104,108];

  Data=[];
  for region = 1:columns(cod_reg);
    reg = cod_reg(region);
    for tipo = 1:6
      En_T_R(:,tipo) = oferta_anual_xtipoyreg(ofe,tipo,reg)(:,2);
    endfor
    total= pow_an(5,reg,ofe)(:,2);
    En_T_R_per(:,1:6) = roundn(En_T_R(:,1:6)./total*100,2);
    Reg_Tip{1,region} = roundn(horzcat(years,En_T_R),2);
    Reg_Tip{2,region} = horzcat(years,En_T_R_per);
    
    disp("---------------------")
    disp(["La oferta de energía anual en " tit_reg_largo{region} " por tipo de energía fue de:"])
    disp("(de izquierda a derecha segun codigo de tipo)"),disp("")
    num2str(Reg_Tip{1,region}),disp("")
    disp("la misma como porcentaje de todos los tipos en la region")
    num2str(Reg_Tip{2,region})
    disp("---------------------")
    csvwrite(strcat("Ej_D_",tit_reg{region},".csv"),Reg_Tip{1,region})
    csvwrite(strcat("Ej_D_",tit_reg{region},"_[%].csv"),Reg_Tip{2,region})
    
    X     =Reg_Tip{1,region};
    X_per =Reg_Tip{2,region};
    
##    Graficos
    tipos_tit={"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};
    xlim=[2010.5 2020.5]
    figure(1+region)
      subplot (2, 1, 1)
      bar(X(:,1),X(:,2:7),0.9,'stacked')
    title(["Consumo anual por tipo en " tit_reg_largo{region} " [GWh]"])
    axis(xlim)
    grid on
    xlabel("Año")
    ylabel("Consumo anual [GWh]")
    legend(tipos_tit,'location',"northeastoutside")
      subplot (2, 1, 2)
      bar(X_per(:,1),X_per(:,2:7),0.9,'stacked')
    axis(horzcat(xlim,[0 100]))
    grid on
    xlabel("Año")
    ylabel("Consumo respecto al total regional [%] ")
    legend(tipos_tit,'location',"northeastoutside")

    filename=strcat("Ej_D_fig_",tit_reg{region},".jpg");
    print(filename) 
  endfor

  csvwrite("Ej_D.csv",cell2mat(Reg_Tip))



endfunction

function res = pow_an_reg_tipo(reg,tipo,ofe);
  n = rows(ofe);
  year  = ofe(1:n,1);
  pow   = ofe(1:n,6);
  col  = ofe(1:n,col);
  res = [year(1) 0];
  j=1;

  for i = 1:n;
    date = [year(i)];
    if ( date(1)!= res(j,1))
      j+=1;
      res(j,1) = date;
    endif
    if ( col(i)== cod )
          res(j,2) += pow(i);
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

function ejercicio_E_()
  energiasRenovables = load('EnergiasRenovablesSimple.dat');
  aportesAnualesFuente = [];
  aportesAnualesRegion = [];
  contFuente = 1;
  contRegion = 1;
  for i = 1:rows(energiasRenovables)
    anio = energiasRenovables(i,1);
    fuente = energiasRenovables(i,4);
    aporte = energiasRenovables(i,6);
    existePos = existeEnMatriz(aportesAnualesFuente, [ anio fuente ], [ 1 2 ]);
    if existePos != -1
      aportesAnualesFuente(existePos,3) += aporte;
    else
      aportesAnualesFuente(contFuente,1) = anio;
      aportesAnualesFuente(contFuente,2) = fuente;
      aportesAnualesFuente(contFuente,3) = aporte;
      contFuente += 1;
    endif
  endfor
  disp(aportesAnualesFuente);
  for i = 1:rows(energiasRenovables)
    anio = energiasRenovables(i,1);
    region = energiasRenovables(i,5);
    aporte = energiasRenovables(i,6);
    existePos = existeEnMatriz(aportesAnualesRegion, [ anio region ], [ 1 2 ]);
    if existePos != -1
      aportesAnualesRegion(existePos,3) += aporte;
    else
      aportesAnualesRegion(contRegion,1) = anio;
      aportesAnualesRegion(contRegion,2) = region;
      aportesAnualesRegion(contRegion,3) = aporte;
      contRegion += 1;
    endif
  endfor
  disp(aportesAnualesRegion);
endfunction


function ejercicio_E()
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  years   = demanda_anual(dem)(:,1);
  n_years  = rows(years);
  tit_reg = {"BS AS";"CENTRO";"COMAHUE";"CUYO";"LITORAL";"NOR-ES";"NOR-OES";"PATAG"};
  cod_reg = 101:108 ;
  tit_tip = {"BIODIESEL";"BIOGAS";"BIOMASA";"EOLICO";"HIDRO";"SOLAR"};
  cod_tip = 1:6;
  
  tipo_2011(cod_tip,1)  = pow_an_(4,cod_tip,ofe,2011);
  tipo_2019(cod_tip,1)  = pow_an_(4,cod_tip,ofe,2019);
  
  region_2011(cod_reg-100,1)  = pow_an_(5,cod_reg,ofe,2011);
  region_2019(cod_reg-100,1)  = pow_an_(5,cod_reg,ofe,2019);
  
  TIPO=horzcat(tipo_2011,tipo_2019);
  TIPO(:,3)=roundn((TIPO(:,2)./TIPO(:,1)-1)*100,2)

  
  REGION=horzcat(region_2011,region_2019);
  REGION(:,3)=roundn((REGION(:,2)./REGION(:,1)-1)*100,2)

  for i=1:2
    TIPO_porcentual(:,i) = roundn(TIPO(:,i)./sum(TIPO(:,i))*100,2);
    REGION_porcentual(:,i) = roundn(REGION(:,i)./sum(REGION(:,i))*100,2);
  endfor

  TIPO_porcentual
  REGION_porcentual  

  csvwrite("Ej_E_TIPO.csv",TIPO);
  csvwrite("Ej_E_TIPO_por.csv",TIPO_porcentual);
  csvwrite("Ej_E_REGION.csv",REGION);
  csvwrite("Ej_E_REGION_por.csv",REGION_porcentual);
  
  
##  Graficos
    years={"2011";"2019"};
    figure(5)
    subplot(2,1,1)
      bar(cod_tip',TIPO(:,1:2))
      title("Oferta de energia por tipo en todas las regiones en 2011 y 2019 [GWh]")
      axis([0.5 6.5])
      grid on
      xlabel("Tipo de energia")
      ylabel("Consumo anual [GWh]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_tip)
    subplot(2,1,2)
      bar(cod_tip',TIPO_porcentual(:,1:2))
      title("Oferta de energia [%] por tipo de todas las regiones en 2011 y 2019")
      axis([0.5 6.5])
      grid on
      xlabel("Tipo")
      ylabel("Consumo anual [%]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_tip)

figure(6)      
    subplot(2,1,1)
      bar(cod_reg.-100',REGION(:,1:2))
      title("Oferta de energia por region de todos los tipos en 2011 y 2019 [GWh]")
      axis([0.5 8.5])
      grid on
      xlabel("Region")
      ylabel("Consumo anual [GWh]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_reg)
      
    subplot(2,1,2)
      bar(cod_reg.-100',REGION_porcentual(:,1:2))
      title("Oferta de energia [%] por region de todos los tipos en 2011 y 2019")
      axis([0.5 8.5])
      grid on
      xlabel("Region")
      ylabel("Consumo anual [%]")
      legend(years,'location',"northeastoutside")
      set(gca,"xticklabel",tit_reg)
      
      print(5,"Ej_E_tipo.jpg")
      print(6,"Ej_E_region.jpg")
endfunction

function res = pow_an_(col,cod,ofe,year) 
##  Esta funcion se usa en C,D...
##  Esta funcion devuelve la oferta del año year del tipo/region especificado. 
##  para el tipo/region que se especifique segun los códigos:
##  el argumento cod se debe pasar como una lista [cod1 cod2 ...]
## tipo => col=4 --- region => col=5

##    1    BIODIESEL
##    2    BIOGAS
##    3    BIOMASA
##    4    EOLICO
##    5    HIDRO <=50MW
##    6    SOLAR

##  101   BUENOS AIRES
##  102   CENTRO
##  103   COMAHUE
##  104   CUYO
##  105   LITORAL
##  106   NORESTE
##  107   NOROESTE
##  108   PATAGONIA

n     = rows(ofe);
pow   = ofe(:,6);
col   = ofe(:,col);
res   = 0*(1:columns(cod)) ;
j=1;

for codigo = cod
  for i = 1:n;
    date = ofe(i,1);
    if ( date == year && col(i) == cod(j) )
      res(j) += pow(i);
    endif
  endfor
  j+=1;
endfor
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

function f = main()
##  printf("----------Ejercicio A----------\n");
##  ejercicio_A();
##  printf("-------------------------------\n");
##  printf("----------Ejercicio B----------\n");
##  ejercicio_B();
##  printf("-------------------------------\n");
##  printf("----------Ejercicio C----------\n");
##  ejercicio_C();
##  printf("-------------------------------\n");
##  printf("----------Ejercicio D----------\n");
##  ejercicio_D();
##  printf("-------------------------------\n");
##  printf("----------Ejercicio E----------\n");
##  ejercicio_E();
##  printf("-------------------------------\n");
  printf("----------Ejercicio F----------\n");
  ejercicio_F();
  printf("-------------------------------\n");
##  printf("----------Ejercicio G----------\n");
##  ejercicio_G();
##  printf("-------------------------------\n");
endfunction

main()