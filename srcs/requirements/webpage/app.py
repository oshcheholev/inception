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
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        padding: 40px;
        min-height: 100vh;
        background:
            radial-gradient(circle at top left, #1f2a44 0%, transparent 30%),
            radial-gradient(circle at bottom right, #14213d 0%, transparent 35%),
            linear-gradient(135deg, #090b10, #111827);
        color: #f1f5f9;
        font-family: "Inter", "Segoe UI", sans-serif;
    }

    h1 {
        font-size: 42px;
        margin-bottom: 12px;
        background: linear-gradient(90deg, #4cc9f0, #7b61ff);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        letter-spacing: 1px;
    }

    .info {
        margin-bottom: 40px;
        color: #94a3b8;
        font-size: 16px;
        line-height: 1.6;
    }

    .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 24px;
    }

    .card {
        position: relative;
        overflow: hidden;
        background: rgba(22, 27, 34, 0.75);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 2px;
        padding: 24px;
        backdrop-filter: blur(12px);
        transition:
            transform 0.25s ease,
            box-shadow 0.25s ease,
            border-color 0.25s ease;
        box-shadow:
            0 10px 25px rgba(0, 0, 0, 0.25),
            inset 0 1px 0 rgba(255, 255, 255, 0.04);
    }

    .card::before {
        content: "";
        position: absolute;
        inset: 0;
        background: linear-gradient(
            135deg,
            rgba(255,255,255,0.08),
            transparent 40%
        );
        pointer-events: none;
    }

    .card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow:
            0 20px 40px rgba(0, 0, 0, 0.45),
            0 0 20px rgba(76, 201, 240, 0.15);
    }

    .ok {
        border-left: 5px solid #22c55e;
    }

    .bad {
        border-left: 5px solid #ef4444;
    }

    .service {
        font-size: 24px;
        font-weight: 700;
        margin-bottom: 12px;
    }

    .status {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-size: 16px;
        padding: 8px 14px;
        border-radius: 999px;
        background: rgba(255,255,255,0.06);
        margin-bottom: 14px;
    }

    # .ok .status::before {
    #     content: "●";
    #     color: #22c55e;
    # }

    # .bad .status::before {
    #     content: "●";
    #     color: #ef4444;
    # }

    a {
        color: #67e8f9;
        text-decoration: none;
        transition: 0.2s;
    }

    a:hover {
        color: #a5f3fc;
        text-shadow: 0 0 12px rgba(103, 232, 249, 0.6);
    }

    .footer {
        margin-top: 50px;
        color: #64748b;
        font-size: 14px;
        text-align: center;
    }

    @media (max-width: 768px) {
        body {
            padding: 24px;
        }

        h1 {
            font-size: 32px;
        }
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
    <p>Inception monitoring dashboard  • Docker • Nginx • MariaDB • WordPress • Redis • cAdvisor • Adminer • Flask</p>
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