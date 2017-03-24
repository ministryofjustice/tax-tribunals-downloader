FROM ministryofjustice/ruby:2.3.1-webapp-onbuild

ENV PUMA_PORT 9292
ENV RACK_ENV production

ENV BUCKET_NAME               replace_this_at_build_time
ENV MOJSSO_CALLBACK_URI       replace_this_at_build_time
ENV MOJSSO_ID                 replace_this_at_build_time
ENV MOJSSO_ORG                replace_this_at_build_time
ENV MOJSSO_ROLE               replace_this_at_build_time
ENV MOJSSO_SECRET             replace_this_at_build_time
ENV MOJSSO_TOKEN_REDIRECT_URI replace_this_at_build_time
ENV MOJSSO_URL                replace_this_at_build_time
ENV USER_BUCKET_NAME          replace_this_at_build_time
ENV SENTRY_DSN                replace_this_at_build_time

RUN touch /etc/inittab

RUN rm /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y

EXPOSE $PUMA_PORT

ENTRYPOINT ["./run.sh"]
