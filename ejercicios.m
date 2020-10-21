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
  datos1 = load('EnergiasRenovablesSimple.dat');
  datos2 = load('DemandaSimple.dat');

  i = 1;
  j = 1;
  while i <= rows(datos1)
    suma(j,1) = datos1(i,6);
    i = i + 1 ;
    while i <= rows(datos1) && datos1(i,1) == datos1(i-1,1) && datos1(i,2) == datos1(i-1,2) 
      suma(j,1) = suma(j,1) + datos1(i,6);
      i = i + 1
    endwhile
    j = j + 1;
  endwhile
  disp(suma)

  disp(""),disp("¿Verifica la ley 26.910?"),disp("")
  
  disp(["Suma (%)" "\t|\t" "Mes/Año" "\t" "Verifica?"]),disp("----------------------------------")
  for k = 1:rows(suma)
    suma_k =num2str((suma(k,1)/datos2(k,3))*100);
    if suma(k,1)/datos2(k,3) <= 0.08
      disp([suma_k "\t|\t" num2str(datos2(k,2)) "/" num2str(datos2(k,1)) "\t\t" "NO"])
    else 
      disp([suma_k "\t|\t" num2str(datos2(k,2)) "/" num2str(datos2(k,1)) "\t\t\t" "SI"])
    endif
  endfor
endfunction

function ejercicio_C();
  datos1 = load('EnergiasRenovablesSimple.dat');
  datos2 = load('DemandaSimple.dat');


  i = 1;
  j = 1;
  while i <= rows(datos1)
    if datos1(i,4) == 4 || datos1(i,4) == 5
      suma(j,1) = datos1(i,6);
      i = i + 1 ;
    elseif
      i = (( i + 1 )); %Le puse parentesis xq me tiraba un error
      suma(j,1) = 0;
    endif
    while i <= rows(datos1) && datos1(i,1) == datos1(i-1,1) 
      if datos1(i,4) == 4 || datos1(i,4) == 5
        suma(j,1) = suma(j,1) + datos1(i,6);
        i = i + 1;
      elseif
        i = (( i + 1 ));
       endif
    endwhile
    j = j + 1;
  endwhile

  for k = 2:rows(suma)
    porcentaje(k,1) = suma(k,1)/suma(k-1,1);
  endfor

  disp("suma")
  disp(suma)
  disp("---------")
  disp("porcentaje")
  disp(porcentaje)
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

function ejercicio_E();
endfunction

function ejercicio_F();
endfunction

function ejercicio_G();
endfunction

function main()
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

main();
