RQ = int(0.2)
MICROORGANISMO_CRECIMIENTO = [
                                [RQ, 0.0, 1.0, 1.0, 0.0, 2.0] , 
                                [1.0, 3.0, -1.0, -1.0, -1.0, -6.0] , 
                                [-1.0, -1.0, 20.0, 0.0, 2.0, 1.0] , 
                                [-1.0, -1.0, 0.0, 8.0, 4.0, 0.0] ,
                                [0.0, 0.0, 2.0, 0.0, 7.0, 5.0]
                            ]

def abs_list(lista):
    absLista = []
    for elem in lista:
        absLista.append(abs(elem))
    return absLista

def swap(A_sorted, pos1, pos2):
    aux = A_sorted[pos1]
    A_sorted[pos1] = A_sorted[pos2]
    A_sorted[pos2] = aux

def matriz_triangulada(matriz):
    for i in range(len(matriz)):
        for j in range(len(matriz[i])):
            if i > j and matriz[i][j] != 0: return False
    return True

def fila_triangulada(matriz, pos_fila):
    for i in range(len(matriz)):
        if i != pos_fila: continue
        for j in range(len(matriz[i])):
            if i > j and matriz[i][j] != 0: return False
    return True

def ejercicioA(A,b):
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
    #Imprimo                    
    for elem in A_sorted:
        print(elem)
    return

def ejercicioB():
    print("Ejercicio B")

def ejercicioC():
    print("Ejercicio C")

def ejercicioD():
    print("Ejercicio D")

def ejercicioE():
    print("Ejercicio E")

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
    A,b = armar_sistema(MICROORGANISMO_CRECIMIENTO)
    ej = [ "A" ]
    if "A" in ej:
        ejercicioA(A,b)
    if "B" in ej:
        ejercicioB()
    if "C" in ej:
        ejercicioC()
    if "D" in ej:
        ejercicioD()
    if "E" in ej:
        ejercicioE()
    if "F" in ej:
        ejercicioF()

main()