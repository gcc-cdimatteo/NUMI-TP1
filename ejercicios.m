a = "";

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
    date = [num2str(dem(j,1)) " / " num2str(dem(j,2))];
    if pow_men(j,3)/dem(j,3) <= 0.08
      disp(horzcat([pow_men_100 "\t|\t"],date,["\t|\t" "NO"]))
    else 
      disp(horzcat([pow_men_100 "\t|\t"],date,["\t|\t\t" "SI"]))
      total_SI+=1;
    endif
  endfor
  disp("---------------------------------------------------")
  disp("")
  disp(["Se cumplió con la ley en " num2str(total_SI) " de " num2str(n_mes) " meses."]),disp("")
endfunction

function ejercicio_C();
#  En este ejercicio habia un par de endif´s que no le pusieron condicion,
#  y por eso tiraba error en el command window y pedia parentesis. 
#  Solo habia que cambiarlos por else.
  
  ofe = load('EnergiasRenovablesSimple.dat');
  dem = load('DemandaSimple.dat');
  
  en_Eol  = pow_an_tipo(4,ofe)(:,2);
  en_Hid  = pow_an_tipo(5,ofe)(:,2);
  en_Tot  = demanda_anual(dem)(:,2);
  years   = demanda_anual(dem)(:,1);
  n_mes   = rows(en_Tot);
  
  Data = round(horzcat(years,en_Eol,en_Eol./en_Tot*100,en_Hid,en_Hid./en_Tot*100,(en_Eol.+en_Hid),(en_Eol.+en_Hid)./en_Tot*100,en_Tot)*100)/100;
  titulos=["Año\t" "Eolica\t" "Eolica (%)\t" "Hidra\t" "Hidra (%)\t" "Eoli+Hidra\t" "Eoli+Hidra (%)\t" "En Total"];
  disp(titulos)
  num2str(Data)
  
  subplot (2, 1, 1)
    plot(years,Data(:,2),"r*-",years,Data(:,4),"b*-",years,Data(:,6),"g*-");
    title("Consumo anual de energía eólica e hidraulica")
    axis([2011 2020])
    grid on
    xlabel("Año")
    ylabel("Consumo anual [GWh]")
    legend("Eolica","Hidraulica","Eolica + Hidraulica",'location','north')
  subplot (2, 1, 2)
    plot(years,Data(:,3),"r*-",years,Data(:,5),"b*-",years,Data(:,7),"g*-");
    axis([2011 2020])
    grid on
    xlabel("Año")
    ylabel("Consumo respecto al total  [%] ")
    legend("Eolica","Hidraulica","Eolica + Hidraulica",'location','north')

#  Totales = plot(years,Data(:,2),"r*-",years,Data(:,4),"b*-",years,Data(:,6),"g*-")
#  Porcentajes = plot(years,Data(:,3),"r*-",years,Data(:,5),"b*-",years,Data(:,7),"g*-")
  
  
  
endfunction

function res = pow_an_tipo(cod,ofe) 
#  Esta funcion devuelve una matriz de nx2 = [año_j oferta_anual] 
#  para el tipo que se especifique segun el código:
#    1    BIODIESEL
#    2    BIOGAS
#    3    BIOMASA
#    4    EOLICO
#    5    HIDRO <=50MW
#    6    SOLAR  
n = rows(ofe);
year  = ofe(1:n,1);
pow   = ofe(1:n,6);
tipo  = ofe(1:n,4);
res = [year(1) 0];
j=1;
for i = 1:n;
  date = [year(i)];
  if ( date(1)!= res(j,1))
    j+=1;
    res(j,1)= date;
  endif
  if ( tipo(i)==cod )
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

function ejercicio_D();
  
  datos1 = load('EnergiasRenovablesSimple.dat');
  datos2 = load('DemandaSimple.dat');

  i = 1;
  j = 1;
  #101 Buenos Aires
  #104 Cuyo
  #108 Patagonia
  while i <= rows(datos1)
     if datos1(i,5) ==101
       BuenosAires(j,1) = datos1(i,6);
      i = i + 1;
     elseif
      i =  (i + 1);
      BuenosAires(j,1) = 0;
     endif
     while i<=rows(datos1) && datos1(i,1) == datos1(i-1,1) 
        if datos1(i,5) == 101
           BuenosAires(j,1) = BuenosAires(j,1) + datos1(i,6);
           i = i + 1;
        elseif
           i = i + 1;
        endif
     endwhile
    j = j + 1;
  endwhile

  disp('Energia producida por Buenos Aires anualmente')
  disp(BuenosAires)

  i=1;
  j=1;

  while i <= rows(datos1)
     if datos1(i,5) ==104
       Cuyo(j,1) = datos1(i,6);
      i = i + 1;
     elseif
      i =  (i + 1);
      Cuyo(j,1) = 0;
     endif
     while i<=rows(datos1) && datos1(i,1) == datos1(i-1,1) 
        if datos1(i,5) == 104
           Cuyo(j,1) = Cuyo(j,1) + datos1(i,6);
           i = i + 1;
        elseif
           i = i + 1;
        endif
     endwhile
    j = j + 1;
  endwhile

  disp('Energia producida por Cuyo anualmente')
  disp(Cuyo)

  i=1;
  j=1;

  while i <= rows(datos1)
     if datos1(i,5) ==108
       Patagonia(j,1) = datos1(i,6);
      i = i + 1;
     elseif
      i =  (i + 1);
      Patagonia(j,1) = 0;
     endif
     while i<=rows(datos1) && datos1(i,1) == datos1(i-1,1) 
        if datos1(i,5) == 108
           Patagonia(j,1) = Patagonia(j,1) + datos1(i,6);
           i = i + 1;
        elseif
           i = i + 1;
        endif
     endwhile
    j = j + 1;
  endwhile

  disp('Energia producida por la Patagonia anualmente')
  disp(Patagonia)

  #porcentaje de energia que produce BA con respecto a las 3 zonas
  disp(" ")
  SumaEnergia=(BuenosAires + Cuyo + Patagonia);
  disp('Suma de la energia de las 3 zonas')
  disp(SumaEnergia)
  disp(" ")

  for i = 1:rows(BuenosAires)
    porcentaje1(i,1) = (BuenosAires(i,1)/SumaEnergia(i,1))*100;
  endfor
  disp('porcentaje de energia que produce Buenos Aires con respecto a las 3 zonas')
  disp(porcentaje1)

  #porcentaje de energia que produce Cuyo con respecto a las 3 zonas
  disp(" ")

  for i = 1:rows(Cuyo)
    porcentaje2(i,1) = (Cuyo(i,1)/SumaEnergia(i,1))*100;
  endfor
  disp('porcentaje de energia que produce Cuyo con respecto a las 3 zonas')
  disp(porcentaje2)

  #porcentaje de energia que produce la Patagonia con respecto a las 3 zonas
  disp(" ")

  for i = 1:rows(Patagonia)
    porcentaje3(i,1) = (Patagonia(i,1)/SumaEnergia(i,1))*100;
  endfor
  disp('porcentaje de energia que produce la Patagonia con respecto a las 3 zonas')
  disp(porcentaje3)
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

function ejercicio_E()
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
  printf("----------Ejercicio A----------\n");
  ejercicio_A();
  printf("-------------------------------\n");
  printf("----------Ejercicio B----------\n");
  ejercicio_B();
  printf("-------------------------------\n");
  printf("----------Ejercicio C----------\n");
  ejercicio_C();
  printf("-------------------------------\n");
  printf("----------Ejercicio D----------\n");
  ejercicio_D();
  printf("-------------------------------\n");
  printf("----------Ejercicio E----------\n");
  ejercicio_E();
  printf("-------------------------------\n");
  printf("----------Ejercicio F----------\n");
  ejercicio_F();
  printf("-------------------------------\n");
  printf("----------Ejercicio G----------\n");
  ejercicio_G();
  printf("-------------------------------\n");
endfunction

main()