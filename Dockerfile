FROM ubuntu:18.04
MAINTAINER Thomas P. <docker@legz.fr>


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

ENV ANDROID_HOME /opt/android-sdk-linux
ENV VERSION_SDK_TOOLS "4333796"

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
RUN sdkmanager "emulator" "tools" "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25" \
    "platforms;android-24" \
    "platform-tools" \
    "build-tools;28.0.1" \
    "build-tools;27.0.3" \
    "system-images;android-28;google_apis;x86" \
    "system-images;android-27;google_apis;x86" \
    "system-images;android-26;google_apis;x86" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" 


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
