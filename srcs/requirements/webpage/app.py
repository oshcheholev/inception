from flask import Flask, render_template_string, jsonify
import socket
import requests
import time

app = Flask(__name__)

START_TIME = time.time()

def check_tcp(host, port):
    try:
        socket.create_connection((host, port), timeout=1)
        return True
    except:
        return False

def check_http(url):
    try:
        r = requests.get(url, timeout=3, verify=False)
        return r.status_code < 500
    except:
        return False

def uptime():
    seconds = int(time.time() - START_TIME)

    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    seconds %= 60

    return f"{hours}h {minutes}m {seconds}s"

def get_status():
    return {
        "wordpress": check_http("https://nginx"),
        "nginx": check_tcp("nginx", 443),
        "redis": check_tcp("redis", 6379),
        "mariadb": check_tcp("mariadb", 3306),
        "adminer": check_http("http://adminer"),
        "cadvisor": check_http("http://cadvisor:8080"),
        "ftp": check_tcp("ftp", 21),
        "time": time.strftime("%H:%M:%S"),
        "uptime": uptime()
    }

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Inception Monitoring Dashboard</title>

    <meta http-equiv="refresh" content="5">

    <style>
        body {
            margin: 0;
            padding: 30px;
            background: #0b0f14;
            color: #e6e6e6;
            font-family: Arial, sans-serif;
        }

        h1 {
            color: #4cc9f0;
            margin-bottom: 10px;
        }

        .info {
            margin-bottom: 30px;
            opacity: 0.8;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
        }

        .card {
            background: #161b22;
            border-radius: 12px;
            padding: 20px;
            transition: 0.2s;
        }

        .card:hover {
            transform: translateY(-3px);
        }

        .ok {
            border-left: 6px solid #2ecc71;
        }

        .bad {
            border-left: 6px solid #e74c3c;
        }

        .service {
            font-size: 22px;
            margin-bottom: 10px;
        }

        .status {
            font-size: 18px;
            margin-bottom: 10px;
        }

        a {
            color: #4cc9f0;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .footer {
            margin-top: 40px;
            opacity: 0.6;
            font-size: 14px;
        }
    </style>
</head>

<body>

<h1>Inception Infrastructure Monitor</h1>

<div class="info">
    Last update: {{ status.time }}<br>
    Monitoring uptime: {{ status.uptime }}
</div>

<div class="grid">

    <div class="card {{ 'ok' if status.wordpress else 'bad' }}">
        <div class="service">WordPress</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.wordpress else '🔴 DOWN' }}
        </div>
        <a href="https://oshcheho.42.fr" target="_blank">
            Open Website
        </a>
    </div>

    <div class="card {{ 'ok' if status.nginx else 'bad' }}">
        <div class="service">Nginx</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.nginx else '🔴 DOWN' }}
        </div>
    </div>

    <div class="card {{ 'ok' if status.mariadb else 'bad' }}">
        <div class="service">MariaDB</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.mariadb else '🔴 DOWN' }}
        </div>
        <a href="http://oshcheho.42.fr:8080" target="_blank">
            Open Adminer
        </a>
    </div>

    <div class="card {{ 'ok' if status.redis else 'bad' }}">
        <div class="service">Redis</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.redis else '🔴 DOWN' }}
        </div>
        <a href="https://oshcheho.42.fr/wp-admin/options-general.php?page=redis-cache"
           target="_blank">
            Redis Settings
        </a>
    </div>

    <div class="card {{ 'ok' if status.adminer else 'bad' }}">
        <div class="service">Adminer</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.adminer else '🔴 DOWN' }}
        </div>
        <a href="http://oshcheho.42.fr:8080" target="_blank">
            Open Adminer
        </a>
    </div>

    <div class="card {{ 'ok' if status.cadvisor else 'bad' }}">
        <div class="service">cAdvisor</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.cadvisor else '🔴 DOWN' }}
        </div>
        <a href="http://oshcheho.42.fr:8081" target="_blank">
            Open cAdvisor
        </a>
    </div>

    <div class="card {{ 'ok' if status.ftp else 'bad' }}">
        <div class="service">FTP Server</div>
        <div class="status">
            {{ '🟢 ONLINE' if status.ftp else '🔴 DOWN' }}
        </div>
    </div>

</div>

<div class="footer">
    <p>Inception monitoring dashboard  • Docker • Nginx • MariaDB • WordPress • Redis• cAdvisor • Adminer • Flask</p>
    <p>Created by oshcheho for 42 Inception project</p>
</div>

</body>
</html>
"""

@app.route("/")
def dashboard():
    return render_template_string(HTML, status=get_status())

@app.route("/api")
def api():
    return jsonify(get_status())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)