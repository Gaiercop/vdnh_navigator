from flask import Flask, Response, json
from flask import request

import pymysql
import asyncio

app = Flask(__name__)

@app.route("/sights", methods=['POST'])
def sights():
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '123456789', database = 'vdnh_navigator')
    
    with con:
        cur = con.cursor()
        cur.execute('SELECT latitude, longitude FROM sights')
        result = cur.fetchall()
        
        if result == None: 
            cur.close()
            return Response(str("Invalid data"), 200)
        
        else:
            cur.close()
            
            string_result = str()
            
            for tup in result:
                for el in tup:
                    string_result += (str(el) + " ")
            
            return string_result


@app.route("/get_sight_name", methods=['POST'])
def get_sight_name():
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '123456789', database = 'vdnh_navigator')
    
    latitude = str(request.json['latitude'])
    longitude = str(request.json['longitude'])
    
    with con:
        cur = con.cursor()
        cur.execute(f'SELECT name FROM sights WHERE latitude = {latitude} AND longitude = {longitude}')
        
        result = cur.fetchone()
        cur.close()
        
        return Response(result[0], 200)
    
@app.route("/add_route", methods=['POST'])
def add_route():
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '123456789', database = 'vdnh_navigator')
    
    route = str(request.json['route'])
    duration = float(request.json['duration'])
    distance = float(request.json['distance'])
    
    with con:
        cur = con.cursor()
        cur.execute(f'INSERT INTO routes(points, time, distance) VALUES ("{route}", {duration}, {distance})')
        
        cur.close()
        con.commit()
        
        return Response("200", 200)
    
@app.route("/get_routes", methods=['POST'])
def get_routes():
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '123456789', database = 'vdnh_navigator')
    
    with con:
        cur = con.cursor()
        cur.execute('SELECT * FROM routes')
        
        data = cur.fetchall()
        
        return Response(json.dumps(data), 200)


        
if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(app.run(host='0.0.0.0', port=5000))

