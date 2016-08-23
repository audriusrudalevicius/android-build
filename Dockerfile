FROM java:8

MAINTAINER Audrius Rudalevicius <a.rudalevicius@nfq.lt>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -yq libstdc++6:i386 zlib1g:i386 libncurses5:i386 --no-install-recommends && \
    apt-get install -yq less \
    apt-get clean

# Download and untar SDK
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN curl -L "${ANDROID_SDK_URL}" | tar --no-same-owner -xz -C /usr/local
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# Install Android SDK components
ENV ANDROID_SUPPORT_VERSION 24.0.0
ENV ANDROID_AVD_HOME /root/.android/avd
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter extra-android-support,extra-android-m2repository,platform-tool --no-ui -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter build-tools-22.0.1,build-tools-23.0.1,build-tools-23.0.2,build-tools-23.0.3,build-tools-21.1.2,build-tools-24.0.0,build-tools-24.0.1,build-tools-21.0.3,android-22,android-23,android-24 --no-ui -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter extra-google-google_play_services,extra-google-m2repository --no-ui -a

# Install gradle
RUN mkdir -p /opt/packages/gradle
WORKDIR /opt/packages/gradle
RUN wget https://services.gradle.org/distributions/gradle-2.14-bin.zip
RUN unzip gradle-2.14-bin.zip
RUN ln -s /opt/packages/gradle/gradle-2.14/ /opt/gradle
RUN rm gradle-2.14-bin.zip
RUN mkdir -p /root/.gradle

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS -Xms256m -Xmx512m
RUN echo "sdk.dir=$ANDROID_HOME" > local.properties

# Add build scripts
COPY ./bin/* /usr/bin/

# Setup project
ENV PROJECT /project
RUN mkdir $PROJECT
WORKDIR $PROJECT

VOLUME /project
VOLUME /root/.gradle

CMD run_build