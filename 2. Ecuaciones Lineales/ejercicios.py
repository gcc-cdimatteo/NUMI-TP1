RQ = int(0.2)
MICROORGANISMO_CRECIMIENTO = [
                                [RQ, 0, 1, 1, 0, 2] , 
                                [1, 3, -1, -1, -1, -6] , 
                                [-1, -1, 20, 0, 2, 1] , 
                                [-1, -1, 0, 8, 4, 0] ,
                                [0, 0, 2, 0, 7, 5]
                            ]

def abs_list(lista):
    absLista = []
    for elem in lista:
        absLista.append(abs(elem))
    return absLista

def swap(matriz, pos1, pos2):
    aux = matriz[pos1]
    matriz[pos1] = matriz[pos2]
    matriz[pos2] = aux

def ejercicioA(A,b):
    dim = len(A)
    filA = {}
    for cont in range(dim):
        filA[cont] = abs_list(A[cont])
    filA_sorted = {k: v for k, v in sorted(filA.items(), key=lambda item: item[1], reverse=True)}
    A_sorted = [[]*dim]*dim
    cont = 0
    for fil in filA_sorted.keys():
        A_sorted[cont] = A[fil]
        cont += 1


    h = 0
    k = 0

    while h < dim and k < dim:
        i_max = 0
        for i in range(h,dim):
            if abs(A_sorted[i_max][k]) < abs(A_sorted[i][k]): i_max = i
        
        if A_sorted[i_max][k] == 0:
            k = k+1
        else:
            swap(A_sorted, h, i_max)
            for i in range(h + 1, dim):
                f = A_sorted[i][k]/A_sorted[h][k]
                A_sorted[i][k] = 0
                for j in range(k + 1, dim):
                    A_sorted[i][j] = A_sorted[i][j] - A_sorted[h][j] * f
            h += 1
            k += 1

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

def armar_sistema(matriz):
    A = []
    b = []
    for i in range(len(matriz)):
        cont = 0
        fila = []
        while cont < len(matriz[i])-1:
            fila.append(matriz[i][cont])
            cont += 1
        A.append(fila)
        b.append([matriz[i][cont]])
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