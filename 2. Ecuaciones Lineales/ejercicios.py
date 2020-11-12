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

    # LO SAQUE DE INTERNET 

    n = len(a)
    p = len(b[0])

    for i in range(n - 1):
        k = i
        for j in range(i + 1, n):
            if abs(a[j][i]) > abs(a[k][i]):
                k = j
        if k != i:
            a[i], a[k] = a[k], a[i]
            b[i], b[k] = b[k], b[i]
            det = -det
 
        for j in range(i + 1, n):
            t = a[j][i]/a[i][i]
            for k in range(i + 1, n):
                a[j][k] -= t*a[i][k]
            for k in range(p):
                b[j][k] -= t*b[i][k]
 
    for i in range(n - 1, -1, -1):
        for j in range(i + 1, n):
            t = a[i][j]
            for k in range(p):
                b[i][k] -= t*b[j][k]
        t = 1/a[i][i]
        det *= a[i][i]
        for j in range(p):
            b[i][j] *= t

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
        b.append(matriz[i][cont])
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