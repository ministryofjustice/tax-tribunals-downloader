FROM ministryofjustice/ruby:2.3.1-webapp-onbuild

ENV PUMA_PORT 3000
ENV RACK_ENV production

RUN touch /etc/inittab

RUN apt-get update && apt-get install -y

EXPOSE $PUMA_PORT

ENTRYPOINT ["./run.sh"]
