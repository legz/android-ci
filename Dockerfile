FROM ubuntu:18.04
MAINTAINER Thomas P. <docker@legz.fr>


ENV ANDROID_HOME /opt/android-sdk-linux
ENV VERSION_SDK_TOOLS "4333796"


# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Base (non android specific) tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  locales \
  git \
  wget \
  python \
  build-essential \
  zip \
  unzip \
  imagemagick \
  && locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" 

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  openjdk-8-jdk \
  libc6:i386 \
  libstdc++6:i386 \
  libgcc1:i386 \
  libncurses5:i386 \
  libz1:i386 


# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools


# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

# Platform tools
## RUN sdkmanager "emulator" "tools" "platform-tools"


# ------------------------------------------------------
# --- Install Gradle from PPA
# Not necessary to install Gradle because Android projects use the Gradle Wrapper (gradlew)

# Gradle PPA
# RUN apt-get update \
#  && apt-get -y install gradle \
# && gradle -v


# ------------------------------------------------------
# --- Install Fastlane

RUN apt-get -y install ruby-dev
RUN gem install fastlane --no-document \
&& fastlane --version


# ------------------------------------------------------
# --- Cleanup 

RUN apt-get clean
