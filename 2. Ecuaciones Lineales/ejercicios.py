import math
import matplotlib.pyplot as plt
import numpy as np

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

def eliminacion_gaussiana(A,b):
    vector_x = [[0]*len(A[0])]
    # Ordeno
    dim = len(A)
    filA = {}
    for cont in range(dim):
        filA[cont] = abs_list(A[cont])
    filA_sorted = {k: v for k, v in sorted(filA.items(), key=lambda item: item[1], reverse=True)}
    A_sorted = []
    for fil in filA_sorted.keys():
        A_sorted.append(A[fil])
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
                b[i][0] = b[i][0]*pivot/divisor - A_sorted[i-1][j]
    #Obtengo vector_x
    for i in range(len(A_sorted)):
        for j in range(len(A_sorted[i])):
            vector_x[0][j] += A_sorted[i][j]
    return A_sorted, b, vector_x

def ejercicioA(A,b):
    A_triangulada, b, vector_x = eliminacion_gaussiana(A, b)
    #Imprimo                    
    for elem in A_triangulada:
        print(elem)
    for elem in vector_x[0]:
        print(elem)
    return

def ejercicioB():
    print("Ejercicio B")

def ejercicioC():
    print("Ejercicio C")

def modulo(vec): # vec = [nx1]
    tot = 0
    for i in range(len(vec[0])):
        tot += vec[0][i]*vec[0][i]
    return math.sqrt(tot)

def ejercicioD():
    # gauss = eliminacion_gaussiana()
    # jacobi = jacobi() - gauss
    # gauss_seidel = gauss_seidel() - gauss
    # sor = sor() - gauss
    # modulo_res = map(modulo, [jacobi, gauss_seidel, sor])
    # print(max(modulo))
    return

def ejercicioE(A, b, RQ_POS):
    aux = A[RQ_POS[0]][RQ_POS[1]]
    res = []
    for v in [0.2, 0.3, 0.4, 0.5, 0.6]:
        A[RQ_POS[0]][RQ_POS[1]] = v
        res.append(eliminacion_gaussiana(A,b)[2])
    print(res)
    modulo_res = list(map(modulo, res))
    print(modulo_res)
    A[RQ_POS[0]][RQ_POS[1]] = aux
    x = np.arange(len(modulo_res))
    fig, ax = plt.subplots()
    plt.bar(x, modulo_res)
    plt.xticks(x, ('RQ=0.2', 'RQ=0.3', 'RQ=0.4', 'RQ=0.5', 'RQ=0.6'))
    plt.show()
    return

def ejercicioF():
    print("Ejercicio F")

def armar_sistema(A_sorted):
    A = []
    b = []
    for i in range(len(A_sorted)):
        cont = 0
        fila = []
        while cont < len(A_sorted[i])-1:
            fila.append(A_sorted[i][cont])
            cont += 1
        A.append(fila)
        b.append([A_sorted[i][cont]])
    return A,b

def main():
    RQ_POS = (0,0)
    MICROORGANISMO_CRECIMIENTO = [
                                    [0.2, 0.0, 1.0, 1.0, 0.0, 2.0] , 
                                    [1.0, 3.0, -1.0, -1.0, -1.0, -6.0] , 
                                    [-1.0, -1.0, 20.0, 0.0, 2.0, 1.0] , 
                                    [-1.0, -1.0, 0.0, 8.0, 4.0, 0.0] ,
                                    [0.0, 0.0, 2.0, 0.0, 7.0, 5.0]
                                ]
    A,b = armar_sistema(MICROORGANISMO_CRECIMIENTO)
    ej = [ "E" ]
    if "A" in ej:
        ejercicioA(A, b)
    if "B" in ej:
        ejercicioB()
    if "C" in ej:
        ejercicioC()
    if "D" in ej:
        ejercicioD()
    if "E" in ej:
        ejercicioE(A, b, RQ_POS)
    if "F" in ej:
        ejercicioF()

main()