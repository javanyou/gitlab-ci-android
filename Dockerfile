FROM openjdk:8-jdk

# update source
RUN echo 'deb http://mirrors.163.com/debian/ jessie main non-free contrib' > /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' >> /etc/apt/sources.list

RUN apt-get -qq update && apt-get install -qqy cppcheck ssh file make ccache lib32stdc++6 lib32z1 lib32z1-dev \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install android sdk
ENV VERSION_SDK_TOOLS "3859397"
ENV ANDROID_HOME="/opt/android/android-sdk-linux"

RUN mkdir -p ${ANDROID_HOME}  && curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > ${ANDROID_HOME}/sdk.zip && \
    unzip ${ANDROID_HOME}/sdk.zip -d ${ANDROID_HOME} && \
    rm -v ${ANDROID_HOME}/sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt ${ANDROID_HOME}

RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update && \
  (while sleep 3; do echo "y"; done) | ${ANDROID_HOME}/tools/bin/sdkmanager --package_file=${ANDROID_HOME}/packages.txt

RUN echo "SDK Manager Finish."
ENV ANDROID_NDK_ROOT="${ANDROID_HOME}/ndk-bundle"
ENV ANDROID_NDK="${ANDROID_NDK_ROOT}"
ENV NDK_ROOT="${ANDROID_NDK}"
ENV CPP_LINT="/opt/cpplint/cpplint"
ENV PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${GRADLE_HOME}/bin:${CPP_LINT}:${ANDROID_NDK_ROOT}:${PATH}"

