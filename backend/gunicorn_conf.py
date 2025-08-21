import multiprocessing as mp
import os


def _int(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except Exception:
        return default


# CPUs visibles (Docker respecte cpuset/cfs_quota)
CPU = max(1, mp.cpu_count())

# Calcul workers: (2*CPU)+1, borne min/max
_calc = (2 * CPU) + 1
workers = _int("WEB_CONCURRENCY", max(3, min(_calc, 12)))
threads = _int("THREADS", 1)
worker_class = os.getenv("WORKER_CLASS", "uvicorn.workers.UvicornWorker")
bind = os.getenv("BIND", "0.0.0.0:8000")

# Timeouts
timeout = _int("GUNICORN_TIMEOUT", 30)
graceful_timeout = _int("GUNICORN_GRACEFUL_TIMEOUT", 30)
keepalive = _int("GUNICORN_KEEPALIVE", 5)

# Recycling pour stabilite
max_requests = _int("GUNICORN_MAX_REQUESTS", 500)
max_requests_jitter = _int("GUNICORN_MAX_REQUESTS_JITTER", 50)

# Logs
accesslog = os.getenv("ACCESS_LOG", "-")
errorlog = os.getenv("ERROR_LOG", "-")
loglevel = os.getenv("LOG_LEVEL", "info")

# preloader pour limiter RSS sur reload
preload_app = os.getenv("PRELOAD_APP", "true").lower() == "true"

# Hooks (optionnel):
# def post_fork(server, worker):
#     pass
