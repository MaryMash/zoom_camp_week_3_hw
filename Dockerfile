FROM kestra/kestra:latest

COPY requirements.txt requirements.txt

USER root
RUN pip install -r requirements.txt

CMD ["server", "standalone"]