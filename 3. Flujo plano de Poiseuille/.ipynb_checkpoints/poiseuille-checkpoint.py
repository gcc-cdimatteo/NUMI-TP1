import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import csv
import os 

HKEY_SEPARACION_PLACAS = 0.1
HKEY_VISCOSIDAD = 0.95
HKEY_GRADIENTE_PRESION = -105
HKEY_PASOS_DISCRETIZACION = [0.025, 0.010, 0.005]

GPsM= HKEY_GRADIENTE_PRESION/HKEY_VISCOSIDAD

def _print(mat):
    for fil in mat:
        print(fil)

def abs_list(lista):
    absLista = []
    for elem in lista:
        absLista.append(abs(elem))
    return absLista

def fila_triangulada(matriz, pos_fila):
    for i in range(len(matriz)):
        if i != pos_fila: continue
        for j in range(len(matriz[i])):
            if i > j and matriz[i][j] != 0: return False
    return True

def eliminacion_Gaussiana(A,b):
    # Ordeno
    dim = len(A)
    filA = {}
    for cont in range(dim):
        filA[cont] = abs_list(A[cont])
    filA_sorted = {k: v for k, v in sorted(filA.items(), key=lambda item: item[1], reverse=True)}
    A_sorted = []
    b_sorted = []
    for fil in filA_sorted.keys():
        A_sorted.append(A[fil])
        b_sorted.append(b[fil])
    #Triangulo
    for i in range(len(A_sorted)):
        if i == 0 or fila_triangulada(A_sorted, i): continue
        indice = 0
        for j in range(len(A_sorted[i])):
            if A_sorted[i][j] != 0: 
                indice = j
                break
        pivot = A_sorted[i-1][indice]
        for k in range(i, len(A_sorted)):
            if A_sorted[k][indice] == 0: continue
            divisor = A_sorted[k][indice]
            for j in range(len(A_sorted[k])):
                A_sorted[k][j] = A_sorted[k][j]*pivot/divisor - A_sorted[i-1][j]
            b_sorted[k][0] = b_sorted[k][0]*pivot/divisor - b_sorted[i-1][0]
    #Resulevo el sistema
    vector_x = [1]*len(A[0])
    for i in range(-1,-(len(A_sorted)+1),-1):
        tot = 0
        divisor = 1
        for j in range(len(A_sorted[i])):
            if j == len(A_sorted)+i: 
                divisor = A_sorted[i][j]
            else:
                tot += A_sorted[i][j]*vector_x[j]
        vector_x[i] = (b_sorted[i][0]-tot)/divisor
    x = []
    for _x in vector_x:
        x.append([_x])
    return A_sorted, b_sorted, x

def calculo_incremento(aumento_final, valor_inicial, cant_iteraciones):
    return aumento_final/(valor_inicial*cant_iteraciones)

def solucion_exacta(paso_disc, y):
    v_y= (HKEY_GRADIENTE_PRESION/(2*HKEY_VISCOSIDAD))*y*(HKEY_SEPARACION_PLACAS-y)
    dvdy_y= (HKEY_GRADIENTE_PRESION/(2*HKEY_VISCOSIDAD))*(HKEY_SEPARACION_PLACAS-2*y)
    return v_y , dvdy_y

def imprimir_diferencias_finitas(res):
    for paso_disc in res:
        print(f"Discretizacion: {paso_disc}")
        cont = 1
        for r in res[paso_disc]:
            print("{:2}. V(y= {:.2e}) = {:.4e}".format(cont,r[0],r[1]))
            cont += 1
        print()
    print()
    return

def diferencias_finitas(gradiente=HKEY_GRADIENTE_PRESION, viscosidad=HKEY_VISCOSIDAD, gpsm=GPsM,h=HKEY_PASOS_DISCRETIZACION):
    res = {}
    for paso_disc in HKEY_PASOS_DISCRETIZACION:
        res[paso_disc] = []
        ##Armo Matriz de Velocidades
        
        ## !!! Esta matriz asi definida da bien solo porque V_0 = V_n+1 = 0 !!!
        ## En realidad habria que tener en cuenta esos dos valores haciendo una 
        ## matriz mas grande o restandolos de b_1 y b_n .
         
        n = int(HKEY_SEPARACION_PLACAS/paso_disc)-1
        A = []
        y = [[paso_disc]]
        b = []
        for i in range(n):
            A.append([])
            y.append([y[-1][0]+paso_disc])
            b.append([(gpsm)*paso_disc*paso_disc])
            for j in range(n):
                if j == i: A[i].append(-2)
                elif j == i-1: A[i].append(1)
                elif j == i+1: A[i].append(1)
                else: A[i].append(0)
        ##Resuelvo por Gauss
        _A, _b, v = eliminacion_Gaussiana(A,b)
        ##Guardo
        for r in range(len(v)):
            res[paso_disc].append((y[r][0], v[r][0]))
    return res

    ## ☻

def tiro_euler():
    res = {}
    for paso_disc in HKEY_PASOS_DISCRETIZACION:
        #print(f"Discretizacion: {paso_disc}")
        tiros = (1, 5)
        res[paso_disc] = {}
        for t in tiros:
            #print(f"Tiro: {t}")
            res[paso_disc][t] = []
            y = [0]
            u = [0]
            s = [t]
            ##Armo las Matrices de Discretizacion
            n = int(HKEY_SEPARACION_PLACAS/paso_disc)-1
            for i in range(n+1):
                y.append(y[-1]+paso_disc)
                s.append(s[-1]+paso_disc*(GPsM))
                u.append(u[-1]+paso_disc*s[-2])
            res[paso_disc][t].append(y)
            res[paso_disc][t].append(u)
            res[paso_disc][t].append(s)
        ##Armo Matriz de Resolución
        A = []
        b = []
        for t in tiros:
            A.append([res[paso_disc][t][1][-1], 1])
            b.append([res[paso_disc][t][2][0]])
        ## _print(A)
        ## _print(b)
        _A, _b, x = eliminacion_Gaussiana(A, b)
        
        t_k = x[1][0]
        res[paso_disc]['t_k'] = t_k
        
        y = [0]
        u = [0]
        s = [t_k]

        for i in range(n+1):
            y.append(y[-1]+paso_disc)
            s.append(s[-1]+paso_disc*(GPsM))
            u.append(u[-1]+paso_disc*s[-2])
        
        res[paso_disc]['k']=[]
        res[paso_disc]['k'].append(y)
        res[paso_disc]['k'].append(u)
        res[paso_disc]['k'].append(s)
        
    return res
   
def tiro_runge_kuta_4():
    res = {}
    for paso_disc in HKEY_PASOS_DISCRETIZACION:
        #print(f"Discretizacion: {paso_disc}")
        tiros = (1, 5)
        res[paso_disc] = {}
        s_k1 = paso_disc*(GPsM)
        s_k2 = paso_disc*(GPsM + 0.5*s_k1)
        s_k3 = paso_disc*(GPsM + 0.5*s_k2)
        s_k4 = paso_disc*(GPsM + s_k3)
        for t in tiros:
            #print(f"Tiro: {t}")
            res[paso_disc][t] = []
            y = [0]
            u = [0]
            s = [t]
            ##Armo las Matrices de Discretizacion
            n = int(HKEY_SEPARACION_PLACAS/paso_disc)-1
            for i in range(n+1):
                y.append(y[-1]+paso_disc)
                s.append(s[-1]+(1/6)*(s_k1+2*s_k2+2*s_k3+s_k4))
                u_k1 = paso_disc*s[-2]
                u_k2 = paso_disc*(s[-2] + 0.5*u_k1)
                u_k3 = paso_disc*(s[-2] + 0.5*u_k2)
                u_k4 = paso_disc*(s[-2] + u_k3)
                u.append(u[-1]+(1/6)*(u_k1+2*u_k2+2*u_k3+u_k4))
            res[paso_disc][t].append(y)
            res[paso_disc][t].append(u)
            res[paso_disc][t].append(s)
        ##Armo Matriz de Resolución
        A = []
        b = []
        for t in tiros:
            A.append([res[paso_disc][t][1][-1], 1])
            b.append([res[paso_disc][t][2][0]])
        _A, _b, x = eliminacion_Gaussiana(A, b)
        #_print(x)
        
        t_k = (x[1][0])
        res[paso_disc]['t_k'] = t_k
        
        y = [0]
        u = [0]
        s = [t_k]

        for i in range(n+1):
            y.append(y[-1]+paso_disc)
            s.append(s[-1]+(1/6)*(s_k1+2*s_k2+2*s_k3+s_k4))
            u_k1 = paso_disc*s[-2]
            u_k2 = paso_disc*(s[-2] + 0.5*u_k1)
            u_k3 = paso_disc*(s[-2] + 0.5*u_k2)
            u_k4 = paso_disc*(s[-2] + u_k3)
            u.append(u[-1]+(1/6)*(u_k1+2*u_k2+2*u_k3+u_k4))
        
        res[paso_disc]['k']=[]
        res[paso_disc]['k'].append(y)
        res[paso_disc]['k'].append(u)
        res[paso_disc]['k'].append(s)
        
    return res

def tiro():
    euler = tiro_euler()
    runge_kuta_4 = tiro_runge_kuta_4()

    return euler, runge_kuta_4

def sensibilidad():
    dfV=pd.DataFrame()
    res = {}
    res['original'] = {}
    res['D_grad']   = {}
    res['D_mu']     = {}
    mse = {}
    v_origninal={}
    delta_porcentual=0.25
    valor_inicial = 1-delta_porcentual
    valor_final   = 1+delta_porcentual 
    iteraciones = 3
    incremento = calculo_incremento(valor_final, valor_inicial, iteraciones)

    #Guardo valores iniciales
    r = diferencias_finitas()
    for paso_disc in r:
        res['original'][paso_disc]  =   np.array(r[paso_disc][:][1])
        v_origninal[paso_disc]      =   np.array(r[paso_disc][:][1])

    #Vario gradiente y dejo constante viscosidad
    grad = HKEY_GRADIENTE_PRESION*valor_inicial
    _grad = 0
    for i in range(iteraciones):
        _grad += grad*incremento
        r = diferencias_finitas(gradiente=_grad)
        #Guardo
        for paso_disc in r:
            mse=0
            for _r in range(paso_disc):
                mse += np.abs()
            res['D_grad'][paso_disc]=[[_grad], [mse]]
            # v_desviado = np.array(r[paso_disc])
            # et  =v_desviado-v_origninal[paso_disc]
            # mse =np.abs(et).mean()
            # df=pd.DataFrame(data=r[paso_disc],columns=['y','v(y)'])
            # name='v(y) - D_grad='

    #Vario viscosidad y dejo constante gradiente
    visc  = HKEY_VISCOSIDAD*valor_inicial
    _visc = 0
    for i in range(iteraciones):
        _visc += visc*incremento
        r = diferencias_finitas(viscosidad=_visc)
        #Guardo
        for paso_disc in r:
            res['D_mu'][paso_disc]=[]
            for _r in r[paso_disc]:
                res['D_mu'][paso_disc].append([_visc,[_r[0], _r[1]]])
    #Exporto a CSV
    # with open(f'{os.path.dirname(os.path.realpath(__file__))}/ej_c.csv', 'w') as csvfile:
    #     w = csv.writer(csvfile, delimiter=',')
    #     w.writerow(["PASO DISCRETIZACION", "GRADIENTE DE PRESION", "VISCOSIDAD", "Y", "V"])
    #     for l in res:
    #         w.writerow(l)
    
    
    
    return

def analisis_experimental():
    res_exp = diferencias_finitas()
    res_ex = {}
    err_trunc = {}
    for paso_disc in res_exp:
        res_ex[paso_disc] = []
        err_trunc[paso_disc] = []
        for r in res_exp[paso_disc]:
            y = r[0]
            v_exp = r[1]
            v_ex = solucion_exacta(paso_disc, y)
            res_ex[paso_disc].append((y, v_ex))
            err_trunc[paso_disc].append((y, abs(v_ex-v_exp)))
        ##Imprimo
        print(f"Discretizacion: {paso_disc}")
        for r in range(len(err_trunc[paso_disc])):
            _y = err_trunc[paso_disc][r][0]
            _vtrunc = err_trunc[paso_disc][r][1]
            _vex = res_ex[paso_disc][r][1]
            _vexp = res_exp[paso_disc][r][1]
            #"y = {_y}: valor exacto = {_vex} | valor experimental = {_vexp} | error truncamiento = {_vtrunc}"
            print(f"y = {_y}: error truncamiento = {_vtrunc}")
        print()
    return

def main():
    ej = ('A','C')
    ## A
    if "A" in ej:
        print('\n'+"-"*5+"Diferencias Finitas"+"-"*5+'\n')
        res = diferencias_finitas()
        # imprimir_diferencias_finitas(res)
        for h in HKEY_PASOS_DISCRETIZACION:
            print('\nh='+str(h)+'\n')
            df=pd.DataFrame(res[h],columns=['y','v(y)'])
            print(df)
            name='Res Dif Fin - h='+str(h)+'.csv'
            df.to_csv(name)
    ## B
    if "B" in ej:
        print('\n'+"-"*5+"Metodo del tiro"+"-"*5+'\n')
        euler , rk4 = tiro()
        for h in HKEY_PASOS_DISCRETIZACION:
            print('\nh='+str(h)+'\n')
            
            t=euler[h]['t_k']
            print('\n'+'Euler:\tt='+str(t)+'\n')
            df=pd.DataFrame(np.array(euler[h]['k']).T,columns=['y','v(y)','v´(y)'])
            print(df)
            name='Res Tiro Euler - h='+str(h)+'.csv'
            df.to_csv(name)

            t=rk4[h]['t_k']
            print('\n'+'RK4:\tt='+str(t)+'\n')
            df=pd.DataFrame(np.array(rk4[h]['k']).T,columns=['y','v(y)','v´(y)'])
            print(df)
            name='Res Tiro RK4 - h='+str(h)+'.csv'
            df.to_csv(name)
    ## C
    if "C" in ej:
        print("-"*5+"Analisis de Sensibilidad"+"-"*5)
        sensibilidad()
        print()
    ## D
    if "D" in ej:
        print("-"*5+"Analisis Experimental"+"-"*5)
        analisis_experimental()

    return

main()