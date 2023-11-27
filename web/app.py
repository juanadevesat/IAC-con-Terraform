from flask import Flask, render_template, request, redirect, flash
import boto3
import json
import random
import datetime
import time


today = datetime.date.today().strftime('%Y-%m-%d')
todayUTC = int(time.time())

nombre_bucket = "s3terraformejfinal"
nombre_dynamoDB = "DBjuan-EjFinal-terraform"

# Crea una aplicación de Flask
app = Flask(__name__)
app.config['SECRET_KEY'] = '000000'


@app.route("/", methods=["GET", "POST"])
def index():
    """
    Definición: Endpoint para la página de inicio de la web. Contiene un formulario.

    Form: Nombre - Nombre insertado por el usuario.
    Form: Correo electrónico - email insertado por el usuario.

    Return: index.html
    """

    if request.method == "GET":
        return render_template("index.html")

    else:
        # Creamos un cliente de boto3 para acceder a S3
        s3 = boto3.client('s3', region_name="eu-west-3")

        # Comprobamos que se han introducido los datos
        nombre = request.form.get("nombre")
        if len(nombre) == 0:
            flash("¡Introduce un nombre!")
            return render_template("index.html")
        
        email = request.form.get("email")
        if len(email) == 0:
            flash("¡Introduce un correo electrónico!")
            return render_template("index.html", nom=nombre)

        # Comprobamos que el usuario no existe en la base de datos
        dynamodb = boto3.resource('dynamodb', region_name="eu-west-3")
        tabla_usuarios = dynamodb.Table(nombre_dynamoDB)
        response = tabla_usuarios.scan()
        docs = response['Items']

        docs_dict = []
        for doc in docs:
            docs_dict.append(doc)

        existe = False

        for d in docs_dict:
            if d['email'] == email:
                existe = True

        if existe == True:
            flash("¡Este correo electrónico ya ha sido registrado!")
            return render_template("index.html", nom=nombre, mail=email)
        else:
            # Creamos un diccionario con los datos del usuario
            usuario = {
                'ID': random.randint(100000, 999999),
                'nombre': nombre,       # Dato procedente de la web
                'email': email,         # Dato procedente de la web
                'registro': today       # Dato procedente de la variable creada arriba
            }

            try:
                # Guardamos los datos del usuario en un archivo JSON en cloud storage                
                s3.put_object(Bucket=nombre_bucket, Key=f'usuarios{todayUTC}.json', Body=json.dumps(usuario))
                return redirect("/loading")
            except:
                flash("¡Ha ocurrido un error! No se han almacenado los datos.")
                return render_template("index.html")

@app.route("/loading")
def loading():
    """
    Definición: Endpoint para la página de espera mientras carga la tabla.

    Return: loading.html
    """
    return render_template("loading.html")


@app.route("/data")
def data():
    """
    Definición: Endpoint para la página de la tabla de usuarios.

    Items - diccionario de datos extraídos de la base de datos

    return: data.html
    """

    # Configurar conexión con dynamoDB
    dynamodb = boto3.resource('dynamodb', region_name="eu-west-3")
    tabla_usuarios = dynamodb.Table(nombre_dynamoDB)

    # Obtener los elementos de la tabla
    response = tabla_usuarios.scan()
    items = response['Items']
    return render_template("data.html", items=items)


if __name__ == '__main__':
    # Ejecuta la aplicación
    app.run(host="0.0.0.0", port=5000, debug=False)
