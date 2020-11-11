RQ = int(0.2)
MICROORGANISMO_CRECIMIENTO = [
                                [RQ, 0, 1, 1, 0, 2] , 
                                [1, 3, -1, -1, -1, -6] , 
                                [-1, -1, 20, 0, 2, 1] , 
                                [-1, -1, 0, 8, 4, 0] ,
                                [0, 0, 2, 0, 7, 5]
                            ]

def elementos_diagonal(matriz):
    elementos = []
    dimension = len(matriz)
    for i in range(dimension):
        for j in range(dimension-1):
            if i > j:
                elementos.append(matriz[i][j])
    return elementos
            
def matriz_triangulada(matriz):
    diagonal = elementos_diagonal(matriz)
    for elem in diagonal:
        if elem != 0: 
            return False
    return True

def ejercicioA(A,b):
    dim = len(A[0])
    for j in range(dim-2):
        for i in range(j+1, dim):
            m = A[i][j]/A[j][j]
            A[i] = A[i] - m*A[j]
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