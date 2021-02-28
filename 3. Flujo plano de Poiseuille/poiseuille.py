HKEY_SEPARACION_PLACAS = 0.1
HKEY_VISCOSIDAD = 0.95
HKEY_GRADIENTE_PRESION = -105

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

def diferencias_finitas():
    h = [0.025, 0.010, 0.005]
    d = 0.1
    for paso_disc in h:
        n = int(d/paso_disc)-1
        A = []
        y = [[0.25]]
        b = []
        for i in range(n):
            A.append([])
            y.append([y[-1][0]+0.25])
            b.append([-105/0.95])
            for j in range(n):
                if j == i: A[i].append(-2*paso_disc*paso_disc)
                elif j == i-1: A[i].append(1*paso_disc*paso_disc)
                elif j == i+1: A[i].append(1*paso_disc*paso_disc)
                else: A[i].append(0)
        _A, _b, x = eliminacion_Gaussiana(A,b)
        print(f"Discretizacion: {paso_disc}")
        cont = 1
        for r in range(len(x)):
            print(f"{cont}. V(y= {y[r][0]}d) = {x[r][0]}")
            cont += 1

    return

def main():
    ## A
    diferencias_finitas()
    ## B

    ## C

    ## D

main()