import math
import matplotlib.pyplot as plt
import numpy as np
from numpy.linalg import norm as norm
import pandas as pd
#import pandas as pd

### Funciones AUXILIARES
def Linf(x):
    return norm(x,np.inf)

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

def eliminacion_xGaussiana(A,b):
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
    vector_x = [[1]*len(A[0])]
    for i in range(-1,-(len(A_sorted)+1),-1):
        tot = 0
        divisor = 1
        for j in range(len(A_sorted[i])):
            if j == len(A_sorted)+i: 
                divisor = A_sorted[i][j]
            else:
                tot += A_sorted[i][j]*vector_x[0][j]
        vector_x[0][i] = (b_sorted[i][0]-tot)/divisor
    return A_sorted, b_sorted, vector_x

def subA(A,tipo):
    # Esta funcion devuelve las matrices Lower, Diagonal y Upper (tipo= 1,2,3 respectivamente).
    dim = np.shape(A)
    n=dim[0]
    m=dim[1]
    res = np.zeros(dim)
    for i in  range(n):
        for j in range(m):
            if tipo==1:
                if i>j: res[i][j] = A[i][j]
            if tipo==2:
                if i==j: res[i][j] = A[i][j]
            if tipo==3:
                if i<j: res[i][j] = A[i][j]
    return np.array(res)

def jacobi     (A,b,x0=None,n_iter=1000,tol=0.0001,verbose=False,density=5,error='Relative',Xref=None):
    # Esta funcion devuelve:
    # x   = matriz cuya i-sima columna es la i-esima iteracion de X por jacobi
    # err = vector cuyo i-esimo valor es el error relativo entre las iteraciones x[n] y x[n+1] 
    # n   = numero de iteraciones hasta detenerse el algoritmo
    
    print("JACOBI :")
    A = np.array(A)
    nA,mA = np.shape(A)
    b = np.array(b)
    
    L=subA(A,1)
    D=subA(A,2)
    U=subA(A,3)
    if x0 == None:  x0=np.zeros(nA)
    x=[]
    x.append(x0.reshape((nA,1)))
    print("x0= {}".format(np.transpose(x[0])))
    err=[10*tol]
    for n in range(n_iter):
        iteraciones=n 
        v  = b - np.matmul( L+U,x[n] )
        xn = np.matmul( np.linalg.inv(D) , v)
        x.append(np.array(xn))
        if error == 'Relative':
            err_n=Linf( x[n+1] - x[n] ) / Linf(x[n])
        else:
            err_n=Linf(x[n]-Xref)
        err.append(err_n)
        if verbose==True and np.remainder(n,density)==0 :
            print("n      =",n)
            print("x["+str(n+1)+"]   =",x[n+1].reshape((1,nA)))
            print("err["+str(n)+"] =",err[n])
            print(".....")
        if n>0 and err[n] < tol:break
    return x, err, iteraciones-1

def xGaussSeidel(A,b,x0=None,n_iter=1000,tol=0.0001,verbose=False,density=5,error='Relative',Xref=None):
    # Esta funcion devuelve:
    # x   = matriz cuya i-sima columna es la i-esima iteracion de X por jacobi
    # err = vector cuyo i-esimo valor es el error relativo entre las iteraciones x[n] y x[n+1] 
    # n   = numero de iteraciones hasta detenerse el algoritmo
    print("xGauss SEIDEL :")
    A = np.array(A)
    nA,mA = np.shape(A)
    b = np.array(b)
    L=subA(A,1)
    D=subA(A,2)
    U=subA(A,3)
    if x0 == None:  x0=np.zeros(nA).reshape((nA,1))
    x=[]
    x.append(np.array(x0))
    print("x0= {}".format(np.transpose(x[0])))
    err=[10*tol]
    for n in range(n_iter):
        iteraciones=n
        xnmas1=np.zeros(mA)
        for i in range(mA):
            xnmas1[i] =  np.linalg.inv(D)[i,i] * ( b[i] - np.matmul( L  , xnmas1)[i] - np.matmul( U , x[n])[i] )
        x.append(np.array(xnmas1).reshape((nA,1)))
        
        if error == 'Relative':
            err_n=Linf( x[n+1] - x[n] ) / Linf(x[n])
        else:
            err_n=Linf(x[n]-Xref)
        err.append(err_n)

        if verbose==True and np.remainder(n,density)==0:
            print("n      =",n)
            print("x["+str(n+1)+"]   =",xnmas1.reshape((1,nA)))
            print("err["+str(n)+"] =",err[n])
            print(".....")
        if n>0 and err[n] < tol:break
    return x, err, iteraciones-1

def SOR        (A,b,w,x0=None,n_iter=1000,tol=0.0001,verbose=False,density=5,error='Relative',Xref=None):
    # Esta funcion devuelve:
    # x   = matriz cuya i-sima columna es la i-esima iteracion de X por jacobi
    # err = vector cuyo i-esimo valor es el error relativo entre las iteraciones x[n] y x[n+1] 
    # n   = numero de iteraciones hasta detenerse el algoritmo
    
    A = np.array(A)
    b = np.array(b)
    nA,mA = np.shape(A)
    L=subA(A,1)
    D=subA(A,2)
    U=subA(A,3)
    if x0 == None:  x0=np.zeros(nA).reshape((nA,1))
    x=[]
    x.append(np.array(x0))
    err=[10*tol]
    for n in range(n_iter):
        iteraciones=n
        xnmas1=np.zeros(mA)
        for i in range(mA):
            xnmas1[i] =  (1-w) *  x[n][i]  +  w  *  np.linalg.inv(D)[i,i] * ( b[i] - np.matmul( L  , xnmas1)[i] - np.matmul( U , x[n])[i] )
        x.append(np.array(xnmas1).reshape((nA,1)))
        
        if error == 'Relative':
            err_n=Linf( x[n+1] - x[n] ) / Linf(x[n])
        else:
            err_n=Linf(x[n]-Xref)
        err.append(err_n)

        if verbose==True and np.remainder(n,density)==0:
            print("n      =",n)
            print("x["+str(n+1)+"]   =",xnmas1.reshape((1,nA)))
            print("err["+str(n)+"] =",err[n])
            print(".....")
        if n>0 and err[n] < tol:break
    return x, err, iteraciones-1

### Funciones EJERCICIOS

def ejercicioA(A,b):
    A_triangulada, b, vector_x = eliminacion_xGaussiana(A, b)
    #Imprimo                    
    for elem in A_triangulada:
        print(elem)
    print("B:")
    for elem in b:
        print(elem[0])
    print("SOL:")
    for elem in vector_x[0]:
        print(elem)
    return vector_x

def ejercicioB(A,b):
    print("Ejercicio B"+"\n ----------------------------")
    xJac , errJac , nJac = jacobi(A,b,verbose=True)
    print("\nLa solucion por el metodo de Jacobi es :")
    print(xJac[nJac])
    print("\nla misma se alacanzo en {} iteraciones, con un error relativo de {}".format(str(nJac),str(round(errJac[nJac],10))))
    print("\n --------------------------- \n")
    xGS , errGS  , nGS   = xGaussSeidel(A,b,verbose=True)
    print("\nLa solucion por el metodo de xGauss-Seidel es :")
    print(xGS[nGS])
    print("\nla misma se alacanzo en {} iteraciones, con un error relativo de {}".format(str(nGS),str(round(errGS[nGS],10))))
    print("\n --------------------------- \n")

    return xJac[nJac] , xGS[nGS]

def ejercicioC(A,b):
    print("Ejercicio C\n ----------------")
    print("Se adoptan los valores de w =")
    w_list=np.linspace(0.25,1,10)
    print(w_list)
    err=[]
    n_sor=[]
    print("\nSe corre el algoritmo SOR para cada uno, obteniendose :")
    for i in range(len(w_list)):
        _ , err_i , n_i = SOR(A,b,w=w_list[i])
        err.append(err_i)
        n_sor.append(n_i)

    df=pd.DataFrame(np.c_[np.transpose(w_list),n_sor],columns=['w','n'])
    print(df)
    n_min=df.n.min()
    w_min=df[df.n==n_min].w
    print("\nPor lo que se adopta el w tal que n sea minimo \n")
    print(df[df.n==n_min])
    print("\n ---------------")

    xSOR = SOR(A,b,w_min)[0][-1]

    return w_min , n_min , xSOR

def modulo(vec): # vec = [nx1]
    tot = 0
    for i in range(len(vec[0])):
        tot += vec[0][i]*vec[0][i]
    return math.sqrt(tot)

def ejercicioD(A,b,xGauss,xJac,xGS,xSOR):
    print("\nEJERCICIO D\n")
    errJac  = Linf(xJac   - xGauss)/Linf(xGauss)
    errGS   = Linf(xGS    - xGauss)/Linf(xGauss)
    errSOR  = Linf(xSOR   - xGauss)/Linf(xGauss)
    err_ = [errJac, errGS, errSOR]
    df=pd.DataFrame(np.array(err_).reshape((1,3)),columns=['Jac','GS','SOR'])
    print("Los errores relativos de cada metodo respecto de el metodo directo \nde Gauss en norma Linf son de : \n")
    print(df)
    print("\n ---------------------")
    return df

def ejercicioE(A, b, RQ_POS):
    aux = A[RQ_POS[0]][RQ_POS[1]]
    xGauss_rq = []
    RQ = [0.2, 0.3, 0.4, 0.5, 0.6]
    for rq in RQ:
        A[RQ_POS[0]][RQ_POS[1]] = rq
        x=eliminacion_xGaussiana(A,b)[2][0]
        xGauss_rq.append(x)
        print(x)
        print("\n")
        
        np.savetxt('Ej E xGauss.csv',  
           xGauss_rq, 
           delimiter =", ",  
           fmt ='% f')
    
    A[RQ_POS[0]][RQ_POS[1]] = aux

    # x = np.arange(df.shape()[0])
    # plt.bar(x,df.X)
    # plt.xticks(x, ('RQ=0.2', 'RQ=0.3', 'RQ=0.4', 'RQ=0.5', 'RQ=0.6'))
    # plt.show()
    return

def ejercicioF(A,b,xGauss,w_min):
    print("Ejercicio F")
    
    tol=0.000001
    Xref=xGauss[0]
    xJac , errJac , nJac   = jacobi(A,b,tol=tol,error=1,Xref=Xref)
    xGS  , errGS  , nGS    = xGaussSeidel(A,b,tol=tol,error=1,Xref=Xref)
    xSOR , errSOR , nSOR   = SOR(A,b,w_min,tol=tol,error=1,Xref=Xref)

    print(np.array(xJac)[-100:-1])
    # X=[xJac[-1],xGS[-1],xSOR[-1]]
    # print(X)
    # for i in X:
    #     print(i)

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
    
    ej = [ "A","B","C","D","E","F" ]
    if "A" in ej:
        xGauss = np.array(ejercicioA(A,b))

    A,b = armar_sistema(MICROORGANISMO_CRECIMIENTO)
    
    if "B" in ej:
        xJac  , xGS   = ejercicioB(A,b)
    if "C" in ej:
        w_min , n_min , xSOR = ejercicioC(A,b)
    if "D" in ej:
        ejercicioD(A,b,xGauss,xJac,xGS,xSOR)
    if "E" in ej:
        ejercicioE(A, b, RQ_POS)
    if "F" in ej:
        A,b = armar_sistema(MICROORGANISMO_CRECIMIENTO)
    
        ejercicioF(A,b,xGauss,w_min)

main()
