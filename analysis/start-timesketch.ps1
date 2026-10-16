<#
 start-timesketch.ps1  -  start the two processes the Timesketch dev container needs
 (reconstructed from the project notes)

 The dev container starts "asleep": the Celery worker (processes uploads) and the gunicorn
 web server must be started by hand after every Docker or PC restart.
 Container name assumed to be timesketch-dev.
#>
docker exec -d timesketch-dev celery -A timesketch.lib.tasks worker --loglevel info
docker exec -d timesketch-dev gunicorn --reload -b 0.0.0.0:5000 timesketch.wsgi:application

Start-Sleep -Seconds 10
curl.exe -s -o NUL -w "Timesketch HTTP status: %{http_code}`n" http://127.0.0.1:5000/
