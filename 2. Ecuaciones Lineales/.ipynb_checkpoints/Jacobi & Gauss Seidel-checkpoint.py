#!/usr/bin/env python
# coding: utf-8

# Importo las librerias NumPy (calculos de arrays) y Matplotlib (visualizción)

# In[2]:


import numpy as np
import matplotlib.pyplot as plt
plt.show()


# In[3]:


from numpy.linalg import norm as norm
def Linf(x):
    # esta funcion es la norma L-infinito
    return norm(x,np.inf)


# In[4]:


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


# In[5]:


def jacobi(A,b,x0=None,n_iter=1000,tol=0.0001,verbose=False,density=5):
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
    if x0 == None:  x0=np.zeros(nA)
    x=[]
    x.append(np.array(x0))
    err=[10*tol]
    for n in range(n_iter):
        iteraciones=n
        xn = np.matmul( np.linalg.inv(D) , b - np.matmul( L+U  , x[n]) )
        x.append(np.array(xn))
        err.append( Linf( x[n+1] - x[n] ) / Linf(x[n])) 
        if verbose==True and np.remainder(n,density)==0:
            print("n      =",n)
            print("x["+str(n+1)+"]   =",xn)
            print("err["+str(n)+"] =",err[n])
            print(".....")
        if n>0 and err[n] < tol:break
    return x, err, iteraciones-1


# Los datos del problema son:

# In[6]:


RQ = float(0.2)
MICROORGANISMO_CRECIMIENTO = [
                                [RQ, 0.0, 1.0, 1.0, 0.0, 2.0] , 
                                [1.0, 3.0, -1.0, -1.0, -1.0, -6.0] , 
                                [-1.0, -1.0, 20.0, 0.0, 2.0, 1.0] , 
                                [-1.0, -1.0, 0.0, 8.0, 4.0, 0.0] ,
                                [0.0, 0.0, 2.0, 0.0, 7.0, 5.0]
                            ]


# In[7]:


A=np.array(MICROORGANISMO_CRECIMIENTO)[:,:-1]
print(A)


# In[8]:


b=np.array(MICROORGANISMO_CRECIMIENTO)[:,-1]
print(b)


# Llamo a la funcion de Jacobi, verbose=True hace que imprima las iteraciones

# In[9]:


x, errJac, nJac = jacobi(A,b,verbose=True)


# In[10]:


resJacobi=x[-1]


# In[11]:


def GaussSeidel(A,b,x0=None,n_iter=100,tol=0.0001,verbose=False,density=5):
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
    if x0 == None:  x0=np.zeros(nA)
    x=[]
    x.append(np.array(x0))
    err=[10*tol]
    for n in range(n_iter):
        iteraciones=n
        xnmas1=np.zeros(mA)
        for i in range(mA):
            xnmas1[i] =  np.linalg.inv(D)[i,i] * ( b[i] - np.matmul( L  , xnmas1)[i] - np.matmul( U , x[n])[i] )
        x.append(np.array(xnmas1))
        err.append( Linf( x[n+1] - x[n] ) / Linf(x[n])) 
        if verbose==True and np.remainder(n,density)==0:
            print("n      =",n)
            print("x["+str(n+1)+"]   =",xnmas1)
            print("err["+str(n)+"] =",err[n])
            print(".....")
        if n>0 and err[n] < tol:break
    return x, err, iteraciones-1


# In[12]:


x, errGS, nGS = GaussSeidel(A,b,verbose=True,density=2)


# In[13]:


resGaussSeidel = x[-1]


# In[24]:


tol=0.0001
plt.style.use('ggplot')
error_plot=plt.figure(figsize=(25,15))
ax = error_plot.add_subplot(111)
ax.plot(errJac[1:],label="Jac",marker='*',c='g')
ax.plot(errGS[1:],label="GS",marker='*',c='b')
# escala LOG y grid
plt.yscale('log')
ax.yaxis.grid(color='gray', linestyle='dashed',which='both')
#linea horizontal de la tolerancia
ax.axhline(tol,c='r',linestyle='--',label='tol')
plt.text(max(nGS,nJac)*3/4,tol,'tol',fontsize=30,c='r')
#lineas verticales de los n's de corte
ax.axvline(nGS,c='b',linestyle='--')
plt.text(nGS,100*tol,'nGS ='+str(nGS),fontsize=20,c='b')
ax.axvline(nJac,c='g',linestyle='--')
plt.text(nJac-10,100*tol,'nJac ='+str(nGS),fontsize=20,c='g')
# Legend
handles, _ = ax.get_legend_handles_labels()
labels=["Jacobi","Gaus-Seidel","tol ="+str(tol)]
ax.legend(handles,labels,fontsize=30,frameon=True,framealpha=0.9)
# Titulos de Grafico y ejes
plt.title('Error relativo de Norma Linf entre las iteraciones x[n] y x[n+1]',fontsize=30)
plt.ylabel(ylabel='error',fontsize=30)
plt.xlabel(xlabel='n',fontsize=30)
plt.tight_layout()

# ticks
for tick in ax.xaxis.get_major_ticks():
    tick.label.set_fontsize(20) 
for tick in ax.yaxis.get_major_ticks():
    tick.label.set_fontsize(20) 
    tick.label.set_rotation('vertical')
    
    
# guardo el grafico
plt.savefig('Jacobi vs GS')


# Comparo ambas soluciones

# In[15]:


print(Linf(resJacobi-resGaussSeidel)/Linf(resJacobi))

