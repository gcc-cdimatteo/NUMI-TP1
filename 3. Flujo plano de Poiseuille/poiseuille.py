HKEY_SEPARACION_PLACAS = 0.1
HKEY_VISCOSIDAD = 0.95
HKEY_GRADIENTE_PRESION = -105
HKEY_PASOS_DISCRETIZACION = [0.025, 0.010, 0.005]

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

def diferencias_finitas(gradiente=HKEY_GRADIENTE_PRESION, viscosidad=HKEY_VISCOSIDAD):
    res = {}
    for paso_disc in HKEY_PASOS_DISCRETIZACION:
        res[paso_disc] = []
        ##Armo Matriz de Velocidades
        n = int(HKEY_SEPARACION_PLACAS/paso_disc)-1
        A = []
        y = [[0.25]]
        b = []
        for i in range(n):
            A.append([])
            y.append([y[-1][0]+0.25])
            b.append([HKEY_GRADIENTE_PRESION/HKEY_VISCOSIDAD])
            for j in range(n):
                if j == i: A[i].append(-2*paso_disc*paso_disc)
                elif j == i-1: A[i].append(1*paso_disc*paso_disc)
                elif j == i+1: A[i].append(1*paso_disc*paso_disc)
                else: A[i].append(0)
        ##Resuelvo por Gauss
        _A, _b, v = eliminacion_Gaussiana(A,b)
        ##Imprimo
        print(f"Discretizacion: {paso_disc}")
        cont = 1
        for r in range(len(v)):
            print(f"{cont}. V(y= {y[r][0]}d) = {v[r][0]}")
            res[paso_disc].append((y[r][0], v[r][0]))
            cont += 1
    return res

def tiro():
    return

def sensibilidad():
    aumento = 1.25
    valor_inicial = 0.75
    iteraciones = 1
    incremento = aumento/(valor_inicial*iteraciones)
    #Vario gradiente y dejo constante viscosidad
    grad = HKEY_GRADIENTE_PRESION*valor_inicial
    _grad = 0
    for i in range(iteraciones):
        _grad += grad*incremento
        print(f"GRADIENTE DE PRESION = {_grad} Y VISCOSIDAD = {HKEY_VISCOSIDAD}")
        diferencias_finitas(gradiente=_grad)
    #Vario viscosidad y dejo constante gradiente
    visc = HKEY_VISCOSIDAD*valor_inicial
    _visc = 0
    for i in range(iteraciones):
        _visc += visc*incremento
        print(f"GRADIENTE DE PRESION = {HKEY_GRADIENTE_PRESION} Y VISCOSIDAD = {_visc}")
        diferencias_finitas(viscosidad=_visc)
    return

def solucion_exacta(paso_disc, y):
    return (HKEY_GRADIENTE_PRESION/(paso_disc*2*HKEY_VISCOSIDAD))*y*(HKEY_SEPARACION_PLACAS-y)

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
    ## A
    #diferencias_finitas()
    ## B
    #tiro()
    ## C
    #sensibilidad()
    ## D
    analisis_experimental()
    return

main()