FROM employmenttribunal.azurecr.io/ruby25-onbuild:0.4

# Adding argument support for ping.json
ARG APP_VERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APP_VERSION ${APP_VERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

# Application specific variables 

ENV FILES_CONTAINER_NAME      replace_this_at_build_time
ENV MOJSSO_CALLBACK_URI       replace_this_at_build_time
ENV MOJSSO_ID                 replace_this_at_build_time
ENV MOJSSO_ORG                replace_this_at_build_time
ENV MOJSSO_ROLE               replace_this_at_build_time
ENV MOJSSO_SECRET             replace_this_at_build_time
ENV MOJSSO_TOKEN_REDIRECT_URI replace_this_at_build_time
ENV MOJSSO_URL                replace_this_at_build_time
ENV SENTRY_DSN                replace_this_at_build_time
ENV USER_CONTAINER_NAME       replace_this_at_build_time


# fix to address http://tzinfo.github.io/datasourcenotfound - PET ONLY
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get install -qy tzdata --no-install-recommends && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

ENV PUMA_PORT 8000
EXPOSE $PUMA_PORT

# running app as a servive
ENV PHUSION true
RUN mkdir /etc/service/app
COPY run.sh /etc/service/app/run
RUN chmod +x /etc/service/app/run

