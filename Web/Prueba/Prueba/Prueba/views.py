"""
Routes and views for the flask application.
"""

#from crypt import methods
from datetime import datetime
from email.policy import default
from glob import glob
import ipaddress
from flask import Flask, request, render_template, redirect
from Prueba import app
from .database import conn
import socket


ipAddress = 0
Username = ""
postIdUser = 0

@app.route('/')
@app.route('/user', methods=['GET', 'POST'])
def user():
    global ipAddress
    global Username
    global postIdUser
    message = ""
    
    if request.method == 'POST':
        url = request.url
        ipAddress = request.remote_addr
        Username = request.form['Username']
        Password = request.form['Password']
        cursor = conn.cursor()
        cursor.execute('{CALL UserID(?, ?)}', (Username, 0)) # Llamada SP y paso de parametros
        postIdUser = cursor.fetchone()[0]
        cursor.execute('{CALL ValidarUsuario(?, ?, ?, ?, ?)}', (Username, Password, postIdUser, ipAddress, 0))
        loginStatus = cursor.fetchone()[0]
        conn.commit()
        cursor.close()
        if(loginStatus == 0):
            return redirect('/contact')
        else:
            message = "Error: Nombre de usuario o password incorrectos"

    return render_template(
        'user.html',
        title='Login',
        message=message
    )    

@app.route('/home')
def home():
    """Renders the home page."""
    cursor = conn.cursor()
    #cursor.execute('EXEC OrdenarArticulos') # Llamada SP para ordenar articulos
    #articulos = cursor.fetchall()
    cursor.close()
    return render_template(
        'index.html',
        title='Home Page',
        articulos=articulos
    )

#@app.route('/')
@app.route('/contact', methods=['GET', 'POST'])
def contact():
    """Renders the contact page."""
    articulos = []
    filtroNombre = request.args.get('Nombretxt', default='', type=str)
    filtroCantidad = request.args.get('Cantidadtxt', default='', type=int)
    filtroClase = request.args.get('ClaseList', default='', type=str)
    message = ""
    cursor = conn.cursor()
    cursor.execute('{CALL OrdenarClaseArticulo(?)}', (0)) # Llamada SP y paso de parametros
    claseArticulos = cursor.fetchall()

    if request.method == 'GET' and 'filtrarNombre' in request.args:
        cursor.execute('{CALL BuscarArticuloPorNombre(?, ?, ?, ?)}', (str(filtroNombre), postIdUser, ipAddress, 0))
        articulos = cursor.fetchall()
        cursor.nextset()
        resultCode = cursor.fetchone()[0] ######## AQUI TIRA ERROR CUANDO SE INGRESA UN NUMERO EN FILTRAR POR NOMBRE #########
        if resultCode == 50001:
            message = "No se encontro el articulo"
        elif resultCode == 50002:
            message = "Nombre mal formado"
        elif resultCode == 0:
            message = ""

    elif request.method == 'GET' and 'filtrarCantidad' in request.args:
        cursor.execute('{CALL MostrarArticulosPorCantidad(?, ?, ?, ?)}', (filtroCantidad, postIdUser, ipAddress, 0))
        articulos = cursor.fetchall()
        cursor.nextset()
        resultCode = cursor.fetchone()[0]
        if resultCode == 50006:
            message = "Cantidad mal formada"
        elif resultCode == 0:
            message = ""

    elif request.method == 'GET' and 'filtrarClase' in request.args:
        cursor.execute('{CALL FiltrarClaseArticulo(?, ?, ?, ?)}', (filtroClase, postIdUser, ipAddress, 0))
        articulos = cursor.fetchall()
        message = ""

    return render_template(
        'contact.html',
        title='Articulos',
        claseArticulos=claseArticulos,
        articulos=articulos,
        message=message
    )

@app.route('/about')
def about():
    """Renders the about page."""
    return render_template(
        'about.html',
        title='About',
        year=datetime.now().year,
        message='Your application description page.'
    )

@app.route('/insert', methods=['GET', 'POST'])
def insert():
    if request.method == 'POST' and request.form['nombreArticulo'] != '' and request.form['precioArticulo'] != '':
        nombreArticulo = request.form['nombreArticulo']
        precioArticulo = request.form['precioArticulo']
        cursor = conn.cursor()
        cursor.execute('{CALL InsertarArticulo(?, ?, ?)}', (nombreArticulo, precioArticulo, 0)) # Llamada SP y paso de parametros
        result = cursor.fetchone()
        conn.commit()
        cursor.close()
        print(result[0])

        # Manejo de errores:
        if result[0] == 50001:
            message = "Articulo ya existe"
        elif result[0] == 50002:
            message = "Error: el nombre no esta formado correctamente"
        else:
            message = ""
        return render_template(
            'insert.html', 
            title="Insertar Articulo", 
            nombreArticulo=nombreArticulo, 
            precioArticulo=precioArticulo,
            message=message
            )
    else:
        return render_template(
            'insert.html',
            title='Insertar Articulo',
            )